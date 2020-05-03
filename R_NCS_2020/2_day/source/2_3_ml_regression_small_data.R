# ------------------
# 지도학습: 머신러닝 예제
# ------------------

# 기존에 배운 회귀분석은 인과관계를 파악하기 위한 것이었다면, 이번시간부터는 예측모형으로써의 회귀분석을 학습니다. 
# 지도학습을 하는 목적은 크게 두가지가 있습니다. 
# 수치를 예측하는 것, 분류를 예측하는 것
# 이번 시간에는 수치를 예측하는 것에 관한 코드를 작성합니다. 

#### 전통적인 방법 - 단순 회귀 ####
# 데이터 불러오기 
setwd("~/Documents/R_edu")
unemployment <- read.csv("R_NCS_2020/2_day/data/unemployment.csv")

print(unemployment)
summary(unemployment)

# 종속변수 ~ 독립변수, formula 작성
fmla <- female_unemployment ~ male_unemployment
fmla

# 회귀모형 생성
unemployment_lm <- lm(fmla, data = unemployment)

# 모형 출력
unemployment_lm

# 모형 통계량 확인
summary(unemployment_lm)

# 모형 예측하기 (How?), newData 만들기
newData <- data.frame(male_unemployment = 5.3)
# 이 때, 변수명이 unemployment 데이터와 동일해야 함
newData

# 예측 변수 추가 하기
unemployment$predictions <- predict(unemployment_lm)
head(unemployment)

# 시각화를 해보자
library(ggplot2)

ggplot(unemployment, aes(x = predictions, y = female_unemployment)) + 
  geom_point() +
  geom_abline(color = "blue")

# 남자의 실업률 데이터를 근거로 여자의 실업률을 예측해본다.
pred <- predict(unemployment_lm, newdata = newData)

# 결과값 출력
print(pred)

# 데이터셋을 나누지 않음 (왜? 데이터가 작아서)
# 모형이 기본적인 가정을 만족한다면 이 모형을 그대로 사용할 수 있음

#### 전통적인 방법 - 다중 회귀 ####
# 데이터 불러오기
bloodpressure <- read.csv("R_NCS_2020/2_day/data/bloodpressure.csv")
print(bloodpressure)

# 다중회귀 포뮬러 생성
fmla <- blood_pressure ~ age + weight
fmla

# 모형 생성
bloodpressure_lm <- lm(fmla, data = bloodpressure)

# 모형 출력 및 통계량 확인
bloodpressure_lm
summary(bloodpressure_lm)

# 예측 변수 추가 및 시각화
# bloodpressure ~ prediction
bloodpressure$prediction <- predict(bloodpressure_lm)

# 시각화
ggplot(bloodpressure, aes(x = prediction, y = blood_pressure)) + 
  geom_point() +
  geom_abline(color = "blue")

# 예측 데이터 생성 (age + weight)
newData <- data.frame(
  age = 60, 
  weight = 200
)

pred <- predict(bloodpressure_lm, newData)
print(pred)

# 데이터가 없다고 해서 예측을 못하는 건 아닙니다. 
# 데이터가 없는 경우, 원 데이터를 최대한 활용해서 예측을 진행하되, 다만 오차는 크게 발생할 수 있다! 정도로 파악하면 됩니다. 

#### 모형 평가 - 시각화 ####
# Load the package WVPlots
# install.packages("WVPlots")
library(WVPlots)

# 실제값과 예측갑의 차이 = 잔차 = residuals 구하기
# residuals = actual - predict
unemployment$residuals <- unemployment$female_unemployment - unemployment$predictions
GainCurvePlot(unemployment, "predictions", "female_unemployment", "Unemployment model")

# 해석방법은 메뉴얼 참조

#### 모형 평가 - RMSE ####
# 지도학습에서 RMSE를 통해서 모형을 평가한다.
# RMSE 구하는 방법
res <- unemployment$residuals
(rmse <- sqrt(mean(res^2)))

# RMSE는 얼마나 작아야 할까요? 
# RMSE는 직관적으로 실제값의 표준편차보다는 작아야 합니다. 
(sd_unemployment <- sd(unemployment$female_unemployment))

#### 모형 평가 - R-Squared ####
# 예측값을 활용하여 수정계수를 구하는 방법입니다. 
# 수정계수가 1에 가까울수록 좋은 모델입니다. 

# 실제값의 평균
(fe_mean <- mean(unemployment$female_unemployment))

# 분산의 총합 구하기
(tss <- sum((unemployment$female_unemployment - fe_mean)^2))

# 잔차의 총합 구하기
(rss <- sum(unemployment$residuals^2))

# 마지막으로 수정계수 구하기
(rsq <- 1 - (rss / tss))

# install.packages("broom")
library(broom)
(rsq_glance <- glance(unemployment_lm)$r.squared)
  