# ---- tidymodels ----

library(tidymodels)
data("iris")

# 데이터 분리
set.seed(300)
split = initial_split(iris, prop = 0.7)
train = training(split)
test  = testing(split)

# 교차검증 데이터셋 준비
folds_5 = vfold_cv(train, v = 5, repeats = 2)

# ---- Use default parameters in parsnip ---- 
# randomForest
show_engines("rand_forest")

# Create Model 
rf_spec = rand_forest(mode = "classification") %>% set_engine("randomForest")

# Fit Traning Data
model_default = rf_spec %>% fit(Species ~ ., data = train)
model_default

# 예측 평가
model_default %>% 
  predict(test) %>% 
  bind_cols(test) %>% 
  metrics(Species, .pred_class) 

# 혼동 행렬
model_default %>% 
  predict(test) %>% 
  bind_cols(test) %>% 
  conf_mat(Species, .pred_class) 

# 다양한 모델 평가지표 
multimetric <- metric_set(accuracy, bal_accuracy, sens, yardstick::spec, precision, recall, ppv, npv)

model_default %>% 
  predict(test) %>% 
  bind_cols(test, type = "prob") %>% 
  multimetric(Species, estimate = .pred_class)

# ---- Use tune to tune parsnip model ----
# 파라미터 추가
# 옵션 1
rf_spec = rand_forest(mode = "classification") %>% set_engine("randomForest")
rf_spec <- rf_spec %>% update(mtry = tune(), trees = tune())

# 옵션 2
rf_spec_new <- rand_forest(
  mode = "classification", 
  mtry = tune(), 
  trees = tune()
) %>% 
  set_engine("randomForest")

# Create Workflow
rf_workflow <- workflow() %>% 
  add_variables(Species, predictors = everything()) %>% 
  add_model(rf_spec_new)

# ---- Grid Search ----
set.seed(300)
manual_tune <- rf_workflow %>% 
  tune_grid(
    resamples = folds_5, 
    grid = expand.grid(
      mtry = c(1, 2, 3), 
      trees = c(500, 1000, 2000)
    )
  )

collect_metrics(manual_tune)

# ---- show best model ----
show_best(manual_tune, n = 1)

manual_final <- finalize_workflow(rf_workflow, select_best(manual_tune)) %>%
  fit(train)

manual_final %>% 
  predict(test) %>% 
  bind_cols(test) %>% 
  multimetric(Species, estimate = .pred_class)

# ---- Random Search ----
set.seed(300)
random_tune <- rf_workflow %>% tune_grid(
  resamples = folds_5, grid = 5
)

show_best(random_tune)

random_final <- finalize_workflow(rf_workflow, select_best(random_tune)) %>% 
  fit(train)

random_final %>% 
  predict(test) %>% 
  bind_cols(test) %>% 
  multimetric(Species, estimate = .pred_class)

save(random_final, file = "model/model.RData")