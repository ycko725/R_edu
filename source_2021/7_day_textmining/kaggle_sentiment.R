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

# ---- 텍스트 전처리 방법 ----
# 텍스트 데이터 10%만 추출
set.seed(2021)
# install.packages("tm")
library(tm)

idx = sample(1:nrow(raw_reviews), nrow(raw_reviews) * 0.1, replace = FALSE)

reviews = raw_reviews[idx, ]

# 이산형 변수로 만들기
reviews %>% 
  mutate(pos_binary = ifelse(Liked > 0, 1, 0)) %>% 
  select(Liked, pos_binary) -> pos_binary_df

glimpse(raw_reviews)

# pos_binary_df %>% head(20)
pos_binary_df$pos_binary <- as.factor(pos_binary_df$pos_binary)
summary(pos_binary_df$pos_binary)

# ---- 키워드 점수 계산 데이터 셋 생성 

# 텍스트 데이터 추출
REVIEW_TEXT = as.character(reviews$Review)

# 텍스트 데이터 소문자
TEXT_lower = tolower(REVIEW_TEXT)

# 토큰나이징 변환
library(tokenizers)

TEXT_Token = c()
for(i in 1:length(TEXT_lower)) {
  token_words = unlist(tokenize_word_stems(TEXT_lower[i]))
  
  Sentence = ""
  
  for (tw in token_words) {
    Sentence = paste(Sentence, tw)
  }
  
  TEXT_Token[i] = Sentence
}

# Text 
Corpus_token = Corpus(VectorSource(TEXT_Token))
Corpus_tm_token = tm_map(Corpus_token, removePunctuation)
Corpus_tm_token = tm_map(Corpus_tm_token, removeNumbers)
Corpus_tm_token = tm_map(Corpus_tm_token, removeWords, c(stopwords("english")))

DTM_token = DocumentTermMatrix(Corpus_tm_token)
DTM_Matrix_Token = as.matrix(DTM_token)

top_1_pnt_words = colSums(DTM_Matrix_Token) > quantile(colSums(DTM_Matrix_Token), probs = 0.99)

DTM_Matrix_Token_selected = DTM_Matrix_Token[, top_1_pnt_words]
DTM_Matrix_Token_selected

DTM_df = as.data.frame(DTM_Matrix_Token_selected)
nrow(DTM_df)
nrow(pos_binary_df)

pos_final_df = cbind(pos_binary_df, DTM_df)
pos_final_df

# ---- 훈련 검증용 데이터 분류 
set.seed(12134)

idx = sample(1:nrow(pos_final_df), nrow(pos_final_df) * 0.7, replace = FALSE)
train = pos_final_df[idx, ]
test = pos_final_df[-idx, ]

# 로지스틱 회귀분석 - 변수 선택법
# AIC 값!! 
glimpse(train)

start_time = Sys.time()
glm_model = step(glm(pos_binary ~ ., data = train[, -1]
                     , family = binomial(link = "logit")), direction = "backward")

end_time = Sys.time()
difftime(end_time, start_time, unit = "secs")

summary(glm_model)

# 모형 성능 측정
library(pROC)
preds = predict(glm_model, newdata = test, type = "response")
roc_glm = roc(test$pos_binary, preds)
plot.roc(roc_glm, print.auc = TRUE)
