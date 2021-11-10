library(dplyr)
library(KoNLP)
library(stringr)
library(ggplot2)
library(showtext)
library(ggwordcloud)
library(tidytext)

useNIADic()

text = tibble(
  value = c("금융이 미래다", "위드코로나 최대 실적")
)

text
extractNoun(text$value)

text %>% 
  unnest_tokens(input = value, 
                output = word, 
                token = extractNoun)

# 뉴스기사 
raw_news = readLines("data/economy_news.txt", encoding = "UTF-8")

# 기본 전처리
news <- raw_news %>% 
  str_replace_all("[^가-힣]", " ") %>% # 한글만 남기기
  str_squish() %>% # 중복 공백 제거
  as_tibble()

# 명사 기준 토튼화
word_noun <- news %>% 
  unnest_tokens(input = value, 
                output = word, 
                token = extractNoun)

# 단어 카운트
# str_count("회복세")

word_noun2 <- word_noun %>% 
  count(word, sort = TRUE) %>% 
  filter(str_count(word) > 1)

word_noun2

# 상위 10개 단어 추출
top10 <- word_noun2 %>% head(10)

# 그래프
ggplot(top10, aes(x = reorder(word, n), y = n)) + 
  geom_col() + 
  coord_flip()

# wordcloud
ggplot(word_noun2, aes(label = word, size = n, col = n)) + 
  geom_text_wordcloud(seed = 1234) + 
  scale_radius(limits = c(3, NA), 
               range = c(3, 15)) + 
  scale_color_gradient(low = "#00ADA1", high = "#F79D6F") + 
  theme_minimal()

# sentences 
raw_news %>% 
  str_squish() %>% 
  as_tibble() %>% 
  unnest_tokens(input = value, 
                output = sentences, 
                token = "sentences") -> sentences_df

str_detect("치킨은 맛있다", "피자")

sentences_df %>% 
  filter(str_detect(sentences, "하락"))
