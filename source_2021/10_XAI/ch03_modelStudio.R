# 데이터 불러오기 
data(titanic_imputed, package = "DALEX")
head(titanic_imputed)

# 패키지 불러오기 
library(DALEX)
library(modelStudio)

set.seed(123)

rf_model <- ranger::ranger(survived~., data = titanic_imputed, classification = TRUE, probability = TRUE)

explainer_rf <- DALEX::explain(rf_model,
                               data = titanic_imputed[, -8], y = titanic_imputed[, 8], verbose = FALSE)

ms <- modelStudio(explainer_rf, B = 50)
r2d3::save_d3_html(ms, file = "~/Desktop/R_edu/source_2021/10_XAI/modelStudio_titanic.html")
