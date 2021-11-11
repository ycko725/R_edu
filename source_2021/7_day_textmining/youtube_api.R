library(ggplot2)
library(readr)
library(dplyr)

cmt_3 = read_csv("data/youtube_comments.csv")

# RcppMeCab
library(RcppMeCab)

# 테스트
text = "안녕하세요!"
pos(sentence = text)
# $`�ȳ\xe7\xc7ϼ��\xe4!`
# [1] "�/SY"           "ȳ/SL"            "\xe7\xc7\xcf/SH" "���\xe4/SY"  
# [5] "!/SF" 
text2 = enc2utf8(text)

pos(sentence = text2)
# $`안녕하세요!`
# [1] "안녕/NNG"   "하/XSV"     "세요/EP+EF" "!/SF"

glimpse(cmt_3)

cmt_pos_3 = posParallel(sentence = cmt_3$textOriginal, 
                        format = "data.frame")

glimpse(cmt_pos_3)
head(cmt_pos_3)

cmt_pos_3_cnt = data.frame(table(cmt_pos_3$doc_id))
head(cmt_pos_3_cnt)
summary(cmt_pos_3_cnt$Freq)

ggplot(cmt_pos_3_cnt) + 
  geom_histogram(aes(Freq), bins = 100, fill = "blue", color = "white") +
  scale_x_continuous(limits = c(0, 200)) + 
  scale_y_continuous(limits = c(0, 150)) + 
  theme_minimal()

# 감정, 부정 사전을 이용하여 감성 분석하기
nego = readLines("data/neg_pol_word.txt", encoding = "UTF-8")
posi = readLines("data/pos_pol_word.txt", encoding = "UTF-8")

negoWord = data.frame(keyword = nego, value = -1)
glimpse(negoWord)

posiWord = data.frame(keyword = posi, value = 1)
glimpse(posiWord)

neg_3 = merge.data.frame(x = cmt_pos_3, 
                         y = negoWord, 
                         by.x = "token", 
                         by.y = "keyword")
neg_3

pos_3 = merge.data.frame(x = cmt_pos_3, 
                         y = posiWord, 
                         by.x = "token", 
                         by.y = "keyword")

pos_3
glimpse(pos_3)

sentiment_3 = rbind(neg_3, pos_3)

# score 함수
# ---> 긍정, 부정, 중립으로 나누는 함수
score = function(data) {
  sent_sum = aggregate(value ~ doc_id, data, sum)
  
  for(i in 1:nrow(sent_sum)) {
    if(sent_sum$value[i] > 0) {
      sent_sum$senti[i] = "긍정"
    } else if(sent_sum$value[i] < 0) {
      sent_sum$senti[i] = "부정"
    } else sent_sum$senti[i] = "중립"
  }
  return(sent_sum)
}

sent_3 = score(sentiment_3)
glimpse(sent_3)
table(sent_3$senti)
