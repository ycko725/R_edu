# Classification use case
library(dplyr)
library(DALEX)
library(DALEXtra)
library(titanic)
library(fastDummies)
library(h2o)
set.seed(123)

# 데이터 불러오기 및 전처리
titanic_small <- titanic_train %>%
  select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked) %>%
  mutate_at(c("Survived", "Sex", "Embarked"), as.factor) %>%
  mutate(Family_members = SibSp + Parch) %>% # Calculate family members
  na.omit() %>%
  dummy_cols() %>%
  select(-Sex, -Embarked, -Survived_0, -Survived_1, -Parch, -SibSp)

print(head(titanic_small))

# 데이터 분리
titanic_small_y <- titanic_small %>% 
  select(Survived) %>%
  mutate(Survived = as.numeric(as.character(Survived))) %>%
  as.matrix()

titanic_small_x <- titanic_small %>%
  select(-Survived) %>%
  as.matrix()

# h2o 모델 만들기
h2o.init()
h2o.no_progress()

titanic_h2o <- as.h2o(titanic_small, destination_frame = "titanic_small")

model_h2o <- h2o.deeplearning(x = 2:11,
                              y = 1,
                              training_frame = "titanic_small",
                              activation = "Rectifier", # ReLU as activation functions
                              hidden = c(16, 8), # Two hidden layers with 16 and 8 neurons
                              epochs = 100,
                              rate = 0.01, # Learning rate
                              adaptive_rate = FALSE, # Simple SGD
                              loss = "CrossEntropy")

# 테스트 데이터 셋
henry <- data.frame(
  Pclass = 1,
  Age = 8,
  Fare = 72,
  Family_members = 0,
  Sex_male = 1,
  Sex_female = 0,
  Embarked_S = 0,
  Embarked_C = 1,
  Embarked_Q = 0,
  Embarked_ = 0
)

henry_h2o <- as.h2o(henry, destination_frame = "henry")
predict(model_h2o, henry_h2o) %>% print()

# Explain Function()
explainer_titanic_h2o   <- DALEXtra::explain_h2o(model = model_h2o,
                                                 data = titanic_small[ , -1],
                                                 y = as.numeric(as.character(titanic_small$Survived)),
                                                 label = "MLP_h2o",
                                                 colorize = FALSE)

# Model Performance
mp_titinic_h2o   <- model_performance(explainer_titanic_h2o)
mp_titinic_h2o

plot(mp_titinic_h2o)
plot(mp_titinic_h2o, geom = "boxplot")

vi_titinic_h2o   <- model_parts(explainer_titanic_h2o)
plot(vi_titinic_h2o)
vi_titinic_h2o   <- model_parts(explainer_titanic_h2o, type="difference")
plot(vi_titinic_h2o)

# Variable Reponse
mp_age_h2o    <- model_profile(explainer_titanic_h2o, variable =  "Pclass")
plot(mp_age_h2o)

# Prediction Understanding
pp_h2o   <- predict_parts(explainer_titanic_h2o, henry, type = "break_down")

plot(pp_h2o)
