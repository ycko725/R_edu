# https://bookdown.org/cardiomoon/roc/

library(caret)
library(ModelMetrics)
library(dplyr)
library(mlbench)
library(tidyr)

data(PimaIndiansDiabetes, package = "mlbench")

set.seed(123)
ind <- createDataPartition(PimaIndiansDiabetes$diabetes, 0.7)
tr <- PimaIndiansDiabetes[ind$Resample1,]
ts <- PimaIndiansDiabetes[-ind$Resample1,]


ctrl <- trainControl(method = "cv",
                     number = 5, 
                     returnResamp = 'none',
                     summaryFunction = twoClassSummary,
                     classProbs = T,
                     savePredictions = T,
                     verboseIter = F)


gbmGrid <-  expand.grid(interaction.depth = 10,
                        n.trees = 200,                                      
                        shrinkage = 0.01,                 
                        n.minobsinnode = 4) 

gbm_pima <- train(diabetes ~ .,
                  data = tr,
                  method = "gbm", 
                  metric = "ROC",
                  tuneGrid = gbmGrid,
                  verbose = FALSE,
                  trControl = ctrl)



probs <- seq(.1, 0.9, by = 0.02)
ths <- thresholder(gbm_pima,
                   threshold = probs,
                   final = TRUE,
                   statistics = "all")

ths %>%
  mutate(prob = probs) %>%
  filter(J == max(J)) %>%
  pull(prob) -> thresh_prob

thresh_prob

longdf <- ths %>% 
  pivot_longer(cols = Sensitivity:Specificity, names_to = "rate")

ggplot(data = longdf, aes(x = prob_threshold, 
                          y = value, 
                          color = rate)) + 
  geom_line() + 
  scale_x_continuous(breaks = seq(0, 1, by = 0.1))

pred <- predict(gbm_pima, newdata = ts, type = "prob")
real <- as.numeric(factor(ts$diabetes))-1

ModelMetrics::sensitivity(real, pred$pos, cutoff = thresh_prob)
ModelMetrics::specificity(real, pred$pos, cutoff = thresh_prob)
ModelMetrics::kappa(real, pred$pos, cutoff = thresh_prob)
ModelMetrics::mcc(real, pred$pos, cutoff = thresh_prob)
ModelMetrics::auc(real, pred$pos)

library(pROC)
roc.obj <- roc(real, pred$pos)
coords(roc.obj, "best", ret = "threshold")

plot(roc.obj, print.thres = "best")
