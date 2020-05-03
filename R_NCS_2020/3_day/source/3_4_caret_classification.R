# ------------------
# 2일차에 배운 caret을 응용하여 모형을 학습하고 비교합니다.  
# ------------------

#### I. caret 패키지 활용 머신러닝 모형 개발 ####
#### 단계 1. 병렬처리를 위한 패키지 불러오기  ####
library(caret) # 머신러닝을 위한 패키지
library(tidyverse) # 데이터 핸들링 및 시각화를 위한 패키지
library(doParallel) # 병렬처리를 위한 패키지

## 병렬처리
# 주 목적: 속도 때문에 씀
# 원리 및 기타 설명은 다음 링크를 참고한다. 
# https://freshrimpsushi.tistory.com/1266

detectCores() # 현재 자기 컴퓨터의 코어 개수를 반환한다

# 병렬처리에 쓸 코어를 등록한다. 
# 보통 50% 쓰는 것을 추천한다. (이유: 모형이 개발되는 동안 다른 간단한 작업도 해야 함)

cl <- parallel::makeCluster(2, setup_timeout = 0.5)
registerDoParallel(cl)

#### 단계 2. 데이터 가져오기  ####
setwd("~/Documents/R_edu")
loan_data <- read.csv("R_NCS_2020/3_day/data/cleaned_loan_data.csv", stringsAsFactors = FALSE) # 29091 8

#### 단계 3. 데이터 전처리 ####
# 결측치 확인
sapply(loan_data, function(x) sum(is.na(x)))

# 중복값 확인
loan_data %>% duplicated() %>% sum() # 374개 확인
loan_data2 <- loan_data %>% distinct()

# 데이터 타입 확인
glimpse(loan_data)

# 사실 여기부터 모형 개발에 목적에 맞게 기저 범주를 하나씩 설정하며 봐야 하지만. 이 부분은 수강생 분들에게 맡기겠다. 
loan_data2$loan_status <- factor(loan_data2$loan_status, levels = c(0, 1), labels = c("non_default", "default"))
loan_data2$grade <- as.factor(loan_data2$grade)
loan_data2$home_ownership <- as.factor(loan_data2$home_ownership)
# 한꺼번에 하고 싶습니다. 
loan_data2 <- loan_data2 %>% 
  mutate_if(is.character, as.factor)

glimpse(loan_data2)

#### 단계 4. 데이터 분리 ####
set.seed(2018)
inx   <- createDataPartition(loan_data2$loan_status, p = 0.6, list = F)
train <- loan_data2[ inx, ]
test  <- loan_data2[-inx, ]

#### 단계 5. 모형 controler 개발 ####
# caret 패키지의 특징

control <- trainControl(
  method  = "repeatedcv",
  number  = 10, # 10겹
  repeats = 3, # 3번
  search  = "grid",
  classProbs = TRUE)
#summaryFunction = twoClassSummary)

#### 단계 6. 데이터의 통계적인 전처리 ####
# feature engineering
# 각각에 대한 설명은 4일차에 진행함
preProc <- c("BoxCox", 
             "center",
             "scale",
             "spatialSign",
             "corr",
             "zv")

## define x, y
## logistic regression
set.seed(2018)
glimpse(train)

frml <- loan_status ~ loan_amnt + grade + home_ownership + annual_inc + age + emp_cat + ir_cat

#### 단계 7.1. 모형 개발 - 로지스틱회귀 분석 ####
logis <- train(
  frml, 
  data = train, 
  method     = "glm",
  metric     = "Accuracy",
  trControl  = control,
  preProcess = preProc)

logis
# 이전버전 
# saveRDS(logis, "R_NCS_2020/3_day/model/logis_model.rds") Version 3.6.3 까지 적용
save(logis, file = "R_NCS_2020/3_day/model/logis_model.RData")


#### 단계 7.2. 모형 개발 - 의사결정나무 ####
modelLookup("rpart")

# Model Tunning Parameter
# 4일차에 설명 예정
rpartGrid <- expand.grid(cp = c(0.001, 0.01, 0.1))

set.seed(2018)
rpt <- train(
  frml, 
  data = train,
  method     = "rpart",
  metric     = "Accuracy",
  trControl  = control,
  preProcess = preProc,
  tuneGrid   = rpartGrid)

rpt
ggplot(rpt)

save(rpt, file = "R_NCS_2020/3_day/model/rpt_model.RData")
# saveRDS(rpt, "../model/rpt_model.rds")

#### 단계 7.3. 모형 개발 - 랜덤포레스트 ####
modelLookup("rf")

rftGrid <- expand.grid(mtry = c(3, 5, 8)) # sqrt(p)

set.seed(2020)

# system.time은 시간을 재기 위한 것
system.time(
  rft <- train(
    frml, 
    data = train,
    method     = "rf",
    metric     = "Accuracy",
    trControl  = control,
    preProcess = preProc,
    tuneGrid   = rftGrid,
    ntree      = 500)
)

#     user   system  elapsed 
#    29.168    5.071 1465.453 (초) # 24분 소요 (2 core 사용시)

rft
ggplot(rft)

# 랜덤포레스트의 경우 연산이 많아 시간이 오래걸리므로
# 모형을 저장하는 것이 중요함
# saveRDS(rft, "../model/rft_model.rds")
save(rft, file = "R_NCS_2020/3_day/model/rft_model.RData")

#### 단계 7.4. 모형 개발 - GBM(Stochastic Gradient Boosting Model) ####
modelLookup("gbm")

gbmGrid <- expand.grid(n.trees = 500,
                       interaction.depth = 30,
                       shrinkage = c(0.01, 0.1),
                       n.minobsinnode = 30)

set.seed(2020)

# system.time은 시간을 재기 위한 것
system.time(
  gbm <- train(
    frml, 
    data = train,
    method     = "gbm",
    metric     = "Accuracy",
    trControl  = control,
    preProcess = preProc,
    tuneGrid   = gbmGrid,
    verbose    = F)
)

#   user   system  elapsed 
# 83.955    9.091 4949.041 > core 2개 82분 소요 

gbm
ggplot(gbm)

# 부스팅의 경우 연산이 많아 시간이 오래걸리므로
# 모형을 저장하는 것이 중요함
# saveRDS(gbm, "../model/gbm_model.rds")
save(gbm, file = "R_NCS_2020/3_day/model/gbm_model.RData")

#### 단계 7.5. 모형 개발 - avNNet(인공신경망) ####
modelLookup("avNNet")

nnetGrid <- expand.grid(size = c(1, 5, 9),
                        decay = c(0.01, 0.1),
                        bag = F)

maxSize <- max(nnetGrid$size)
numWts <- 10 * (maxSize * (ncol(train) + 1) + 10 + 1)

set.seed(2020)

system.time(
  snn <- train(
    frml, 
    data = train,
    method     = "avNNet",
    metric     = "Accuracy",
    trControl  = control,
    preProcess = preProc,
    tuneGrid   = nnetGrid,
    maxit      = 500,
    linout     = F,
    trace      = F,
    MaxNWts    = numWts)
)

#  user   system  elapsed 
# 5.412    5.445 2014.847 33분

snn
ggplot(snn)

# 인공신경망의 경우 연산이 많아 시간이 오래걸리므로
# 모형을 저장하는 것이 중요함
# saveRDS(snn, "../model/snn_model.rds")
save(snn, file = "R_NCS_2020/3_day/model/snn_model.RData")

#### 단계 8. 모형 정확도 기준비교 ####

# 저장된 모형 가져오기 (R 3.6.3 버전 까지만 허용)
# logis <- readRDS("../model/logis_model.rds")
# rpt <- readRDS("../model/rft_model.rds")
# rft <- readRDS("../model/rft_model.rds")
# gbm <- readRDS("../model/gbm_model.rds")
# snn <- readRDS("../model/snn_model.rds")

# R 4.0.0 이후 버전
load("R_NCS_2020/3_day/model/logis_model.RData")
load("R_NCS_2020/3_day/model/rpt_model.RData")
load("R_NCS_2020/3_day/model/rft_model.RData")
load("R_NCS_2020/3_day/model/gbm_model.RData")
load("R_NCS_2020/3_day/model/snn_model.RData")

## compare models
resamps <- resamples(
  list(glm = logis,
       rpt = rpt,
       rft = rft,
       gbm = gbm,
       snn = snn))

summary(resamps)
bwplot(resamps, layout = c(2, 1))

# Final Model is SNN

# 단계 9. 모형 예측 및 AUC
pred_snn <- predict(snn, test, type = "prob")
pred_snn$loan_status <- ifelse(pred_snn$non_default > 0.85, 0, 1) # cut-off를 조정하며 맞춰보자
pred_snn$loan_status <- factor(pred_snn$loan_status, levels = c(0, 1), labels = c("non_default", "default"))
confusionMatrix(pred_snn$loan_status, test$loan_status, positive = "non_default")

library(ROCR)
pr <- prediction(as.numeric(pred_snn$loan_status) - 1, as.numeric(test$loan_status) - 1)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
abline(0, 1, col = "red")
## -- 
# AUC = Area Under Curve의 뜻으로
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]; auc

# 3_2와 비교해서 어떤 것이 성능이 더 좋은지 확인해보자. 
# preProcessing과 모형 튜닝을 과하게 사용하면 오히려 성능이 더 안좋을 수 있다. 
# 무조건 쓰는 것보다 중요한 것, 왜 써야 하는지에 통계적인 지식이 있지 않으면 오히려 시간대비 성능이 더 떨어질 수 있음을 명심하자! 



