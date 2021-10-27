# ---- step 01 데이터 불러오기 ----

data(titanic_imputed, package = "DALEX")
head(titanic_imputed)

# ---- step 02 패키지 불러오기 ----
library(DALEX)

# ---- step 03 모델 생성하기 ---- 
ranger_model <- ranger::ranger(survived~., data = titanic_imputed, classification = TRUE, probability = TRUE)

gbm_model <- gbm::gbm(survived~., data = titanic_imputed, distribution = "bernoulli")

# ---- step 04 Model Parts Variable Importance ---- 
?explain
explainer_ranger <- explain(ranger_model, data = titanic_imputed, y = titanic_imputed$survived, label = "Ranger Model")

?model_parts
# Ref. https://ema.drwhy.ai/featureImportance.html
# 가장 중요한 변수는 Gender 임을 강조. 
fi_ranger <- model_parts(explainer_ranger)
plot(fi_ranger)

# ----- step 05 Model Profile ----
# ALE Plot
explainer_ranger <- explain(ranger_model, data = titanic_imputed, y = titanic_imputed$survived, label = "Ranger Model", verbose = FALSE)
explainer_gbm <- explain(gbm_model, data = titanic_imputed, y = titanic_imputed$survived, label = "GBM Model", verbose = FALSE)

ale_ranger <- model_profile(explainer_ranger, variables = "fare", type = "accumulated")
ale_gbm <- model_profile(explainer_gbm, variables = "fare", type = "accumulated")
plot(ale_ranger$agr_profiles, ale_gbm$agr_profiles)

# 주요 참고자료
# https://christophm.github.io/interpretable-ml-book/ale.html#theory-2
# https://tootouch.github.io/IML/accumulated_local_effects/
