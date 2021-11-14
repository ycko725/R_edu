# references
# http://xai-tools.drwhy.ai/flashlight.html

# 데이터 불러오기
data(titanic_imputed, package = "DALEX")
head(titanic_imputed)

# 패키지 불러오기
library(flashlight)
library(MetricsWeighted)

# 모델 만들기 
ranger_model <- ranger::ranger(survived~., data = titanic_imputed, classification = TRUE, probability = TRUE)
tree_model <- rpart::rpart(as.factor(survived)~., data = titanic_imputed)


# Model Parts
custom_predict <- function(X.model, new_data) {
  predict(X.model, new_data)$predictions[,1]
}

fl <- flashlight(model = ranger_model, data = titanic_imputed, y = "survived", label = "Titanic Ranger",
                 metrics = list(auc = AUC), predict_function = custom_predict)

imp <- light_importance(fl, m_repetitions = 10)

plot(imp, fill = "darkred")

# two models 
custom_predict_ranger <- function(X.model, new_data) {
  predict(X.model, new_data)$predictions[,1]
}

custom_predict_rpart <- function(X.model, new_data) {
  predict(X.model, new_data)[,1]
}

fl_ranger <- flashlight(model = ranger_model,  label = "Titanic Ranger",
                        metrics = list(auc = AUC), predict_function = custom_predict_ranger)

fl_rpart <- flashlight(model = tree_model,  label = "Titanic Tree",
                       metrics = list(auc = AUC), predict_function = custom_predict_rpart)

fl <- multiflashlight(list(fl_ranger, fl_rpart), data = titanic_imputed, y = "survived")

imp <- light_importance(fl, m_repetitions = 10)
plot(imp, fill = "darkred")

# Interactions - One model
custom_predict <- function(X.model, new_data) {
  predict(X.model, new_data)$predictions[,1]
}

fl <- flashlight(model = ranger_model, data = titanic_imputed, y = "survived", label = "Titanic Ranger",
                 metrics = list(auc = AUC), predict_function = custom_predict)

st_1 <- light_interaction(fl, seed = 123)
plot(st_1, fill = "darkred")

# Model Profile
custom_predict <- function(X.model, new_data) {
  predict(X.model, new_data)$predictions[,1]
}

fl <- flashlight(model = ranger_model, data = titanic_imputed, y = "survived", label = "Titanic Ranger",
                 metrics = list(auc = AUC), predict_function = custom_predict)

ale <- light_profile(fl, v = "fare", type = "ale")
plot(ale)

