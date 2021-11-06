# 라이브러리 불러오기
library(tidymodels)

# 데이터 불러오기
data("penguins")

# 결측치 제거하기
penguins = na.omit(penguins)

# 데이터 분리
# 과제: loan 데이터로 바꿔서 진행해본다. 
set.seed(123)
split <- initial_split(penguins, strata = sex)
train <- training(split)
test <- testing(split)

# 모델 개발 - XGBoost 
xgb_spec <- boost_tree(
  trees = 1000, 
  tree_depth = tune(), 
  min_n = tune(), 
  loss_reduction = tune(),  ## first three: model complexity
  sample_size = tune(), mtry = tune(),  ## randomness
  learn_rate = tune(),                  ## step size
) %>% 
  set_engine("xgboost") %>% 
  set_mode("classification")

# 모델 설정
xgb_spec

# 하이퍼 파라미터 튜닝 그리드 서치
?grid_latin_hypercube
xgb_grid <- grid_latin_hypercube(
  tree_depth(),
  min_n(),
  loss_reduction(),
  sample_size = sample_prop(),
  finalize(mtry(), train),
  learn_rate(),
  size = 30
)

xgb_grid

# 머신러닝 워크플로우 설정
xgb_wf <- workflow() %>%
  add_formula(sex ~ .) %>%
  add_model(xgb_spec)

xgb_wf
set.seed(123)

# 교차검증 셋
vb_folds <- vfold_cv(train, strata = sex, v = 5)

# 모형 학습을 위한 클러스터 설정 
cl <- parallel::makeCluster(8, setup_timeout = 0.5)
doParallel::registerDoParallel(cl)

set.seed(234)
xgb_res <- tune_grid(
  xgb_wf,
  resamples = vb_folds,
  grid = xgb_grid,
  control = control_grid(save_pred = TRUE)
)

# 모형학습 결과 
xgb_res
collect_metrics(xgb_res)

# 최적의 파라미터 산출을 위한 시각화 
xgb_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  select(mean, mtry:sample_size) %>%
  pivot_longer(mtry:sample_size,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(alpha = 0.8, show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "AUC")

# 가장 좋은 파라미터 추출 
show_best(xgb_res, "roc_auc")
best_auc <- select_best(xgb_res, "roc_auc")
best_auc

# 도출된 최적의 파라미터 적용 
final_xgb <- finalize_workflow(
  xgb_wf,
  best_auc
)

final_xgb

# Feature Importance 
library(vip)

final_xgb %>%
  fit(data = train) %>%
  extract_fit_parsnip() %>%
  vip(geom = "point") + 
  theme_minimal()

# 최종 테스트 셋 적용을 위한 마지막 설정 
final_res <- last_fit(final_xgb, split)
collect_metrics(final_res)



# 최종 테스트 혼동행렬 분류표 
final_res %>%
  collect_predictions() %>%
  roc_curve(sex, .pred_female) %>%
  autoplot() + 
  theme_minimal() 

final_boosted_model <- fit(final_res, penguins)
save(final_boosted_model, file = "penguin_model.RData")

# 참고문헌
# https://statkclee.github.io/model/tidyverse-parsnip-penguin-xgboost.html#1_tidymodels%EC%99%80_XGBoost12