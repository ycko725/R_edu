# ---- 데이터 불러오기 ---- 
library(ggplot2)
library(dplyr)
library(reshape)
library(readr)

raw_reviews = read_csv("data/Womens Clothing E-Commerce Reviews.csv") %>% select(-1)

glimpse(raw_reviews)

colnames(raw_reviews) <- c('ID', 'Age', 'Title', 'Review', 'Rating', 'Recommend', 'Liked', 'Division', 'Dept', 'Class')

glimpse(raw_reviews)

# age는 리뷰를 작성한 고객의 연령
# Title, Review Text 변수: 리뷰의 제목과 내용
# Rating: 고객이 부여한 평점
# Recommend IND: 추천 여부
# Positive Feedback Count: 좋아요 수치
# Division Name, Department Name, Class Name, 상품의 대분류 소분류 정보

# ---- 데이터 전처리 ----
# NA values 확인
colSums(is.na(raw_reviews))

# 연속형 변수의 범주화 - cut()
age_group = cut(as.numeric(raw_reviews$Age), 
                breaks = seq(10, 100, by = 10), 
                include.lowest = TRUE, 
                right = FALSE, 
                labels = paste0(seq(10, 90, by = 10), "th"))

age_group[1:10]

# 변수 추가
raw_reviews$age_group = age_group
table(raw_reviews$age_group)

# EDA 
ggplot(data.frame(prop.table(table(raw_reviews$Dept))), aes(x=Var1, y = Freq*100)) + 
  geom_bar(stat = 'identity') + 
  xlab('Department Name') + 
  ylab('Percentage of Reviews/Ratings (%)') + 
  geom_text(aes(label=round(Freq*100,2)), vjust=-0.25) + 
  theme_minimal()

# ---- 감성 사전 데이터 셋 변환 ---- 
glimpse(raw_reviews)
raw_reviews %>% 
  mutate(pos_binary = ifelse(Liked > 0, 1, 0)) %>% # 이산형 변수로 변환
  select(Liked, pos_binary) -> pos_binary_df

idx = sample(1:nrow(raw_reviews), nrow(raw_reviews) * 0.1, replace = FALSE)
pos_df = pos_binary_df[idx, ]

# 0과 1 비교
summary(as.factor(pos_df$pos_binary))

# ---- 키워드 점수 계산 위한 데이터셋 생성
# 텍스트 데이터 추출
REVIEW_TEXT = as.character(reviews$Review)

TEXT_Token = c()
for(i in 1:length(REVIEW_TEXT)) {
  token_words = unlist(tokenize_word_stems(REVIEW_TEXT[i]))
  
  Sentence = ""
  
  for (tw in token_words) {
    Sentence = paste(Sentence, tw)
  }
  
  TEXT_Token[i] = Sentence
}

# ---- Text 
Corpus_token = Corpus(VectorSource(TEXT_Token))
Corpus_tm_token = tm_map(Corpus_token, removePunctuation)
Corpus_tm_token = tm_map(Corpus_token, removeNumbers)
Corpus_tm_token = tm_map(Corpus_token, removeWords, c(stopwords("english")))

TDM_Token = TermDocumentMatrix(Corpus_tm_token)
TDM_Matrix_Token = as.matrix(TDM_Token)

# 상위 키워드 추출
# - quantile() 함수를 