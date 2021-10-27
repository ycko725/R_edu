# ------------------
# 본 장은 R에서 Keras를 실습하는 과정입니다.  
# 딥러닝에 대한 자세한 이론 설명은 별도로 하지 않습니다. 
# 추후 딥러닝 강좌 개설 시, 중요 개념들에 대해 짚고 넘어갑니다. 
# ------------------

#### 1단계: 패키지 설치 ####
# 패키지는 H2O와 다르게 쉽습니다. 
devtools::install_github("rstudio/keras")
library(keras)

# 텐서플로우 설치: tensorflow를 벡엔드로 사용하기 때문. 
install_keras()

#### 2단계: 데이터 불러오기 ####
iris <- iris

#### 3단계: 상관관계 그래프 작성하기 (옵션) #### 
library(corrplot)

# 수치형 데이터를 상관관계수로 변환하기
M <- cor(iris[,1:4])

# 상관관계 그래프 작성하기
corrplot(M, method="circle")

#### 4단계: 데이터 전처리 ####
# (1) 데이터프레임을 행렬로 변환 -------------------
# 범주형을 숫자로 바꿔야 한다. 
# 딥러닝은 데이터프레임이 아니라 행렬형태로 데이터를 받는다. 
iris[,5] <- as.numeric(as.factor(unlist(iris[,5]))) -1
iris <- as.matrix(iris)
dimnames(iris) <- NULL

# (2) 데이터 정규화 -------------------
# keras 패키지에는 normalize 함수가 있다. 
iris_x <- normalize(iris[,1:4])

# 정규화가 진행된 데이터를 다시 5 column과 합친 코드이다. 
iris_mat <- cbind(iris_x, iris[,5])
head(iris_mat)

#### 5단계: 딥러닝 모형 데이터셋 분리 ####
# 데이터 셋 나누기 index 
ind <- sample(2, nrow(iris_mat), replace=TRUE, prob=c(0.67, 0.33))

# 모형 설계행렬
iris.training <- iris_mat[ind==1, 1:4]
iris.test <- iris_mat[ind==2, 1:4]

# 모형 예측변수
iris.trainingtarget <- iris_mat[ind==1, 5]
iris.testtarget <- iris_mat[ind==2, 5]

# One-Hot 인코딩: 훈련예측변수
iris.trainLabels <- to_categorical(iris.trainingtarget)

# One-Hot 인코딩: 검증예측변수
iris.testLabels <- to_categorical(iris.testtarget)

#### 6단계: 딥러닝 모형 개발 ####
# 데이터에 적합한 딥러닝 모형을 적용해야 하는데 신경망 계층(layer)은 몇층으로 할지, 노드는 몇개로 할지, 활성화(activation) 함수는 무엇으로 할지, 하이퍼 모수 학습률(learning rate)은 어떻게 정할지, 다양한 조합이 모형의 성능에 영향을 미치게 된다. 그런 점에서 케라스는 모형자체에 개발자가 집중할 수 있도록 함으로써 큰 도움을 주고 있다.

set.seed(777)

# (1) 모형 초기화
model <- keras_model_sequential()

# 여기에 우선적으로 아래와 같이 신경망 계층을 만듭니다. 
# output 값이 3개입니다. (versicolor, virginica, setosa)
# 8 hidden notes를 만들었고, input shape = 4개로 만들었는데, 
# 이유는 4개의 column이 존재하기 때문입니다. 

model %>% 
  layer_dense(units = 8, activation = 'relu', input_shape = c(4)) %>% 
  layer_dense(units = 3, activation = 'softmax')

# 모형 요약
summary(model)

# 모형 configuration
get_config(model)

#  layer configuration
get_layer(model, index = 1)

# List the model's layers
model$layers

# List the input tensors
model$inputs

# List the output tensors
model$outputs

#### 7단계: 딥러닝 모형 컴파일 ####
# loss & optimizer에 대한 구체적인 설명은 별도로 하지 않겠습니다. 
# categorical_crossentropy는 다중 분류를 의미합니다. 
# 만약 이중분류를 하고 싶다면, 'binary_crossentropy' 입력하면 됩니다. 
# 가장 많이 사용되는 최적화 알고리즘은 SGD (Stochastic Gradient Descent), ADAM 및 RMSprop입니다. 

# 이 내용은 관련 책을 참조 바랍니다. 
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = 'adam',
  metrics = 'accuracy'
)

#### 8단계: 딥러닝 모형 적합 ####
model %>% fit(
  iris.training, 
  iris.trainLabels, 
  epochs = 500, 
  batch_size = 5,
  validation_split = 0.1
)

#### 9단계: 예측 모형 테스트 ####
# 테스트 데이터를 활용한 예측값 산출
classes <- model %>% predict_classes(iris.test, batch_size = 128)

# 혼동행렬
table(iris.testtarget, classes)

#### 10단계: 모형 평가 ####
# 테스트 데이터를 기반으로 모형을 평가한다. 
score <- model %>% evaluate(iris.test, iris.testLabels, batch_size = 128)

# loss 및 accuracy가 산출 된 것을 확인할 수 있다. 
print(score)

# 자세한 내용은 아래를 참고한다. 
# https://keras.io/