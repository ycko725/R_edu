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

idx = sample(1:nrow(raw_reviews), nrow(raw_reviews) * 0.2, replace = FALSE)
raw_reviews = raw_reviews[idx, ]

raw_reviews %>% 
  mutate(pos_binary = ifelse(Liked > 0, 1, 0)) %>% # 이산형 변수로 변환
  select(Liked, pos_binary) -> pos_binary_df

pos_binary_df$pos_binary <- as.factor(pos_binary_df$pos_binary)

# 0과 1 비교
summary(as.factor(pos_binary_df$pos_binary))

# ---- 키워드 점수 계산 위한 데이터셋 생성
# 텍스트 데이터 추출
REVIEW_TEXT = as.character(raw_reviews$Review)
REVIEW_TEXT = tolower(REVIEW_TEXT)

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

DTM_Token = DocumentTermMatrix(Corpus_tm_token)
DTM_Matrix_Token = as.matrix(DTM_Token)

# 상위 키워드 추출
# - quantile() 함수 활용
top_1_pnt_words = colSums(DTM_Matrix_Token) > quantile(colSums(DTM_Matrix_Token), probs = 0.99)

DTM_Matrix_Token_selected = DTM_Matrix_Token[, top_1_pnt_words]
ncol(DTM_Matrix_Token_selected)

DTM_df = as.data.frame(DTM_Matrix_Token_selected)
pos_final_df = cbind(pos_binary_df, DTM_df)

pos_final_df

# ---- 훈련 검증용 데이터 분류
set.seed(1234)
idx = sample(1:nrow(pos_final_df), nrow(pos_df) * 0.7, replace = FALSE)
train = pos_final_df[idx, ]
test = pos_final_df[-idx, ]

# ---- 변수 선택법에 의한 모형 개발 ----
glimpse(train)

# 로지스틱 회귀 모형 개발 시간 측정
Start_Time = Sys.time()

glm_model = step(glm(pos_binary  ~ ., data = train[,-1],
               family = binomial(link = "logit")),direction = "backward")

End_Time = Sys.time()

difftime(End_Time,Start_Time, unit = "secs")

summary(glm_model)

# ---- 모형 성능 측정 ----
# install.packages("pROC")
library(pROC)
preds = predict(glm_model, newdata = test, type = 'response')
roc_glm = roc(test$pos_binary, preds)
plot.roc(roc_glm, print.auc = TRUE)
