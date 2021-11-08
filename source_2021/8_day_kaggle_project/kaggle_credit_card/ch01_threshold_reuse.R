# https://bookdown.org/cardiomoon/roc/

library(caret)
library(ModelMetrics)
library(dplyr)
library(mlbench)
library(tidyr)

data("PimaIndiansDiabetes", package = "mlbench")

set.seed(123)
idx   = createDataPartition(PimaIndiansDiabetes$diabetes, 0.7)
train = PimaIndiansDiabetes[idx$Resample1, ]
test = PimaIndiansDiabetes[-idx$Resample1, ]

# trainControl / 교차 검증 preprocessing, nzv, pca, center scale
ctrl = trainControl(method = "cv"
                    , number = 5
                    , returnResamp = "none"
                    , summaryFunction = twoClassSummary
                    , classProbs = TRUE 
                    , savePredictions = TRUE
                    , verboseIter = FALSE)

# 하이퍼 파라미터 지정
glimpse(train)
modelLookup("gbm")
gbmGrid = expand.grid(interaction.depth = 10
                      , n.trees = 100
                      , shrinkage = 0.01
                      , n.minobsinnode = 2)

# 모델 설정
gbm_model = train (diabetes ~ ., 
                      data = train
                      , method = "gbm"
                      , metric = "ROC"
                      , tuneGrid = gbmGrid
                      , verbose = FALSE 
                      , trControl = ctrl)

gbm_model
probs <- seq(.1, 0.9, by = 0.02)
ths_df <- thresholder(gbm_model
                      , threshold = probs
                      , final = TRUE
                      , statistics = "all")

ths_df %>% 
  mutate(prob = probs) %>% 
  filter(J == max(J)) %>% 
  pull(prob) -> thresh_hold_value

thresh_hold_value

longdf <- ths_df %>% 
  pivot_longer(cols = Sensitivity:Specificity, names_to = "rate")

glimpse(longdf)

ggplot(data = longdf, aes(x = prob_threshold, 
                          y = value, 
                          color = rate)) + 
  geom_line()

pred = predict(gbm_model, newdata = test, type = "prob")
real = as.numeric(factor(test$diabetes)) - 1

ModelMetrics::sensitivity(real, pred$pos, cutoff = thresh_hold_value)
ModelMetrics::specificity(real, pred$pos, cutoff = thresh_hold_value)
ModelMetrics::auc(real, pred$pos, cutoff = thresh_hold_value)


library(pROC)
roc_obj <- roc(real, pred$pos)
coords(roc_obj, "best", ret = "threshold")
plot(roc_obj, print.thres = "best")
