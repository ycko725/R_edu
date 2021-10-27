# ------------------
# 모형의 예측변수의 값을 보정하는 방법에 대해 배웁니다. 
# ------------------

# 파라미터 조정은 알고리즘에 대한 이해도와 관련이 있다. 
# 첫번째 시간에 강조했듯이, 모든 알고리즘에 대한 이해를 할 수는 없습니다. 
# 또한 논문을 처음부터 끝까지 다 읽을수는 없습니다. 
# R의 강점은 각 알고리즘 설명에 관한 논문을 쉽게 찾을 수 있는 강점이 있고, 
# 각 논문에서 필요한 영역에 대해 20-30분의 스터디를 통해서 빠르게 파라미터 값 조정의 의미를 파악해야 합니다. 
# 그 방법이 강사가 했던 방법 중 가장 효율적이었습니다. 
# 강사가 공부하는 방법은 다음과 같습니다. 
library(randomForest)
?randomForest
# References
# Breiman, L. (2001), Random Forests, Machine Learning 45(1), 5-32.
# Breiman, L (2002), “Manual On Setting Up, Using, And Understanding Random Forests V3.1”, https://www.stat.berkeley.edu/~breiman/Using_random_forests_V3.1.pdf.

# R은 특히 통계 기법이나 머신러닝 알고리즘에 대해 이와 같이 Reference를 제공합니다. 
# 논문이나 메뉴얼을 읽고 어떻게 적용할 것인지 그때마다 처리하는 것이 중요합니다. 

# 이제 기존의 방식인 랜덤포레스트에서 파라미터를 조정하는 것과 # caret 패키지에서 파라미터를 조정하는 것의 차이를 알려드립니다. 
# 랜덤포레스트에 대한 기본 설명은 교재를 참조하시기를 바랍니다. 
# 부스팅과 배깅의 차이점은 교재를 통해 배우기를 바라며, 유투브를 통해서 학습하시는 걸 권장합니다. 
# 훨씬 쉽게 설명이 잘 되어 있습니다. 

#### I. 기존 방식 ####
# 부동산 가격 예측 알고리즘 만들어 보자
data("Boston", package = "MASS")
glimpse(Boston)

# 패키지 로드
library(randomForest)
library(caret)

# 데이터 분리
set.seed(2020)
inx      <- createDataPartition(Boston$medv, p = 0.6, list = F)
training <- Boston[ inx, ]
testing  <- Boston[-inx, ]

# 모형 생성
model.01 <- randomForest(medv ~., data = training)
model.01

# Number of trees: 500개 복원 추출 방식 사용
# No. of variables tried at each split: 4
# 4개의 변수를 이용하여 자식 노드가 분류되었다. 
# 평균 제곱 오차 MSE (mean of squared residuals) = 11.96
# MSE가 적을 수록 좋은 모형
# 분산 설명률 85.28

#### (1) 파라미터 조정 ####
# 랜덤 포레스트의 수를 300개 변수를 8개로 늘려보자
model.02 <- randomForest(medv ~., data = training, ntree = 300, mtry = 8)
model.02

# 평균 제곱 오차 MSE (mean of squared residuals) = 10.94007
# 분산 설명률 86.54

#### (2) 중요변수 확인 ####
# 이 알고리즘에는 중요 변수를 확인할 수 있도록 도와준다. 
model.03 <- randomForest(medv ~., data = training, ntree = 300, mtry = 8, importance = T)

varImp(model.03) 
varImpPlot(model.03)

# MSE를 개선하는데 기여하는 변수를 수치로 제공함
# NodePurity는 노드 불순도를 개선하는데 기여한 변수를 수치로 제공함

# 회귀의 경우 MSE / NodePurity가 중요지표로 나오고, 로지스틱 회귀의 경우 Mean Decrease Accurary / Mean Decrease Gini로 나옴. 

#### (3) 최적의 파라미터 구하기 ####
#최적의 파라미터값 구하기 (ntree, mtry)
ntree <- c(300,400,500)
mtry  <- c(4, 6, 8)
param_df <- data.frame(n=ntree,m=mtry)
param_df

# for문으로 돌림
for (i in param_df$n) {
  cat('ntree = ' ,i,'\n')
  for (j in param_df$m) {
    cat('mtry = ' ,j,'\n')
    model <- randomForest(medv~.,data = training, ntree=i, mtry=j)
    print(model)
  }
}

# 이렇게 하면 안됩니다. 직관적인 비교가 어렵습니다.
# 모두 삭제 한다. 
rm(list = ls())

#### II. caret 방식 ####
# caret 패키지 등을 사용하는 이유는 모형 생성 및 파라미터 튜닝을 보다 쉽고 간결하게 하기 위함입니다. 
# 부동산 가격 예측 알고리즘 만들어 보자
data("Boston", package = "MASS")
glimpse(Boston)

# 패키지 로드
library(randomForest)
library(caret)
library(tidyverse)
library(doParallel) # 병렬처리를 위한 패키지

detectCores() # 현재 자기 컴퓨터의 코어 개수를 반환한다

cl <- parallel::makeCluster(2, setup_timeout = 0.5)
registerDoParallel(cl)

# 데이터 분리
set.seed(2020)
inx      <- createDataPartition(Boston$medv, p = 0.6, list = F)
training <- Boston[ inx, ]
testing  <- Boston[-inx, ]

# 재현성 위해 
set.seed(123)

# 기본모형
model.01 <- train(
  medv ~ .,
  method  = "rf", 
  data    = training
)

model.01
ggplot(model.01) + theme_minimal()
# 위그래프를 통해서 최적의 mtry를 확인할 수 있다. 

#### (1) 파라미터 튜닝 방식 - Random Search ####
modelLookup("rf")

# mtry 개수는 다음과 같이 분류합니다. 
# 회귀와 분류가 조금 다릅니다. 
# 회귀의 경우 변수 총 갯수 / 3 
# sqrt(ncol(x))

mtry <- ceiling(ncol(training) / 3)
control <- trainControl(search = 'random')

model.02 <- train(medv ~ .,
                  method   = "rf", 
                  data     = training, 
                  tuneLength = mtry, # 5
                  trControl = control
                  )
model.02
plot(model.02)
# 7이 가장 낮음

#### (2) 파라미터 튜닝 방식 - Grid Search ####
control <- trainControl(search="grid")

set.seed(1234)
mtry <- ceiling(ncol(training) / 3)
tunegrid <- expand.grid(.mtry=c(1:mtry))
tunegrid2 <- expand.grid(.mtry=c(4:9))

model.03 <- train(medv ~ .,
                  method   = "rf", 
                  data     = training, 
                  # tuneLength = mtry, # 5 (random search 때 사용)
                  tuneGrid = tunegrid2,
                  trControl = control
                  )
model.03
plot(model.03)

# Grid Search의 단점은 최적의 모형을 찾기에는 시간이 조금 걸릴 수 있다. 
# 그러나, 장점은 모형 성능을 경험적으로 깨달을 수 있기 때문에 조정할 수 있다. 
# tunegrid2를 적용하면서 RMSE를 0.01 단위로 모형을 비교할 수 있음을 알 수 있다. 

#### (3) 파라미터 튜닝 방식 - ntree 개수 심기 ####
# ntree 개수를 심지 않았다.
# ntree 개수를 심으려면 for-loop를 적용한다. 
set.seed(1234)
tunegrid2 <- expand.grid(.mtry=c(4:9))
control <- trainControl(search="grid", 
                        verboseIter = TRUE) # 진행상황 확인

# 모형 담기
modellist <- list()

for (ntree in c(300, 400, 500, 600)) {
    set.seed(1234)
  model <- train(medv ~ .,
                 method   = "rf", 
                 data     = training, 
                 tuneGrid = tunegrid2,
                 trControl = control, 
                 ntree = ntree)
  
  key <- toString(ntree)
  modellist[[key]] <- model
}

# 결과 비교하자. 
results <- resamples(modellist)
summary(results)
dotplot(results)

# 이렇게 작은 데이터의 경우에도 3-4분의 시간이 소요됨을 알 수 있다. 
# 다른 모형도 위와 같은 방식으로 접근해서 작업해야 한다. 


