# 데이터 불러오기
data("titanic_imputed", package = "DALEX")
head(titanic_imputed)

# 패키지 
library(DALEX)
# install.packages("modelStudio")
library(modelStudio)

set.seed(2021)

rf_model <- ranger::ranger(survived ~ ., data = titanic_imputed, classification = TRUE, probability = TRUE)

# DALEX 
explainer_rf_model <- DALEX::explain(rf_model, data = titanic_imputed[, -8], y = titanic_imputed[, 8])

# ModelStudio
ms <- modelStudio::modelStudio(explainer_rf_model, B = 50)
# install.packages("r2d3")
r2d3::save_d3_html(ms, file = "modelstudio.html")

