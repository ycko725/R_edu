library(readr)

dic = read_csv("data/knu_sentiment_lexicon.csv")
glimpse(dic)

library(dplyr)
dic %>% 
  filter(polarity == 2) %>% 
  arrange(word)

dic %>% 
  filter(word %in% c("기쁜", "슬픈"))

# 이모티콘
library(stringr)
dic %>% 
  filter(!str_detect(word, "[가-힣]")) %>% 
  arrange(word)

dic %>% 
  mutate(sentiment = ifelse(polarity >= 1, "긍정", 
                            ifelse(polarity <= -1, "부정", "중립")))

test_data <- tibble(
  sentences = c("송길영 부사장님 영상은 꼬박 챙겨보는데 신사임당에도 출연해주셨다니!!!!!!!!!오늘도 영상 잘보고 갑니다!", 
                "내가 없어도 회사가 잘 돌아갈까봐 휴가를 못가는 임원들 ㅋㅋㅋㅋㅋ", 
                "미치겠다,,,, 사람 죽이고 정치 잘했다고라,,, 호남 에서  그런 말을 했다는 것이  어이 없습니다")
)

library(tidytext)
df <- test_data %>% 
  unnest_tokens(input = sentences, 
                output = word, 
                token = "words", 
                drop = F)

df <- df %>% 
  left_join(dic, by = "word") %>% 
  mutate(polarity = ifelse(is.na(polarity), 0, polarity))

df

score_df <- df %>% 
  group_by(sentences) %>% 
  summarise(score = sum(polarity))
score_df

score_df %>% 
  mutate(result = ifelse(score >= 1, "긍정", 
                         ifelse(score <= -1, "부정", "중립")))
