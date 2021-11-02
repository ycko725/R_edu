# ------------------
# 2일차에 배운 caret을 응용하여 모형을 학습하고 비교합니다.  
# ------------------

#### I. caret 패키지 활용 머신러닝 모형 개발 ####
#### 단계 1. 병렬처리를 위한 패키지 불러오기  ####

## 병렬처리
# 주 목적: 속도 때문에 씀
# 원리 및 기타 설명은 다음 링크를 참고한다. 
# https://freshrimpsushi.tistory.com/1266

# 현재 자기 컴퓨터의 코어 개수를 반환한다

# 병렬처리에 쓸 코어를 등록한다. 
# 보통 50% 쓰는 것을 추천한다. (이유: 모형이 개발되는 동안 다른 간단한 작업도 해야 함)



#### 단계 2. 데이터 가져오기  ####

# 29091 8

#### 단계 3. 데이터 전처리 ####
# 결측치 확인


# 중복값 확인


# 데이터 타입 확인


# 사실 여기부터 모형 개발에 목적에 맞게 기저 범주를 하나씩 설정하며 봐야 하지만. 이 부분은 수강생 분들에게 맡기겠다. 

# 한꺼번에 하고 싶습니다. 


#### 단계 4. 데이터 분리 ####


#### 단계 5. 모형 controler 개발 ####
# caret 패키지의 특징


#### 단계 6. 데이터의 통계적인 전처리 ####
# feature engineering
# 각각에 대한 설명은 4일차에 진행함


## define x, y
## logistic regression


#### 단계 7.1. 모형 개발 - 로지스틱회귀 분석 ####

# 이전버전 
# saveRDS(logis, "R_NCS_2020/3_day/model/logis_model.rds") Version 3.6.3 까지 적용


#### 단계 7.2. 모형 개발 - 의사결정나무 ####


# Model Tunning Parameter
# 4일차에 설명 예정


# saveRDS(rpt, "../model/rpt_model.rds")

#### 단계 7.3. 모형 개발 - 랜덤포레스트 ####


# system.time은 시간을 재기 위한 것


#     user   system  elapsed 
#    29.168    5.071 1465.453 (초) # 24분 소요 (2 core 사용시)


# 랜덤포레스트의 경우 연산이 많아 시간이 오래걸리므로
# 모형을 저장하는 것이 중요함
# saveRDS(rft, "../model/rft_model.rds")


#### 단계 7.4. 모형 개발 - GBM(Stochastic Gradient Boosting Model) ####


# system.time은 시간을 재기 위한 것


#   user   system  elapsed 
# 83.955    9.091 4949.041 > core 2개 82분 소요 


# 부스팅의 경우 연산이 많아 시간이 오래걸리므로
# 모형을 저장하는 것이 중요함
# saveRDS(gbm, "../model/gbm_model.rds")


#### 단계 7.5. 모형 개발 - avNNet(인공신경망) ####


#  user   system  elapsed 
# 5.412    5.445 2014.847 33분


# 인공신경망의 경우 연산이 많아 시간이 오래걸리므로
# 모형을 저장하는 것이 중요함
# saveRDS(snn, "../model/snn_model.rds")

#### 단계 8. 모형 정확도 기준비교 ####

# 저장된 모형 가져오기 (R 3.6.3 버전 까지만 허용)
# logis <- readRDS("../model/logis_model.rds")
# rpt <- readRDS("../model/rft_model.rds")
# rft <- readRDS("../model/rft_model.rds")
# gbm <- readRDS("../model/gbm_model.rds")
# snn <- readRDS("../model/snn_model.rds")

# R 4.0.0 이후 버전


## compare models


# Final Model is SNN

# 단계 9. 모형 예측 및 AUC

## -- 
# AUC = Area Under Curve의 뜻으로


# 3_2와 비교해서 어떤 것이 성능이 더 좋은지 확인해보자. 
# preProcessing과 모형 튜닝을 과하게 사용하면 오히려 성능이 더 안좋을 수 있다. 
# 무조건 쓰는 것보다 중요한 것, 왜 써야 하는지에 통계적인 지식이 있지 않으면 오히려 시간대비 성능이 더 떨어질 수 있음을 명심하자! 



