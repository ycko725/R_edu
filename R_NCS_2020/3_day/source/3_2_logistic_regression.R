# ------------------
# 로지스틱 회귀분석 - 기본 원리
# ------------------

# 로지스틱 회귀분석은 회귀분석의 선형성 가정이 위반되었다는 것에서 출발합니다. 
# 종속변수가 범주형이면 선형성 가정이 위반됩니다. 
# 이러한 문제를 피하기 위해서는 로그변환을 합니다. 
# 로짓변환: 로그변환을 하는 이유는 비선형 관계를 선형관계로 바꾸어 선형성 가정이 위반 된 것을 보완하기 위함입니다. 
# 최대우도추정: 결과변수의 값을 잘 추정할 수 있는 매개변수를 찾아야 하는데, 이 때 필요한 기법이 최대우도추정이다. 관측값이 발생할 가장 큰 계수를 찾는다는 뜻. 

# 로지스틱 회귀분석의 특징은 다음과 같습니다. 
# 분석목적: 종속변수와 독립변수 간의 관계를 통해서 예측 모델을 생성합니다. 
# 회귀분석과의 차이점: 종속변수는 반드시 범주형 변수이어야 합니다. 
# 이항형: Yes/No, 다항형: 예) Iris의 Species 칼럼
# 정규성: 정규분포 대신에 이항분포를 따릅니다. 
# 로짓변환: 종속변수의 출력범위를 0과 1로 조정하는 과정을 의미합니다. 
#### I. 이항분류 기존 방식 #### 
#### 단계 1. 데이터 가져오기 ####
setwd("~/Documents/R_edu")
loan_data <- read.csv("R_NCS_2020/3_day/data/cleaned_loan_data.csv", stringsAsFactors = FALSE)

head(loan_data)
str(loan_data)

# 데이터 변환의 이유, 1, 0은 숫자가 아니다. 범주형이다. 
loan_data$loan_status <- as.factor(loan_data$loan_status)


#### 단계 2. 데이터 분리 ####
library(caret)

inTrain <- createDataPartition(y = loan_data$loan_status, p=0.6, list = FALSE)
train_loan <- loan_data[inTrain,]
test_loan  <- loan_data[-inTrain,]
dim(train_loan)

#### 단계 3. 모형 개발 #### 
options(scipen = 100)
null_modle <- glm(loan_status ~ 1, family = "binomial", data = loan_data)
log_model <- glm(loan_status ~ loan_amnt + grade, family = "binomial", data = loan_data)

summary(log_model)

# 카이제곱 통계량 및 유의확률 구하기
anova(null_modle, log_model, test = "Chisq")

# 승산비 구하는 법
t(exp(log_model$coefficients))

# 신뢰구간 구하기
exp(confint(log_model))

# glm은 F 검정 통계량과 모델의 설명력은 제공되지 않는다. 
# glm 모형 성능에 관한 내용은, 이탈도, 로그가능도, R 통계량, 왈드 통계량, 호스머-렘쇼 측도, AIC 정보기준 (아카이케), 승산비 등이 있다. 
# 위 개념에 대한 기본적인 설명은 교재를 참고한다. 
# 지나치게 통계 이론으로 갈 여지가 있어서, 이 부분은 추후 통계 과정을 통해서 학습하는 것을 권한다. 
# 본 수업은 지도학습에 대한 머신러닝 과정이다.  
# 혼동 행렬에 대한 기본 개념을 익힘으로써, 분류문제에 관한 모형 평가를 더 자세히 공부할 수 있기 때문이다. 
# 만약 자세히 공부하기 원한다면 유쾌한 The R Book에서 관련 내용을 공부하시기를 권면한다. 

#### 단계 4. 모형 예측 ####
pred <- predict(log_model, newdata = test_loan, type = "response")
# type = "response" 속성은 예측 결과를 0~1사이의 확률값으로 반환한다. 
#### 단계 5. 예측치를 이항형으로 변환 ####
# 예측치가 0.15 이상이면 1, 0.15 미만이면 0
# 일단, 0.15인지는 메뉴얼 참조
result_pred <- ifelse(pred > 0.15, 1, 0)

#### 단계 6. 분류 정확도 계산 ####
table(test_loan$loan_status, result_pred)

#### 단계 7. 분류 정확도 계산 ####
# 혼동 매트릭스에 대한 설명은 교재 참조
# 정확도 계산
(5065 + 321) / (5065 + 321 + 1401 + 485)

#### 단계 8. ROC Curve를 이용한 모델 평가 & AUC ####
library(ROCR)
par(mfrow = c(1,1))
pr <- prediction(pred, test_loan$loan_status)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
abline(0, 1, col = "red")
## -- 
# AUC = Area Under Curve의 뜻으로
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]; auc

