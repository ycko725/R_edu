library(dplyr)
library(KoNLP)
library(stringr)
library(ggplot2)
library(showtext)
library(tidytext)

# 요소수 문제 관련 - 자동차
def_car = readLines("data/def_news_car.txt", encoding = "UTF-8")

# 핵심 포인트
car = def_car %>% 
  as_tibble() %>% 
  mutate(category = "def_car")

# 요소수 문제 관련 - 중국
def_china = readLines("data/def_news_china.txt", encoding = "UTF-8")
china <- def_china %>% 
  as_tibble() %>% 
  mutate(category = "def_china") 

# 합치기 
bind_news = bind_rows(car, china) %>% select(category, value)
head(bind_news)

# 전처리 진행
news_df = bind_news %>% 
  mutate(value = str_replace_all(value, "[^가-힣]", " "), 
         value = str_squish(value))

news_df

# 토큰화
news_df %>% 
  unnest_tokens(input = value, 
                output = word,
                token = extractNoun) -> news_df

frequency = news_df %>% 
  count(category, word) %>% 
  filter(str_count(word) > 1)

head(frequency)

# df = tibble(x = c(1:100))
# df %>% slice_max(x, n = 3)

top10 <- frequency %>% 
  group_by(category) %>% 
  slice_max(n, n = 10)

top10 %>% filter(category == "def_car")
top10 %>% filter(category == "def_china")


# with_ties? 
frequency %>% 
  group_by(category) %>% 
  slice_max(n, n = 15, with_ties = FALSE) -> top10 # --> 옵션 확인

ggplot(top10, aes(x = reorder(word, n), 
                  y = n, 
                  fill = category)) + 
  geom_col() + 
  coord_flip() + 
  facet_wrap( ~ category) + 
  theme_minimal()

ggplot(top10, aes(x = reorder(word, n), 
                  y = n, 
                  fill = category)) + 
  geom_col() + 
  coord_flip() + 
  facet_wrap( ~ category, scales = "free_y") + # y축 통일 안시킴
  theme_minimal()

frequency %>% 
  filter(word != "요소") %>% 
  group_by(category) %>% 
  slice_max(n, n = 10, with_ties = FALSE) -> top10

ggplot(top10, aes(x = reorder_within(word, n, category), 
                  y = n, 
                  fill = category)) + 
  geom_col() + 
  coord_flip() + 
  facet_wrap( ~ category, scales = "free_y") + # y축 통일 안시킴
  scale_x_reordered() + 
  theme_minimal()

library(tidyr)

df_long <- frequency %>% 
  group_by(category) %>% 
  slice_max(n, n = 10) %>% 
  filter(word %in% c("가격", "수입", "공급망"))

df_long

df_wide <- df_long %>% 
  pivot_wider(names_from = category, 
              values_from = n, 
              values_fill = list(n = 0))

frequency_wide <- frequency %>% 
  pivot_wider(names_from = category, 
              values_from = n, 
              values_fill = list(n = 0))
# ratio 변수 추가
library(magrittr)
frequency_wide <- frequency_wide %>% 
  mutate(ratio_car = ((def_car + 1) / (sum(def_car + 1))), 
         ratio_china = ((def_china + 1) / (sum(def_china + 1))))

frequency_wide <- frequency_wide %>% 
  mutate(odds_ratio = ratio_car / ratio_china)

frequency_wide %>% 
  arrange(-odds_ratio)

top_df <- frequency_wide %>% 
  filter(rank(odds_ratio) <= 10 | rank(-odds_ratio) <= 10)

top_df <- top_df %>% 
  mutate(category = ifelse(odds_ratio > 1, "def_car", "def_china"), 
         n = ifelse(odds_ratio > 1, def_car, def_china))

top_df

ggplot(top_df, aes(x = word, y = n, fill = category)) + 
  geom_col() + 
  coord_flip() + 
  facet_wrap(~ category, scales = "free") + theme_minimal()

news_sentences <- bind_news %>% 
  as_tibble() %>% 
  unnest_tokens(input = value, 
                output = sentence, 
                token = "sentences")

news_sentences %>% 
  filter(category == "def_car" & str_detect(sentence, "자동차"))


news_sentences %>% 
  filter(category == "def_china" & str_detect(sentence, "중국"))
