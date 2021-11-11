# 9.2  YouTube 댓글 수집하기
# 9.2.1  OAuth 권한 연동하기
# install.packages("tuber")
library(tuber)
library(ggplot2)

app_id = "1079765158115-rb2ee67n9oqt78o6leh4gak2k54tn6oe.apps.googleusercontent.com"
app_secret = "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"

yt_oauth(app_id = app_id,
         app_secret = app_secret,
         token = "")

# 9.2.2  YouTube 채널 및 영상 통계 정보 수집ㆍ분석하기
youtuber = data.frame(channel = c("부동산 읽어주는 남자",
                                  "국민은행", 
                                  "신한은행"),
                      channel_id = c("UC2QeHNJFfuQWB4cy3M-745g",
                                     "UCHq8auIJ8ewo7iD2pqX22UA", 
                                     "UC4E394G9WuS9y6SlBZslMsQ"))

# 세 차례 get_channel_stats() 함수를 이용해서 데이터 수집
youtuber_1 = get_channel_stats(channel_id = "UC2QeHNJFfuQWB4cy3M-745g")
yt1_stats = data.frame(channel = "부동산 읽어주는 남자", youtuber_1$statistics)

youtuber_2 = get_channel_stats(channel_id = "UCHq8auIJ8ewo7iD2pqX22UA")
yt2_stats = data.frame(channel = "국민은행", youtuber_2$statistics)

youtuber_3 = get_channel_stats(channel_id = "UC4E394G9WuS9y6SlBZslMsQ")

yt3_stats = data.frame(channel = "신한은행", youtuber_3$statistics)

yt_stats = rbind(yt1_stats, yt2_stats, yt3_stats)
yt_stats

yt_stats = data.frame()
for(i in 1:nrow(youtuber)){
  yt_stat = data.frame(channel = youtuber$channel[i],
                       get_channel_stats(youtuber$channel_id[i])$statistics)
  yt_stats = rbind(yt_stats, yt_stat)
}

yt_stats

# 채널별 전체 시청 수 시각화
ggplot(yt_stats, aes(x = channel, fill = channel)) +
  geom_bar(aes(y = viewCount), stat = "identity") +
  geom_text(aes(label = paste0(format(viewCount, big.mark = ","), " View"),
                y = viewCount), stat = "identity", vjust = -0.5) +
  labs(title = "채널별 전체 시청 수") +
  xlab("") +
  ylab("") +
  theme(text = element_text(size = 15, 
                            family = "AppleGothic"),
        panel.background = element_blank(),
        legend.position = "none",
        axis.ticks = element_blank(),
        axis.text.y = element_blank())

# 채널별 구독자 수 시각화
ggplot(yt_stats, aes(x = channel, fill = channel)) +
  geom_bar(aes(y = subscriberCount), stat = "identity") +
  geom_text(aes(label = paste0(format(subscriberCount,
                                      big.mark = ","), " View"),
                y = subscriberCount), stat = "identity", vjust = -0.5) +
  labs(title = "채널별 구독자 수") +
  xlab("") +
  ylab("") +
  theme(text = element_text(size = 15, 
                            family = "AppleGothic"),
        panel.background = element_blank(),
        legend.position = "none",
        axis.ticks = element_blank(),
        axis.text.y = element_blank())

# 채널별 콘텐츠 수 시각화
ggplot(yt_stats, aes(x = channel, fill = channel)) +
  geom_bar(aes(y = videoCount), stat = "identity") +
  geom_text(aes(label = paste0(format(videoCount,
                                      big.mark = ","), " View"),
                y = videoCount), stat = "identity", vjust = -0.5) +
  labs(title = "채널별 콘텐츠 수") +
  xlab("") +
  ylab("") +
  theme(text = element_text(size = 15, 
                            family = "AppleGothic"),
        panel.background = element_blank(),
        legend.position = "none",
        axis.ticks = element_blank(),
        axis.text.y = element_blank())

# 신사임당 - 부자는 알지만 가난한 사람은 모르는 것 (존리)
cmt_3 = get_all_comments(video_id = "e6Qa05lBdEI")
nrow(cmt_3)

# 데이터 배포
# library(readr)
# write_csv(cmt_3, "data/youtube_comments.csv")


library(readr)

cmt_3 = read_csv("data/youtube_comments.csv")

# 9.3  RcppMeCab 패키지를 이용하여 한글 자연어 처리하기
# 9.3.1  RcppMeCab 패키지 설치하기
# MacOS 참조: https://rpubs.com/Evan_Jung/sentiment_analysisR
library(remotes)
remotes::install_github("junhewk/RcppMeCab")
library(RcppMeCab)

# 9.3.2  RcppMeCab 패키지를 이용하여 형태소 분석하기
sentence = "안녕하세요"
pos(sentence = sentence)

sentence = enc2utf8("안녕하세요")
pos(sentence = sentence)

# 신사임당 인기 콘텐츠 댓글
cmt_pos_3 = posParallel(sentence = cmt_3$textOriginal,
                        format = "data.frame")

head(cmt_pos_3)

cmt_pos_3_cnt = data.frame(table(cmt_pos_3$doc_id))
head(cmt_pos_3_cnt)
summary(cmt_pos_3_cnt$Freq)

# 부자는 알지만 가난한 사람은 모르는 것 (존리)(히스토그램) > 
ggplot(cmt_pos_3_cnt) +
  geom_histogram(aes(Freq), bins = 100, fill = "#7da1d4", color = "white") +
  scale_x_continuous(limits = c(0, 200)) +
  scale_y_continuous(limits = c(0, 150)) +
  labs(title = "부자는 알지만 가난한 사람은 모르는 것 (존리)") + 
  theme(axis.ticks = element_blank(), 
        axis.title = element_blank(), 
        panel.background = element_blank()) 

# 9.5 긍·부정 사전을 이용하여 감성 분석하기
nego = readLines("data/neg_pol_word.txt",
                 encoding = "UTF-8")

posi = readLines("data/pos_pol_word.txt",
                 encoding = "UTF-8")

negoWord = data.frame(keyword = nego,
                      value = -1)

posiWord = data.frame(keyword = posi,
                      value = 1)

# 신사임당 "부자는 알지만 가난한 사람은 모르는 것 (존리)" # 댓글 감성 분석
neg_3 = merge.data.frame(x = cmt_pos_3,
                         y = negoWord,
                         by.x = "token",
                         by.y = "keyword")

pos_3 = merge.data.frame(x = cmt_pos_3,
                         y = posiWord,
                         by.x = "token",
                         by.y = "keyword")

sentiment_3 = rbind(neg_3, pos_3)

score = function(sent){
  sent_sum = aggregate(value ~ doc_id, sent, sum)
  
  for(i in 1:nrow(sent_sum)){
    if(sent_sum$value[i]>0){
      sent_sum$senti[i] = "긍정"
    }else if(sent_sum$value[i]<0){
      sent_sum$senti[i] = "부정"
    }else sent_sum$senti[i] = "중립"
  }
  return(sent_sum)
}

# 신사임당 "부자는 알지만 가난한 사람은 모르는 것 (존리)"
sent_3 = score(sentiment_3)
table(sent_3$senti)

