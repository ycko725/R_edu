# 03-1 --------------------------------------------------------------------

library(dplyr)

# 요소수 문제 관련 - 자동차
# 참조: https://vip.mk.co.kr/newSt/news/news_view.php?p_page=&sCode=21&t_uid=20&c_uid=1915688&topGubun=
def_car <- readLines("data/def_news_car.txt", encoding = "UTF-8")
car <- def_car %>%
  as_tibble() %>%
  mutate(category = "def_car")

# 요소수 문제 관련 - 중국
# 참조: https://vip.mk.co.kr/newSt/news/news_view.php?p_page=&sCode=21&t_uid=20&c_uid=1915668&topGubun=
def_china <- readLines("data/def_news_china.txt", encoding = "UTF-8")
china <- def_china %>%
  as_tibble() %>%
  mutate(category = "def_china")

# -------------------------------------------------------------------------
bind_news <- bind_rows(car, china) %>%
  select(category, value)

head(bind_news)
tail(bind_news)


# -------------------------------------------------------------------------
# 기본적인 전처리
library(stringr)
news_df <- bind_news %>%
  mutate(value = str_replace_all(value, "[^가-힣]", " "),
         value = str_squish(value))

news_df


# 토큰화
library(tidytext)
library(KoNLP)

news_df <- news_df %>%
  unnest_tokens(input = value,
                output = word,
                token = extractNoun)
news_df


# -------------------------------------------------------------------------
df <- tibble(class = c("a", "a", "a", "b", "b", "b"),
             sex = c("female", "male", "female", "male", "male", "female"))
df

df %>% count(class, sex)


# -------------------------------------------------------------------------
frequency <- news_df %>%
  count(category, word) %>%   # 연설문 및 단어별 빈도
  filter(str_count(word) > 1)  # 두 글자 이상 추출

head(frequency)


# -------------------------------------------------------------------------
df <- tibble(x = c(1:100))
df

df %>% slice_max(x, n = 3)


# -------------------------------------------------------------------------
top10 <- frequency %>%
  group_by(category) %>%  # category 분리
  slice_max(n, n = 10)     # 상위 10개 추출

top10


# -------------------------------------------------------------------------
top10 %>%
  filter(category == "def_china")


# -------------------------------------------------------------------------
df <- tibble(x = c("A", "B", "C", "D"), y = c(4, 3, 2, 2))

df %>% 
  slice_max(y, n = 3)

df %>% 
  slice_max(y, n = 3, with_ties = F)


# -------------------------------------------------------------------------
top10 <- frequency %>%
  group_by(category) %>%
  slice_max(n, n = 10, with_ties = F)

top10


# -------------------------------------------------------------------------
library(ggplot2)
ggplot(top10, aes(x = reorder(word, n),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category)


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder(word, n),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category,         # president별 그래프 생성
              scales = "free_y")  # y축 통일하지 않음


# -------------------------------------------------------------------------
top10 <- frequency %>%
  filter(word != "요소") %>%
  group_by(category) %>%
  slice_max(n, n = 10, with_ties = F)

top10


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder(word, n),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category, scales = "free_y")


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder_within(word, n, category),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category, scales = "free_y")


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder_within(word, n, category),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category, scales = "free_y") +
  scale_x_reordered() +
  labs(x = NULL) +                                    # x축 삭제
  theme(text = element_text(family = "nanumgothic"))  # 폰트


# 03-2 --------------------------------------------------------------------
df_long <- frequency %>%
  group_by(category) %>%
  slice_max(n, n = 10) %>%
  filter(word %in% c("가격", "수입", "공급망", "관세"))

df_long


# -------------------------------------------------------------------------
install.packages("tidyr")
library(tidyr)

df_wide <- df_long %>%
  pivot_wider(names_from = category,
              values_from = n)

df_wide


# -------------------------------------------------------------------------
df_wide <- df_long %>%
  pivot_wider(names_from = category,
              values_from = n,
              values_fill = list(n = 0))

df_wide


# -------------------------------------------------------------------------
frequency_wide <- frequency %>%
  pivot_wider(names_from = category,
              values_from = n,
              values_fill = list(n = 0))
 
frequency_wide


# -------------------------------------------------------------------------
frequency_wide <- frequency_wide %>%
  mutate(ratio_car = ((def_car + 1)/(sum(def_car + 1))),  # def_car 단어의 비중
         ratio_china = ((def_china + 1)/(sum(def_china + 1))))  # def_china 에서 단어의 비중

frequency_wide


# -------------------------------------------------------------------------
frequency_wide <- frequency_wide %>%
  mutate(odds_ratio = ratio_car/ratio_china)

frequency_wide %>%
  arrange(-odds_ratio)

frequency_wide %>%
  arrange(odds_ratio)


# -------------------------------------------------------------------------
frequency_wide <- frequency_wide %>%
  mutate(ratio_car  = ((def_car + 1)/(sum(def_car + 1))),
         ratio_china  = ((def_china + 1)/(sum(def_china + 1))),
         odds_ratio = ratio_car/ratio_china)


# -------------------------------------------------------------------------
frequency_wide <- frequency_wide %>%
  mutate(odds_ratio = ((def_car + 1)/(sum(def_car + 1)))/
                      ((def_china + 1)/(sum(def_china + 1))))


# -------------------------------------------------------------------------
top10 <- frequency_wide %>%
  filter(rank(odds_ratio) <= 10 | rank(-odds_ratio) <= 10)

top10 %>%
  arrange(-odds_ratio)


# -------------------------------------------------------------------------
df <- tibble(x = c(2, 5, 10))
df %>% mutate(y = rank(x))     # 값이 작을수록 앞순위
df %>% mutate(y = rank(-x))    # 값이 클수록 앞순위


# -------------------------------------------------------------------------
top10 <- top10 %>%
  mutate(category = ifelse(odds_ratio > 1, "def_car", "def_china"),
         n = ifelse(odds_ratio > 1, def_car, def_china))

top10


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder_within(word, n, category),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category, scales = "free_y") +
  scale_x_reordered()


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder_within(word, n, category),
                  y = n,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ category, scales = "free") +
  scale_x_reordered() +
  labs(x = NULL) +                                    # x축 삭제
  theme(text = element_text(family = "nanumgothic"))  # 폰트


# -------------------------------------------------------------------------
speeches_sentence <- bind_news %>%
  as_tibble() %>%
  unnest_tokens(input = value,
                output = sentence,
                token = "sentences")

head(speeches_sentence)
tail(speeches_sentence)


# -------------------------------------------------------------------------
speeches_sentence %>%
  filter(category == "def_car" & str_detect(sentence, "자동차"))


# -------------------------------------------------------------------------
speeches_sentence %>%
  filter(category == "def_china" & str_detect(sentence, "중국"))


# -------------------------------------------------------------------------
frequency_wide %>%
  arrange(abs(1 - odds_ratio)) %>%
  head(10)


# -------------------------------------------------------------------------
frequency_wide %>%
  filter(def_car >= 2 & def_china >= 2) %>%
  arrange(abs(1 - odds_ratio)) %>%
  head(10)


# 03-3 --------------------------------------------------------------------
frequency_wide <- frequency_wide %>%
  mutate(log_odds_ratio = log(odds_ratio))


# -------------------------------------------------------------------------
# def_car에서 비중이 큰 단어
frequency_wide %>%
  arrange(-log_odds_ratio)

# def_china에서 비중이 큰 단어
frequency_wide %>%
  arrange(log_odds_ratio)

# 비중이 비슷한 단어
frequency_wide %>%
  arrange(abs(log_odds_ratio))


# -------------------------------------------------------------------------
frequency_wide <- frequency_wide %>%
  mutate(log_odds_ratio = log(((def_car + 1) / (sum(def_car + 1))) /
                              ((def_china + 1) / (sum(def_china + 1)))))


# -------------------------------------------------------------------------
top10 <- frequency_wide %>%
  group_by(category = ifelse(log_odds_ratio > 0, "def_car", "def_china")) %>%
  slice_max(abs(log_odds_ratio), n = 10, with_ties = F)


top10 %>% 
  arrange(-log_odds_ratio) %>% 
  select(word, log_odds_ratio, category)


# -------------------------------------------------------------------------
ggplot(top10, aes(x = reorder(word, log_odds_ratio),
                  y = log_odds_ratio,
                  fill = category)) +
  geom_col() +
  coord_flip() +
  labs(x = NULL) +
  theme(text = element_text(family = "nanumgothic")) + 
  theme_minimal()




