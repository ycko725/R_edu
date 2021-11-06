# ---- tidymodels ----
library(tidymodels)
data("iris")
glimpse(iris)

# 이항분류로 바꿔서 실행 바랍니다. ^^
# 쉬는 시간은 7시 45분 ~ 8시 입니다. 
iris2 <- iris[1:100, ]
iris2$Species <- droplevels(iris2$Species)
iris2$Species


# 데이터 분리
set.seed(100)
split = initial_split(iris2, prop = 0.7)
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
multimetric <- metric_set(accuracy, bal_accuracy, sens, spec, precision, recall)

# 예측 평가
model_default %>%
  predict(test) %>% 
  bind_cols(test, type = "prob") %>% 
  multimetric(Species, estimate = .pred_class)

# ---- Use tune to tune parsnip model ----
# 파라미터 추가
# 옵션 1
rf_spec = rand_forest(mode = "classification") %>% set_engine("randomForest")
rf_spec = rf_spec %>% 
  update(mtry = tune(), trees = tune())

# 옵션 2
rf_spec_2 = rand_forest(
  mode = "classification", 
  mtry = tune(), 
  trees = tune()
) %>% 
  set_engine("randomForest")

# Create Workflow
rf_workflow <- workflow() %>% 
  add_variables(Species, predictors = everything()) %>% 
  add_model(rf_spec_2)

# ---- Grid Search ----
manual_tune <- rf_workflow %>% 
  tune_grid(
    resamples = folds_5, 
    grid = expand.grid(
      mtry = c(1, 2, 3), 
      trees = c(500, 1000, 2000)
    )
  )


# ---- show best model ----
show_best(manual_tune, n = 1)
manual_final <- finalize_workflow(rf_workflow, select_best(manual_tune)) %>% fit(train)

manual_final %>%
  predict(test) %>% 
  bind_cols(test, type = "prob") %>% 
  multimetric(Species, estimate = .pred_class)


# ---- Random Search ----
set.seed(300)
random_tune <- rf_workflow %>% tune_grid(
  resamples = folds_5, grid = 5
)

show_best(random_tune, n = 1)
random_final <- finalize_workflow(rf_workflow, select_best(random_tune)) %>% fit(train)

random_final %>%
  predict(test) %>% 
  bind_cols(test, type = "prob") %>% 
  multimetric(Species, estimate = .pred_class)
