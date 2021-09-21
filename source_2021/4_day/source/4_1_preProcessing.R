# ------------------
# 모형의 예측변수의 값을 보정하는 방법에 대해 배웁니다. 
# ------------------

#### I. scale-center 예제 ####
library(caret) # 머신러닝을 위한 패키지
library(tidyverse) # 데이터 핸들링 및 시각화를 위한 패키지
library(doParallel) # 병렬처리를 위한 패키지
library(ROCR)
library(pROC)

detectCores() # 현재 자기 컴퓨터의 코어 개수를 반환한다

# 병렬처리에 쓸 코어를 등록한다. 
# 보통 50% 쓰는 것을 추천한다. (이유: 모형이 개발되는 동안 다른 간단한 작업도 해야 함)
cl <- parallel::makeCluster(2, setup_timeout = 0.5)
registerDoParallel(cl)
data("Sonar", package = "mlbench")

set.seed(2020)
inTrain <- createDataPartition(y = Sonar$Class, # 반응치 자료가 필요
                               p = .75, # 훈련용 데이터의 비율
                               list = FALSE) # 결과의 형식 지정

training <- Sonar[ inTrain,]
testing <- Sonar[-inTrain,]

#### (1) 기본 모형 및 테스트 ####
control <- trainControl(
  method  = "repeatedcv",
  number  = 5, # 5겹
  repeats = 3, # 3번
  classProbs = TRUE, 
  summaryFunction = twoClassSummary)

plsFit <- train(Class ~ .,
                data = training,
                method = "pls", 
                trControl = control,
                metric = "ROC")

plsFit

#### (2) center & scale ####
plsFit.ct_sc <- train(Class ~ .,
                data = training,
                method = "pls", 
                trControl = control,
                metric = "ROC",
                preProc = c("center", "scale"))

plsFit.ct_sc

pred_plsFit.ct_sc <- predict(plsFit.ct_sc, testing, type = "raw")
confusionMatrix(pred_plsFit.ct_sc, testing$Class)
# accuracy: 0.7843

pr <- prediction(as.numeric(pred_plsFit.ct_sc) - 1, as.numeric(testing$Class) - 1)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
abline(0, 1, col = "red")

## -- 
# AUC = Area Under Curve의 뜻으로
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]; auc
# AUC: 0.8425

#### II preProcessing - Data Transformation ####
# 기본 모형
data("Boston", package = "MASS")

set.seed(2020)
inTrain <- createDataPartition(y = Boston$medv, # 반응치 자료가 필요
                               p = .75, # 훈련용 데이터의 비율
                               list = FALSE) # 결과의 형식 지정

training <- Boston[ inTrain,]
testing <- Boston[-inTrain,]

#### (1) 기본 모형 및 테스트 ####
control <- trainControl(
  method  = "repeatedcv",
  number  = 5, # 5겹
  repeats = 3, # 3번
  )

lmFit <- train(medv ~ .,
               data = training,
               method = "lm", 
               trControl = control)

lmFit
# RMSE      Rsquared  MAE     
# 4.911711  0.723149  3.415332

#### (2) boxcox-transformation ####
lm.BoxCox <- train(medv ~ .,
               data = training,
               method = "lm", 
               trControl = control, 
               preProc = c("BoxCox"))

lm.BoxCox
# RMSE      Rsquared   MAE     
# 4.556801  0.7578126  3.336555

#### (3) preProcessing - SpatialSign ####
lm.spatialSign <- train(medv ~ .,
                   data = training,
                   method = "lm", 
                   trControl = control, 
                   preProc = c("spatialSign"))

lm.spatialSign
# RMSE      Rsquared   MAE     
# 5.397496  0.6645011  3.883272

# 오히려 떨어졌다. 
# Note: Since the denominator is intended to measure the squared distance to the  center of the predictor’s distribution, it is important to center and scale the  predictor data prior to using this transformation.
# Kuhn, Max. Applied Predictive Modeling (p. 34). Springer New York. Kindle Edition. 

#### (4) preProcessing - SpatialSign ####
lm.spatialSign.2 <- train(medv ~ .,
                        data = training,
                        method = "lm", 
                        trControl = control, 
                        preProc = c("center", "scale", "spatialSign"))

# (3) 보다 값은 보정 되었지만, 여전히 (2) 보다는 적음
lm.spatialSign.2
# RMSE      Rsquared   MAE     
# 5.441568  0.6651661  3.886313

# 위와 같은 형태로 각각을 비교하면서 모형을 보정하는 것이 상례임
# 그 외에도 PCA 등을 적용할 수 있다. 
# PCA의 경우에는 수치형 데이터에 대한 차원축소로 알려져 있으며, 설명자료가 인터넷에 설명자료가 많기 때문에 여기서는 생략한다
# https://rpubs.com/Evan_Jung/pca 제가 작성한 자료를 참고로 대체 함

#### III 결측값 대체 방법 ####
library(caret) # 머신러닝을 위한 패키지
library(tidyverse) # 데이터 핸들링 및 시각화를 위한 패키지
library(doParallel) # 병렬처리를 위한 패키지

detectCores() # 현재 자기 컴퓨터의 코어 개수를 반환한다

# 병렬처리에 쓸 코어를 등록한다. 
# 보통 50% 쓰는 것을 추천한다. (이유: 모형이 개발되는 동안 다른 간단한 작업도 해야 함)
cl <- makeCluster(2) 
registerDoParallel(cl)
 
breast_cancer <- read.csv('breast_cancer.csv')
summary(breast_cancer)

inTrain <- createDataPartition(y = breast_cancer$breast_cancer_y, # 반응치 자료가 필요
                               p = .75, # 훈련용 데이터의 비율
                               list = FALSE) # 결과의 형식 지정

training <- breast_cancer[ inTrain,]
testing <- breast_cancer[-inTrain,]

control <- trainControl(
  method  = "repeatedcv",
  number  = 5, # 5겹
  repeats = 3, # 3번
  summaryFunction = twoClassSummary,
  classProbs = TRUE, # IMPORTANT!
  verboseIter = TRUE
)

#### (1) median Impute ####
glm.median <- train(
  x = training[, 1:9], y = training$breast_cancer_y,
  method = "glm",
  trControl = control,
  metric = "ROC",
  preProcess = "medianImpute"
)

glm.median

pred_glm.median <- predict(glm.median, testing, type = "raw")
confusionMatrix(pred_glm.median, testing$breast_cancer_y)
# accuracy: 0.96

pr <- prediction(as.numeric(pred_glm.median) - 1, as.numeric(testing$breast_cancer_y) - 1)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
abline(0, 1, col = "red")

## -- 
# AUC = Area Under Curve의 뜻으로
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]; auc
# AUC: 0.9578947

#### (2) knnImpute ####
# glm.knnImpute
glm.knnImpute <- train(
  x = training[, 1:9], y = training$breast_cancer_y,
  method = "glm",
  trControl = control,
  metric = "ROC",
  preProcess = "knnImpute"
)

glm.knnImpute

pred_glm.knn <- predict(glm.knnImpute, testing, type = "raw")
confusionMatrix(pred_glm.knn, testing$breast_cancer_y)
# accuracy: 0.96

pr <- prediction(as.numeric(pred_glm.knn) - 1, as.numeric(testing$breast_cancer_y) - 1)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
abline(0, 1, col = "red")

## -- 
# AUC = Area Under Curve의 뜻으로
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]; auc
# AUC: 0.9578947

#### IV 예측 변수 제거 ####
# 일부 변수에 정보가 없거나 매우 낮은 경우가 있다. 이를 기반으로 예측모형을 개발할 경우 쓸모 없는 변수가 예측모형에 포함되어 기대하지 않은 많은 문제가 야기된다.

# "zv", "nzv" 값을 preProcess 인자로 넣는 경우 상수 변수와 거의 상수 변수를 처리할 수 있다.
# "zv" : 상수 변수 제거
# "nzv" : 거의 상수 변수 제거
# 기존 데이터에 variance_zero <- 7 입력한다. 

#### (1) 기본 모형 및 테스트 
set.seed(2020)

# Boston 데이터에 상수 변수를 넣어본다. 
data("Boston", package = "MASS")
Boston$zero_var <- 2020

inTrain <- createDataPartition(y = Boston$medv, # 반응치 자료가 필요
                               p = .75, # 훈련용 데이터의 비율
                               list = FALSE) # 결과의 형식 지정

training <- Boston[ inTrain,]
testing <- Boston[-inTrain,]

#### (1) 기본 모형 및 테스트 ####
control <- trainControl(
  method  = "repeatedcv",
  number  = 5, # 5겹
  repeats = 3, # 3번, 
  verboseIter = TRUE
)

lmFit <- train(medv ~ .,
               data = training,
               method = "lm", 
               trControl = control)

lmFit
# RMSE      Rsquared   MAE     
# 5.060429  0.7262689  3.528523

#### (2) nzv ####
lmFit.nzv <- train(medv ~ .,
               data = training,
               method = "lm", 
               trControl = control, 
               preProc = "nzv")

lmFit.nzv
# Pre-processing: remove (2) # nzv 변수 2개가 제거된 것을 확인할 수 있음. 
