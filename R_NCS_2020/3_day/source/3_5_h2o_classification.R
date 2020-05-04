# ------------------
# caret과 유사한 interface를 가진 h2o 패키지를 소개합니다. 
# ------------------

#### 1. 환경설정 ####
# 우선 교재를 보시고 자바 설치를 완료 해주시기를 바랍니다. 
# 교재에서 환경변수 설정은 꼭 해주시는 것이 좋습니다. 
# JAVA_HOME은 미리 설정하시는 게 좋습니다만, 
# 임시적으로 사용하실 경우에는 아래와 같이 코드를 입력해서 사용합니다. 

Sys.getenv("JAVA_HOME")
# [1] ""

# MacOS
# Sys.setenv(JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-13.0.2.jdk/Contents/Home")

# Windows
# Copy: C:\Program Files\Java\jdk1.8.0_251
Sys.setenv(JAVA_HOME="C:/Program Files/Java/jdk1.8.0_251")

Sys.getenv("JAVA_HOME")
# [1] "/Library/Java/JavaVirtualMachines/jdk-13.0.2.jdk/Contents/Home"

# 위와 같은 코드가 나왔다면 정상입니다. 

#### 2. 패키지 설치 ####
# 가급적 메뉴얼을 따라주세요. 
# 출처: http://docs.h2o.ai/h2o/latest-stable/h2o-docs/downloading.html#installing-h2o-s-r-package-from-cran

if("package:h2o" %in% search()) { 
  detach("package:h2o", unload=TRUE) 
}

if ("h2o" %in% rownames(installed.packages())) { 
  remove.packages("h2o") 
}

# 원문: The following two commands remove any previously installed H2O packages for R.
# 위코드는 이전 버전의 h2o 패키지를 삭제하는 코드 입니다.

# 원문: Next, download packages that H2O depends on.
# 의존성 코드 관련 패키지를 다운로드 합니다. 
pkgs <- c("RCurl","jsonlite")

for (pkg in pkgs) {
  if (! (pkg %in% rownames(installed.packages()))) { 
    install.packages(pkg) 
  }
}

# 이제 본격적으로 h2o 패키지를 설치합니다. 
install.packages("h2o", type="source", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R")))
# 시간 소요 꽤 됩니다. (쉬는 시간 가지세요.)

# cran에서 직접 받는 경우 최신버전이 아닐수도 있으니, 가급적 h2o에서 직접 받는 것을 추천합니다. 

#### 3. 설치 데모 확인 ####
library(h2o)
localH2O = h2o.init()
demo(h2o.kmeans)

## shut down
h2o.shutdown(prompt = F)
# TRUE가 나오면 정상적으로 종료가 된 것입니다. 

#### 4. 분류모형 예제 ####
#### (1) 패키지 불러오기 ####
library(tidyverse)
library(caret)
library(h2o)

#### (1) 데이터 불러오기 ####
# install.packages("kernlab", dependencies = TRUE)
data(spam, package = "kernlab")
glimpse(spam)

# 아래 소스코드를 입력하면 GUI에서 확인할 수 있습니다. 
localH2O = h2o.init()
spam_h2o <- as.h2o(spam, destination_frame = "spam_h2o")
class(spam_h2o)

# http://localhost:54321/flow/index.html Check

#### (2) 결측치 및 중복값 처리 ####
sapply(spam, function(x) sum(is.na(x)))
spam %>% duplicated() %>% sum()
spam <- spam %>% distinct()

#### (3) h2o 초기화 설정 #### 
?h2o.init
# -1은 병렬처리 한다는 뜻이며 또한 CPU 전체 사용한다는 뜻
# 속도가 빨라진다.
# 만약 그게 아니라면 CPU 개수 상수를 입력하면 된다. 
h2o.init(nthreads = -1, max_mem_size = "4G")

#### (4) 데이터 셋 분리 및 변수 정의 ####
set.seed(2020)

# 데이터셋 분리
ind <- sample(2, nrow(spam), replace = T, prob = c(0.8, 0.3))
train <- spam[ind == 1, ]
test  <- spam[ind == 2, ]

# 변수 정의
my_y <- "type"
my_x <- setdiff(names(train), my_y)

#### (5) 모형 개발 ####
# 메뉴얼을 잘 봐야 합니다. 
# 파라미터에 관한 설명은 여기에 있습니다. 
# https://h2o-release.s3.amazonaws.com/h2o/master/3908/docs-website/h2o-docs/parameters.html

# lambda_search : to find the optimal values of the regularization parameters λ
# The larger lambda is, the more the coefficients are shrunk toward zero (and each other)

# glm 모형
glm <- h2o.glm(
  x                 = my_x,
  y                 = my_y,
  training_frame    = as.h2o(train),
  model_id          = "default_glm", # 중요함
  family            = "binomial",
  lambda_search     = T,   
  alpha             = 0.5, 
  nfolds            = 10, 
  seed              = 2020)

# gbm 모형
gbm <- h2o.gbm(
  x = my_x,
  y = my_y,
  training_frame    = as.h2o(train),
  model_id          = "default_gbm",
  nfolds            = 10,
  ntrees            = 500,
  max_depth         = 10,
  learn_rate        = 0.01,
  seed              = 2020)

# randomforest 모형
drf <- h2o.randomForest(
  x = my_x,
  y = my_y,
  training_frame    = as.h2o(train),
  model_id          = "default_drf",
  nfolds            = 10,
  ntrees            = 500,
  max_depth         = 30,
  seed              = 2018)

## 딥러닝 모형
hdl <- h2o.deeplearning(
  x = my_x,
  y = my_y,
  training_frame    = as.h2o(train),
  model_id          = "default_hdl",
  nfolds            = 10,
  hidden            = c(10, 10),
  distribution      = "bernoulli",
  seed              = 2018)

## 각 모형의 정확도 비교
# h2o 문법은 조금 특이합니다. 

glm@model$cross_validation_metrics_summary$mean[1] # 0.93
gbm@model$cross_validation_metrics_summary$mean[1] # 0.95
drf@model$cross_validation_metrics_summary$mean[1]
hdl@model$cross_validation_metrics_summary$mean[1]

## 두개의 모형 비교
models <- list(glm, gbm, drf, hdl)

# 실제 테스트 데이터에 적용 및 Acc 비교
models %>% 
  map(~ h2o.predict(.x, as.h2o(test))) %>% 
  map(as_tibble) %>% 
  map("predict") %>% 
  map(~ confusionMatrix(.x, test$type, positive = "spam")) %>% 
  map("overall") %>% 
  map_dfc("Accuracy") %>% 
  set_names(paste0("Acc_", c("glm", "gbm", "drf", "hdl")))

## AUC 비교
glm@model$cross_validation_metrics@metrics$AUC
gbm@model$cross_validation_metrics@metrics$AUC
drf@model$cross_validation_metrics@metrics$AUC
hdl@model$cross_validation_metrics@metrics$AUC

models %>% 
  map(~ h2o.auc(.x, xval = T)) %>% 
  bind_cols() %>% 
  set_names(paste0("AUC_", c("glm", "gbm", "drf", "hdl")))

## 변수 중요도 확인
h2o.varimp_plot(gbm, num_of_features = 20)

## shut down
h2o.shutdown(prompt = F)

# h2o를 활용하여  회귀모형 예제는 다음을 참고하세요. 
# Regreesion Model
# https://nbviewer.jupyter.org/github/woobe/useR2019_h2o_tutorial/blob/master/tutorial.html#regression-part-one-h2o-automl

