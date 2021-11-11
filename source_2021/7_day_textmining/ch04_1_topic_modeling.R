# LDA(Latent Dirichlet Allocation, 잠재 디리클레 할당) 모델
# 가정 
# - 토픽은 여러 단어의 혼합으로 구성된다. 
# - 문서는 여러 토픽의 혼합으로 구성된다. 
# - 이미지: https://medium.com/@connectwithghosh/topic-modelling-with-latent-dirichlet-allocation-lda-in-pyspark-2cb3ebd5678e

# LDA 모델 만들기
library(readr)
library(dplyr)
library(stringr)
library(textclean)
library(tidytext)
library(KoNLP)
library(tm)
library(scales)
library(ggplot2)
library(extrafont)
loadfonts()

raw_news_comment <- read_csv("data/news_comment_parasite.csv") %>%
  mutate(id = row_number())

# ---- 기본적인 전처리 ----
# - 중복 문서 제거
# - 짧은 문서 제거
news_comment <- raw_news_comment %>%
  mutate(reply = str_replace_all(reply, "[^가-힣]", " "),
         reply = str_squish(reply)) %>%
  distinct(reply, .keep_all = T) %>% # 중복 댓글 제거
  filter(str_count(reply, boundary("word")) >= 3) # # 짧은 문서 제거 - 3 단어 이상 추출

# 명사 추출
comment <- news_comment %>%
  unnest_tokens(input = reply,
                output = word,
                token = extractNoun,
                drop = F) %>%
  filter(str_count(word) > 1) %>%
  group_by(id) %>% 
  distinct(word, .keep_all = T) %>%   # 댓글 내 중복 단어 제거
  ungroup() %>%
  select(id, word)

# 빈도가 높은 단어 제거하기 
count_word <- comment %>%
  add_count(word) %>%
  filter(n <= 200) %>%
  select(-n)

# 불용어 및 유의어 제거하기
count_word %>%
  count(word, sort = T) %>%
  print(n = 200)

# 불용어 목록 만들기
# 필요에 따라 추가 가능
stopword <- tibble(word = c("들이", "하다", "하게", "하면", "해서", "이번", "하네",
                            "해요", "이것", "니들", "하기", "하지", "한거", "해주",
                            "그것", "어디", "여기", "까지", "이거", "하신", "만큼"))

# 불용어 제거하기 
count_word <- count_word %>%
  anti_join(stopword, by = "word")

# ---- LDA 모델 만들기 ----
# 문서별 단어 빈도 구하기
count_word_doc <- count_word %>%
  count(id, word, sort = T)

count_word_doc

# DTM 만들기
# Document: 문서 구분 기준
# term: 단어
# value: 단어 빈도
dtm_comment <- count_word_doc %>%
  cast_dtm(document = id, term = word, value = n)

dtm_comment

# DTM 내용 확인하기 
as.matrix(dtm_comment[1:8, 1:8])

# LDA()
# 패키지 설치
# install.packages("topicmodels")
library(topicmodels)

# - K: 토픽 수, 여기서는 8개의 토픽으로 모델 만들기 위해 8 입력
# - method: 샘플링 방법: 주로 깁스 샘플링을 이용함. 
# - 깁스 샘플링: https://ratsgo.github.io/statistics/2017/05/31/gibbs/

# 토픽 모델
lda_model <- LDA(dtm_comment, 
                 k = 8, 
                 method = "Gibbs", 
                 control = list(seed = 1234))

glimpse(lda_model)

# @beta: 특정 단어가 각 토픽에 등장할 확률
# @gamma: 문서가 각 토픽에 등장할 확률
# https://ratsgo.github.io/from%20frequency%20to%20semantics/2017/06/01/LDA/

# ---- 토픽별 주요 단어 살펴보기 ----
term_topic <- tidy(lda_model, matrix = "beta")
term_topic

# 우리: 토픽 1에 등장할 확률 0.000398
# 우리: 토픽 2에 등장할 확률 0.00218

# beta는 확률 값이므로 한 토픽의 beta를 모두 더하면 1이 됨
term_topic %>% 
  filter(topic == 1) %>% 
  summarise(sum_beta = sum(beta))

# 단어별 테스트 해보기
# term_topic %>% 
#  filter(term == "") 

# 특정 토픽에서 beta가 높은 단어 살펴보기 
term_topic %>% 
  filter(topic == 1) %>% 
  arrange(-beta)

# 모든 토픽의 주요 단어 살펴보기
terms(lda_model, 20) %>% 
  data.frame()

# 토픽별 주요 단어 시각화
top_term_topic <- term_topic %>% 
  group_by(topic) %>% 
  slice_max(beta, n = 10)

# 막대 그래프 만들기
ggplot(top_term_topic, aes(x = reorder_within(term, beta, topic), 
                           y = beta,
                           fill = factor(topic))) + 
  geom_col(show.legend = F) + 
  facet_wrap(~ topic, scales = "free", ncol = 4) + 
  coord_flip() + 
  scale_x_reordered() + 
  labs(x = NULL) + 
  theme() + 
  theme_minimal(base_family = "AppleGothic")

# ---- 문서를 토픽별로 분류하기 ----
# 감마 추출: 문서가 각 토픽에 등장할 확률
doc_topic <- tidy(lda_model, matrix = "gamma")

# 문서별로 확률이 가장 높은 토픽 추출
doc_class <- doc_topic %>%
  group_by(document) %>%
  slice_max(gamma, n = 1)

# 원문에 확률이 가장 높은 토픽 번호 부여
# integer로 변환
doc_class$document <- as.integer(doc_class$document)

# 원문에 토픽 번호 부여
news_comment_topic <- raw_news_comment %>%
  left_join(doc_class, by = c("id" = "document"))

# 결합 확인
news_comment_topic %>% select(id, topic)
news_comment_topic %>% count(topic)
news_comment_topic <- news_comment_topic %>% na.omit()

# 토픽별 문서 빈도 구하기
count_topic <- news_comment_topic %>% count(topic)

# 문서 빈도에 주요 단어 결합
top_terms <- term_topic %>%
  group_by(topic) %>%
  slice_max(beta, n = 6, with_ties = F) %>%
  summarise(term = paste(term, collapse = ", "))

top_terms

count_topic_word <- count_topic %>%
  left_join(top_terms, by = "topic") %>%
  mutate(topic_name = paste("Topic", topic))

# 주요 막대 그래프 만들기
ggplot(count_topic_word,
       aes(x = reorder(topic_name, n),
           y = n,
           fill = topic_name)) +
  geom_col(show.legend = F) +
  coord_flip() +
  
  geom_text(aes(label = n) ,                # 문서 빈도 표시
            hjust = -0.2) +                 # 막대 밖에 표시
  
  geom_text(aes(label = term),              # 주요 단어 표시
            hjust = 1.03,                   # 막대 안에 표시
            col = "white",                  # 색깔
            fontface = "bold",              # 두껍게
            family = "AppleGothic") +       # 폰트
  
  scale_y_continuous(expand = c(0, 0),      # y축-막대 간격 줄이기
                     limits = c(0, 820)) +  # y축 범위
  labs(x = NULL) + 
  theme_minimal()

# ---- 토픽 이름 짓기 ----
# 원문 읽기 편하게 전처리 & gamma가 높은 순으로 정렬
comment_topic <- news_comment_topic %>%
  mutate(reply = str_squish(replace_html(reply))) %>%
  arrange(-gamma)

# 토픽 1 내용 살펴보기
comment_topic %>%
  filter(topic == 1 & str_detect(reply, "작품")) %>%
  head(50) %>%
  pull(reply)

# 토픽 이름 목록 만들기
name_topic <- tibble(topic = 1:8,
                     name = c("1. ",
                              "2. ",
                              "3. ",
                              "4. ",
                              "5. ",
                              "6. ",
                              "7. ",
                              "8. "))

# 토픽 이름 결합하기
top_term_topic_name <- top_term_topic %>%
  left_join(name_topic, name_topic, by = "topic")

top_term_topic_name

# 막대 그래프 만들기
ggplot(top_term_topic_name,
       aes(x = reorder_within(term, beta, name),
           y = beta,
           fill = factor(topic))) +
  geom_col(show.legend = F) +
  facet_wrap(~ name, scales = "free", ncol = 2) +
  coord_flip() +
  scale_x_reordered() +
  
  labs(title = "영화 기생충 아카데미상 수상 기사 댓글 토픽",
       subtitle = "토픽별 주요 단어 Top 10",
       x = NULL, y = NULL) +
  
  theme_minimal() +
  theme(text = element_text(family = "AppleGothic"),
        title = element_text(size = 12),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# ---- 최적의 토픽 수 정하기 ----
# 방법 1. 모델의 내용을 보고 해석 가능성 고려해 토픽 수 정하기 
# 방법 2. 여러 모델의 성능 지표를 비교해 토픽 수 정하기
# 방법 3. 두가지 방법을 함께 사용하기

# install.packages("ldatuning")
# https://cran.r-project.org/web/packages/ldatuning/index.html
# Mac Error Here
# https://stackoverflow.com/questions/67480220/fatal-error-in-r-on-mac-when-using-ldatuning-package
