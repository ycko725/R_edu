# 빅카인즈 신문기사 추출
# https://www.bigkinds.or.kr/
# 검색어: 인공지능
# 언론사: 중앙일보, 조선일보, 한겨레, 경향신문, 한국경제, 매일경제
# 분석: 분석기사
# 약 1000건

# ---- 패키지 불러오기 ----

library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(KoNLP)
library(tidytext)
library(tidylo)
library(reshape2)


# ---- 데이터 수집 ----


readxl::read_excel("data/NewsResult_20210811-20211111.xlsx") %>% names()

ai_df <- readxl::read_excel("data/NewsResult_20210811-20211111.xlsx") %>% 
  select(일자, 제목, 본문, 언론사, cat = `통합 분류1`) 

ai_df %>% head()

# ---- 열 재구성


ai2_df <- 
  ai_df %>% 
  # 중복기사 제거
  distinct(제목, .keep_all = T) %>% 
  # 기사별 ID부여
  mutate(ID = factor(row_number())) %>% 
  # 월별로 구분한 열 추가
  mutate(month = month(ymd(일자))) %>% 
  # 기사 제목과 본문 결합
  unite(제목, 본문, col = "text", sep = " ") %>% 
  # 중복 공백 제거
  mutate(text = str_squish(text)) %>% 
  # 언론사 분류: 보수 진보 경제 %>% 
  mutate(press = case_when(
    언론사 == "조선일보" ~ "종합지",
    언론사 == "중앙일보" ~ "종합지",
    언론사 == "경향신문" ~ "종합지",
    언론사 == "한겨레" ~ "종합지",
    언론사 == "한국경제" ~ "경제지",
    TRUE ~ "경제지") ) %>% 
  # 기사 분류 구분 
  separate(cat, sep = ">", into = c("cat", "cat2")) %>% 
  # IT_과학, 경제, 사회 만 선택
  filter(str_detect(cat, "IT_과학|경제|사회")) %>% 
  select(-cat2)  

# 전처리 결과 확인
ai2_df %>% head(5)
ai2_df %>% names()
ai2_df$cat %>% unique()

# 분류별 월별 기사의 양 계산
ai2_df %>% count(cat, sort = T)
ai2_df %>% count(month, sort = T)

# ---- 정제 ----
ai_tk <- 
  ai2_df %>% 
  mutate(text = str_remove_all(text, "[^(\\w+|\\s)]")) %>%  # 문자 혹은 공백 이외 것 제거
  unnest_tokens(word, text, token = extractNoun, drop = F) 

ai_tk %>% glimpse()

# 불용어 제거
ai_tk <- 
  ai_tk %>% 
  filter(!word %in% c("인공지능", "AI", "ai", "인공지능AI", "인공지능ai")) %>% 
  filter(str_detect(word, "[:alpha:]+")) 

# 단어의 총빈도와 상대빈도
ai_tk %>% count(word, sort = T)

# 상대빈도
ai_tk %>% count(cat, word, sort = T) %>% 
  bind_log_odds(set = cat, feature = word, n = n) %>% 
  arrange(log_odds_weighted)

ai_tk %>% count(cat, word, sort = T) %>% 
  bind_tf_idf(term = word, document = word, n = n) %>% 
  arrange(idf)

# 한글자 단어는 문서의 주제를 나타내는데 기여하지 못하는 경우도 있고, 고유명사인데 형태소로 분리돼 있는 경우도 있다. 
# 특이한 경우가 없으면 한글자 단어는 모두 제거한다. 
# pull()함수로 열에 포함된 문자열을 벡터로 출력하므로, 모든 내용을 확인할 수 있다.
ai_tk %>% 
  filter(word == "하") %>% pull(text) %>% head(3)

ai_tk %>% 
  filter(str_length(word) > 1) -> ai2_tk

# 기술 기업 등은 매우 일반적으로 사용되는 단어이다. 이런 단어는 제거를 해야 한다. 
ai2_tk %>% 
  count(word, sort = T) 

# 상대빈도 확인
ai2_tk %>% count(cat, word, sort = T) %>% 
bind_log_odds(set = cat, feature = word, n = n) %>% 
  arrange(-log_odds_weighted)

ai2_tk %>% count(cat, word, sort = T) %>% 
  bind_tf_idf(term = word, document = word, n = n) %>% 
  arrange(tf_idf)

# stm 말뭉치
library(stm)

# str_flatten() 문자열 결합해 단일 요소로 산출
combined_df <-
  ai2_tk %>%
  group_by(ID) %>%
  summarise(text2 = str_flatten(word, " ")) %>%
  ungroup() %>% 
  inner_join(ai2_df, by = "ID")

combined_df %>% glimpse()

# textProcessor(): ‘documents’ ‘vacab’ ’meta’등의 하부요소가 생성된다. ’meta’에 텍스트데이터가 저장돼 있다.
processed <- 
  ai2_df %>% textProcessor(documents = combined_df$text2, metadata = .)
out <- 
  prepDocuments(processed$documents,
                processed$vocab,
                processed$meta)

?textProcessor
plotRemoved(processed$documents, lower.thresh = seq(0, 100, by = 5))

out <-
  prepDocuments(processed$documents,
                processed$vocab,
                processed$meta, 
                lower.thresh = 15)

# 모형구축 사전 작업
docs <- out$documents
vocab <- out$vocab
meta <- out$meta

# ---- 분석 ----
topicN <- c(3, 10)
storage <- searchK(out$documents, out$vocab, K = topicN)

plot(storage)

# 배타성(exclusivity): 특정 주제에 등장한 단어가 다른 주제에는 나오지 않는 정도. 확산타당도에 해당.
# 의미 일관성(semantic coherence): 특정 주제에 높은 확률로 나타나는 단어가 동시에 등장하는 정도. 수렴타당도에 해당.
# 지속성(heldout likelihood): 데이터 일부가 존재하지 않을 때의 모형 예측 지속 정도.
# 잔차(residual): 투입한 데이터로 모형을 설명하지 못하는 오차.

# 결론: 3개보다는 10개가 좋아보임

# ---- 주제 모형 구성 ----
stm_fit <-
  stm(
    documents = docs,
    vocab = vocab,
    K = 10,    # 토픽의 수
    data = meta,
    init.type = "Spectral",
    seed = 37 # 반복실행해도 같은 결과가 나오게 난수 고정
  )

summary(stm_fit)

# stm 패키지
# 참조: https://www.structuraltopicmodel.com/
# - Highest probability: 각 주제별로 단어가 등장할 확률이 높은 정도. 베타() 값.
# - FREX: 전반적인 단어빈도의 가중 평균. 해당 주제에 배타적으로 포함된 정도.
# - Lift: 다른 주제에 덜 등장하는 정도. 해당 주제에 특정된 정도.
# - score: 다른 주제에 등장하는 로그 빈도. 해당 주제에 특정된 정도.

# ---- 모형 결과 시각화 ----
stm_fit <-
  stm(
    documents = docs,
    vocab = vocab,
    K = 6,    # 토픽의 수
    data = meta,
    init.type = "Spectral",
    seed = 37, # 반복실행해도 같은 결과가 나오게 난수 고정
    verbose = F
  )

summary(stm_fit) %>% glimpse()
summary(stm_fit)

td_beta <- stm_fit %>% tidy(matrix = 'beta') 

td_beta %>% 
  group_by(topic) %>% 
  slice_max(beta, n = 7) %>% 
  ungroup() %>% 
  mutate(topic = str_c("주제", topic)) %>% 
  
  ggplot(aes(x = beta, 
             y = reorder(term, beta),
             fill = topic)) +
  geom_col(show.legend = F) +
  facet_wrap(~topic, scales = "free") +
  labs(x = expression("단어 확률분포: "~beta), y = NULL,
       title = "주제별 단어 확률 분포",
       subtitle = "각 주제별로 다른 단어들로 군집") +
  theme(plot.title = element_text(size = 20))

# 주제별 문서 분포
td_gamma <- stm_fit %>% tidy(matrix = "gamma") 
td_gamma %>% glimpse()

td_gamma %>% 
  mutate(max = max(gamma),
         min = min(gamma),
         median = median(gamma))

td_gamma %>% 
  ggplot(aes(x = gamma, fill = as.factor(topic))) +
  geom_histogram(bins = 100, show.legend = F) +
  facet_wrap(~topic) + 
  labs(title = "주제별 문서 확률 분포",
       y = "문서(기사)의 수", x = expression("문서 확률분포: "~(gamma))) +
  theme(plot.title = element_text(size = 20))

plot(stm_fit, type = "summary", n = 5)

# ggplot2 시각화로 구성해본다. 
# 주제별 상위 5개 단어 추출
top_terms <- 
  td_beta %>% 
  group_by(topic) %>% 
  slice_max(beta, n = 5) %>% 
  select(topic, term) %>% 
  summarise(terms = str_flatten(term, collapse = ", ")) 

# 주제별 감마 평균 계산
gamma_terms <- 
  td_gamma %>% 
  group_by(topic) %>% 
  summarise(gamma = mean(gamma)) %>% 
  left_join(top_terms, by = 'topic') %>% 
  mutate(topic = str_c("주제", topic),
         topic = reorder(topic, gamma))

gamma_terms %>% 
  
  ggplot(aes(x = gamma, y = topic, fill = topic)) +
  geom_col(show.legend = F) +
  geom_text(aes(label = round(gamma, 2)), # 소수점 2자리 
            hjust = 1.4) +                # 라벨을 막대도표 안쪽으로 이동
  geom_text(aes(label = terms), 
            hjust = -0.05, family = "AppleGothic") +              # 단어를 막대도표 바깥으로 이동
  scale_x_continuous(expand = c(0, 0),    # x축 막대 위치를 Y축쪽으로 조정
                     limit = c(0, 1)) +   # x축 범위 설정
  labs(x = expression("문서 확률분포"~(gamma)), y = NULL,
       title = "AI 관련보도 상위 주제어",
       subtitle = "주제별로 기여도가 높은 단어 중심", 
       caption = "조선일보, 중앙일보, 동아일보, 한국경제, 매일경제 기사 추출 (2021-08 ~ 2021-11) created by McBert") +
  theme(plot.title = element_text(size = 20), 
        ) + 
  theme_minimal(base_family = "AppleGothic")
  
