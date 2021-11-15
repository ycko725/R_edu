# install.packages("DALEX")
# install.packages("DALEXtra")
# install.packages("fastDummies")

library(dplyr)
library(DALEX)
library(DALEXtra)
library(titanic)
library(fastDummies)
library(h2o)

set.seed(2021)
titanic_train %>% 
  select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked) %>% 
  mutate_at(c("Survived", "Sex", "Embarked"), as.factor) %>% 
  mutate(fam_members = SibSp + Parch) %>% # 가족의 수 계산
  na.omit() %>% 
  dummy_cols() %>% 
  select(-Sex, -Embarked, -Survived_0, -Survived_1, -Parch, -SibSp) -> titanic_small

# 데이터 분리
# 종속변수
titanic_y <- titanic_small %>% 
  select(Survived) %>% 
  mutate(Survived = as.numeric(as.character(Survived))) %>% as.matrix()

# 독립변수
titanic_x <- titanic_small %>% 
  select(-Survived) %>% 
  as.matrix()

# h2o 모델 만들기
h2o.init()
h2o.no_progress()

titanic_h2o <- as.h2o(titanic_small, destination_frame = "titanic_small")

# 모델 만들기

model_h2o <- h2o.deeplearning(x = 2:11, 
                              y = 1, 
                              training_frame = "titanic_small", 
                              activation = "Rectifier", # Relu 
                              hidden = c(16, 8), 
                              epochs = 100, 
                              rate = 0.01, 
                              adaptive_rate = FALSE, # 간단한 SGD 
                              loss = "CrossEntropy") 

# 실제 테스트 데이터
human <- data.frame(
  Pclass = 1, 
  Age = 8, 
  Fare = 72, 
  fam_members = 0, 
  Sex_male = 1, 
  Sex_female = 0, 
  Embarked_S = 0, 
  Embarked_C = 1, 
  Embarked_Q = 0, 
  Embarked_ = 0
)

human_h2o <- as.h2o(human, destination_frame = "human")
predict(model_h2o, human_h2o) %>% print()

# 설명 함수
explain_fun_h2o <- DALEXtra::explain_h2o(model = model_h2o, 
                                         data = titanic_small[, -1], 
                                         y = as.numeric(as.character(titanic_small$Survived)), 
                                         label ="MLP_h2o", 
                                         colorize = FALSE)

# Model Performance
mlp_titanic_h2o <- model_performance(explain_fun_h2o)
mlp_titanic_h2o

plot(mlp_titanic_h2o)
plot(mlp_titanic_h2o, geom = "boxplot")

md_parts_titanic_h2o <- model_parts(explain_fun_h2o, type = "difference")
plot(md_parts_titanic_h2o)

# variable respose
vr_titanic_h2o <- model_profile(explainer = explain_fun_h2o, variable = "Pclass")

plot(vr_titanic_h2o)

# prediction 
pp_h2o <- predict_parts(explain_fun_h2o, human, type = "break_down")

plot(pp_h2o)
