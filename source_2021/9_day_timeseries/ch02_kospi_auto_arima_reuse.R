# Step 01 ---- KOSPI 데이터 불러오기 ---- 


# KOSPI 지수의 ticker Symbol ^KS11
# 애플: AAPL
# 삼성전자: 005930.KS


# Step 02 ---- 정상성과 차분 ---- 
# ARIMA 정상성(Stationary)과 차분(Differencing)
# 정상성
# 참고자료: https://otexts.com/fppkr/stationarity.html
# -- 시간의 흐름에 영향을 받지 않음
# -- 계절성 및 추세가 있는 시계열은 정상성을 나타내는 시계열은 아님.
# 차분: 정상성이 없는 시계열에 정상성을 나타낼 수 있도록 만드는 방법.  
# -- 추세나 계절성이 제거(또는 감소)됨. 
# -- 차분 계산식: y = y(t) - y(t-1) 
# 정상성 확인하는 방법: 자기상관함수(Auto Correlation Function: ACF) 
# -- 정상성이 있다면 ACF가 0으로 비교적 빠르게 떨어짐
# 단위근 검정(Unit Root Tests): 차분을 할지, 또는 얼마나 많이 해야 할지 판단. 
# -- 단위근 검정 수행 위해서는 URCA 패키지 활용.
# -- KPSS 단위근 검정 사용
# -- 참고자료: https://otexts.com/fppkr/stationarity.html#%EB%8B%A8%EC%9C%84%EA%B7%BC%EA%B2%80%EC%A0%95

# Step 03 ---- 정상성과 차분 ---- 

# Step 04 ---- Auto Arima 활용하기 ---- 
# 주요 참고자료: https://otexts.com/fppkr/arima-r.html
# 그래프 재 확인하기


# 모형 적합


# 결과값 해석


## ---- (1) 잔차 확인 ---- 
# 참고자료: https://otexts.com/fppkr/residuals.html
# 잔차의 평균은 0이어야 하며, 0이 아닌 경우 예측값이 한쪽으로 편향됨. 
# 잔차를 확인했을 때, 자기상관이 없어야 함, 자기상관인 경우 추가 정보가 남아있는 것. 


# p-value > 0.05 자기상관성이 없음
# p-value < 0.05 자기상관성이 존재 

## ---- (2) 예측 ----



## 최종모형 선정
# - ARIMA 모형은 모델의 차수(p, d, q)를 추정하는 것이 중요
# - arima 함수 이용 시, AIC, AICc, BIC 정보를 읽고 모델 결정
# - 세 정보를 최소화할 경우 가장 좋은 모델
# - 차분의 횟수는 KPSS 검정을 통해 미리 정하고 남은 부분은 여러모델을 비교 검정하여 최적의 모델을 찾아내는 것 뿐이다. 
