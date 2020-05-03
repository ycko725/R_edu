# ------------------
# 지도학습: 조금 더 큰 데이터를 가지고 머신러닝 모형을 만듭니다. 
# ------------------

# 동일한 데이터를 가지고, 3가지 버전으로 머신러닝을 수행합니다. 
# 실전에서는 내부망 패키지 설치가 용이하지 않을 수 있기 때문에, 다양한 방법으로 머신러닝을 작업하는 것이 중요합니다. 

#### 방법 1. 기존 방식 ####
#### (1) 패키지 데이터 가져오기 ####
data("mpg", package = "ggplot2")
summary(mpg)
dim(mpg)

#### (2) 데이터 분리 ####
(N <- nrow(mpg)) # 행의 갯수
(target <- round(N * 0.75)) # 전체 데이터에서 75%에 해당하는 행의 갯수
gp <- runif(N) # 랜덤 숫자 가져오기
mpg_train <- mpg[gp < 0.75, ] # gp 기준으로 train 데이터와 test 데이터 분리
mpg_test <- mpg[gp >= 0.75, ]
nrow(mpg_train) # 각 데이터의 관측치 갯수 파악하기 
nrow(mpg_test) # 각 데이터의 관측치 갯수 파악하기

#### (3) 데이터 모형 만들기 ####
# 이때부터는 기존에 학습한 내용과 동일합니다. 
# 회귀모형 포뮬러를 작성합니다. 
dplyr::glimpse(mpg_train) #  변수 참조
(fmla <- cty ~ hwy)

# 회귀모형 생성 
mpg_model <- lm(fmla, data = mpg_train)

# 모형 확인
summary(mpg_model)

#### (4) 모형 평가 함수 만들기 ####
# 변수의 정의
# predcol: 예측값
# ycol: 실제 데이터 관측값

# r_squared 함수
r_squared <- function(predcol, ycol) {
  tss = sum( (ycol - mean(ycol))^2 )
  rss = sum( (predcol - ycol)^2 )
  1 - rss/tss
}

# RMSE 함수
rmse <- function(predcol, ycol) {
  res = predcol-ycol
  sqrt(mean(res^2))
}

# train 데이터에 예측값 추가
mpg_train$pred <- predict(mpg_model)

# test 데이터에 예측값 추가
mpg_test$pred <- predict(mpg_model, newdata = mpg_test)

# rmse 함수 활용하여 train / test rmse 평가
(rmse_train <- rmse(mpg_train$pred, mpg_train$cty))
(rmse_test <- rmse(mpg_test$pred, mpg_test$cty))

# r_squared 함수 활용하여 train / test r_squared 평가
(rsq_train <- r_squared(mpg_train$pred, mpg_train$cty))
(rsq_test <- r_squared(mpg_test$pred, mpg_test$cty))

# 테스트 데이터 예측값과 실제값 그래프 작성
library(ggplot2)
ggplot(mpg_test, aes(x = pred, y = cty)) + 
  geom_point() + 
  geom_abline()


#### (5) 교차 검증 ####
# 교차 검증에는 여러 방법이 있지만, 그 중의 한 방법입니다. 
# 교차검증 패키지 가져오기 
library(vtreat)

# 데이터의 관측치 수 확인
nRows <- nrow(mpg)

# 3겹 검증을 하겠다. 
k <- 3
splitPlan <- kWayCrossValidation(nRows, k, NULL, NULL)

# 3겹의 계획 구조 보기
str(splitPlan)

# 3겹 검증 실시 코드
k <- 3 # 
mpg$pred.cv <- 0 
for(i in 1:k) {
  split <- splitPlan[[i]]
  model <- lm(cty ~ hwy, data = mpg[split$train, ])
  mpg$pred.cv[split$app] <- predict(model, newdata = mpg[split$app, ])
}

# 모형을 통한 예측
mpg$pred <- predict(lm(cty ~ hwy, data = mpg))

# 모형 평가 
rmse(mpg$pred, mpg$cty)

# 교차검증 코드 결과
rmse(mpg$pred.cv, mpg$cty)

# 위 코드에서 기억해야 하는 것은, 코드의 양과 절차가 쉬운지 아닌지를 적정하게 판단해야 합니다. 

#### 방법 2. Caret ####
# Caret에 대한 설명은 교재참조
library(caret)

#### (1) 패키지 데이터 가져오기 ####
data("mpg", package = "ggplot2")
summary(mpg)
dim(mpg)

#
#### (2) 데이터 분리 #### 
inTrain <- createDataPartition(y = mpg$cty, p=0.75, list = FALSE)
train_mpg <- mpg[inTrain,]
test_mpg  <- mpg[-inTrain,]
dim(train_mpg)

#### (3) 모형 생성 #### 
# 기존 방식에 사용했던 formula와 동일하게 사용합니다. 
(fmla <- cty ~ hwy + displ)
model <- train(fmla,
               data = train_mpg,
               method = "lm")

print(model)

# 위 모형을 출력하면, 모형 평가가 자동으로 탑재된 것을 확인할 수 있습니다.  
# 모형 평가에 대한 해석만 알고 있으면 보다 쉽게 모형을 비교할 수 있습니다. 

#### (4) 교차 검증 ####
# caret의 유용성은 소스코드를 획기적으로 줄여줍니다. 
# 아래 코드를 살펴보자. 
# trainControl 함수에서 교차 검증을 조절할 수 있도록 디자인 할 수 있다. 
fitControl <- trainControl(method = "cv",   
                           number = 3)     # number of folds
                           
model.cv <- train(fmla,
                  data = train_mpg,
                  method = "lm",  # 회귀
                  trControl = fitControl)  

model.cv

# train 데이터에 예측값 추가
train_mpg$pred <- predict(model.cv)

# test 데이터에 예측값 추가
test_mpg$pred <- predict(model.cv, newdata = test_mpg)

# rmse 함수 활용하여 train / test rmse 평가
(rmse_train_caret <- rmse(train_mpg$pred, train_mpg$cty))
(rmse_test_caret <- rmse(test_mpg$pred, test_mpg$cty))

# r_squared 함수 활용하여 train / test r_squared 평가
(rsq_train <- r_squared(train_mpg$pred, train_mpg$cty))
(rsq_test <- r_squared(test_mpg$pred, test_mpg$cty))

#### 고려사항 ####
# 수치형 데이터를 예측하는 것은 회귀 모형말고도 많이 있습니다.
# 예) Tree, Random Forest, Lasso 등
# 기존 방식대로 추가할 것인지, 아니면 caret과 같은 패키지를 사용할 것인지 판단해야 합니다. 
# 이러한 각각의 모형, 그리고 추가되는 모형을 일일이 공부하면서 대응할 수 없습니다. 
# 기존의 모형 알고리즘에 가볍게 추가해서 빠르게 성능을 비교하는 것을 추천합니다. 
# Caret이 현재 보유하고 있는 알고리즘입니다. 
names(getModelInfo())
# lasso, ranger 추가해서 모형 만들어보기

# fitControl은 고정합니다. 
fitControl <- trainControl(method = "cv",   
                           number = 10)  # number of folds
summary(train_mpg)
# 아래는 기존 모형입니다. 
(fmla <- cty ~ hwy + displ)

model.cv <- train(fmla,
                  data = train_mpg,
                  method = "lm",  # 선형 회귀
                  trControl = fitControl)


lasso_cv <- train(fmla, data = train_mpg, method = "lasso", trControl = fitControl)
ranger_cv <- train(fmla, data = train_mpg, method = "ranger", trControl = fitControl)

#### Caret 모형 비교 ####
# 이렇게 만든 모형에 대해 비교하여 최종적인 모형을 선택할 수 있습니다. 
results <- resamples(list(lm = model.cv, lasso = lasso_cv, randomForest = ranger_cv))

# 모형 요약
summary(results)

# 모형 비교 - 박스 플롯
bwplot(results, metric = c("RMSE", "Rsquared"))

# 모형 비교 - dot 플롯
dotplot(results, metric = c("RMSE", "Rsquared"))

# 위 그래프를 통해 연구자는 모형을 선택할 수 있습니다. 

# End of Document
