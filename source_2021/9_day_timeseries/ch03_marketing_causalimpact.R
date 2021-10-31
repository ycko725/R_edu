# ---- Thesis Review ----
# -- 참고: https://google.github.io/CausalImpact/CausalImpact.html
# -- Paper: https://research.google/pubs/pub41854/
# 논문 주요 핵심
# - pre and post-treatment time series of predictor variables 
# --> 특정 이벤트 전후 전체 기간의 데이터를 바탕으로 학습, 이벤트가 없었을 경우를 시뮬레이션 함
# Causal Impact 로직
# - 정책 변경과 같은 개입(intervention)이 있는 시계열 관측치 데이터 Y 필요
# - 연관된 다른 변수 준비 (예: 노동 시장, 날씨, 구글 트렌드 등)
# - 여러 변수를 동시에 사전 요인으로 사용해, 이 요인들이 얼마나 Y에 영향을 끼치는지, 변수들은 서로 어떻게 영향을 미치는지 파악, 그 기반으로 Y가 어떻게 변화할지 예측
# 주요 가정
# - Y와 변수의 관계는 개입(intervention)이 없었다면 계속되었을 것이다. 
# 자세한 것은 https://storage.googleapis.com/pub-tools-public-publication-data/pdf/41854.pdf 에서 확인할 것. 


# Step 01 ---- KOSPI 데이터 불러오기 ---- 
library(quantmod)
library(dplyr)
library(CausalImpact)
library(zoo)

options(scipen = 100)

# KOSPI 지수의 ticker Symbol ^KS11
# 애플: AAPL
# 삼성전자: 005930.KS
KOSPI = getSymbols("^KS11",
                   from = "2020-01-01",
                   to = Sys.time(),
                   auto.assign = FALSE)

# 데이터 확인
# 날짜, 시가(Open), 고가(High), 저가(Low), 종가(Close), 거래량(Volume), 수정가(Adjusted)
# 기업의 활동을 주식의 가치에 반영하고자 종가를 보정하는 것을 수정가라 함
# 배당, 액변분할, 증자, 감자와 같은 이슈 (CRSP: Center for Research in Security Prices)
# 따라서 분석에서는 주로 수정가를 활용함. 

# Step 02 ---- 데이터 가공 ---- 
str(KOSPI)

# 시가보다 종가가 높을 경우 "up", 시가가 종가보다 낮을 경우 "down"
sample = data.frame(date = time(KOSPI),
                    KOSPI,
                    growth = ifelse(Cl(KOSPI) > Op(KOSPI),
                                    "up", "down"))

colnames(KOSPI)

# 컬럼명 변경
colnames(sample) = c("date", "Open", "High", "Low",
                     "Close", "Volume", "Adjusted", "growth")

# 데이터 확인
glimpse(sample)
summary(sample)

data = sample %>% 
  dplyr::select(date, Close, Volume)

data2 = na.omit(data)
start = "2020-01-01"
end = "2020-03-31"

data3 = data2 %>% 
  filter(date > start & date < end) %>% 
  read.zoo()

data3

# 1차 코로나 확산 이전 데이터 확률
pre.period = as.Date(c(start, "2020-02-20"))

# 대구 락다운 발표 조치 이후 (이벤트!)
post.period = as.Date(c("2020-02-28", end))

# 모형 학습
impact = CausalImpact(data3, pre.period, post.period)
plot(impact)
summary(impact)
impact$report
impact$summary

# 결론: 코로나 대확산이 없었다면 주가의 대폭락은 없었을 것 
# 마케팅에의 적용

# 마케팅 데이터셋 sample
library(datarium)
data(marketing)
glimpse(marketing)

marketing2 = marketing %>% 
  mutate(dates = seq(as.Date("2021-01-01"), by = "day", length.out = 200)) %>% 
  dplyr::select(dates, sales, everything()) %>% 
  read.zoo()

start = "2020-01-01"
end = "2021-07-19"

pre.period = as.Date(c(start, "2021-04-01"))
post.period = as.Date(c("2021-04-10", end))

impact = CausalImpact(marketing2, pre.period, post.period)
plot(impact)
summary(impact)
