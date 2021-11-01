# Step 01 ---- KOSPI 데이터 불러오기 ---- 
library(quantmod)
library(dplyr)
library(ggplot2)

# KOSPI 지수의 ticker Symbol ^KS11
# 애플: AAPL
# 삼성전자: 005930.KS
KOSPI = getSymbols("AAPL",
                   from = "2001-01-01",
                   to = Sys.time(),
                   auto.assign = FALSE)

# 데이터 확인
# 날짜, 시가(Open), 고가(High), 저가(Low), 종가(Close), 거래량(Volume), 수정가(Adjusted)
# 기업의 활동을 주식의 가치에 반영하고자 종가를 보정하는 것을 수정가라 함
# 배당, 액변분할, 증자, 감자와 같은 이슈 (CRSP: Center for Research in Security Prices)
# 따라서 분석에서는 주로 수정가를 활용함. 

head(KOSPI)

tail(KOSPI)

# 삼성전자
SEC = getSymbols("005930.KS",
                 from = "2015-01-01",
                 to = "2021-01-01",
                 auto.assign = FALSE)

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

# Step 03 ---- 데이터 시각화 ---- 
# 시각화
ggplot(sample, aes(x = date)) +
  geom_line(aes(y = Low))

ggplot(sample %>% filter(date >= "2020-01-01"), 
       aes(x = date)) +
  geom_line(aes(y = Low))

# 날짜기간 정리
sample[sample$date >= "2020-04-01" & sample$date <= "2020-06-30",]

ggplot(sample[sample$date >= "2001-01-01",], aes(x = date)) +
  geom_linerange(aes(ymin = Low, ymax = High))

ggplot(sample[sample$date >= "2001-01-01",], aes(x = date)) +
  geom_linerange(aes(ymin = Low, ymax = High)) +
  geom_rect(aes(xmin = date - 0.3,
                xmax = date + 0.3,
                ymin = pmin(Open, Close),
                ymax = pmax(Open, Close),
                fill = growth))

ggplot(sample[sample$date >= "2021-10-01",], aes(x = date)) +
  geom_linerange(aes(ymin = Low, ymax = High)) +
  geom_rect(aes(xmin = date - 0.3,
                xmax = date + 0.3,
                ymin = pmin(Open, Close),
                ymax = pmax(Open, Close),
                fill = growth)) +
  guides(fill = "none") +
  scale_fill_manual(values =c("down" = "blue", "up" = "red")) +
  labs(
    title = "KOSPI",
    subtitle = "2020-01-01 ~ 2021-10-29"
  ) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(hjust = 1),
        axis.title = element_blank(),
        axis.line.x.bottom = element_line(color = "grey"),
        axis.ticks = element_line(color = "grey"),
        axis.line.y.left = element_line(color = "grey"),
        plot.background = element_rect(fill = "white"),
        panel.background = element_rect(fill = "white")
  )

## 삼성전자 그래프 그려볼 것

## 애플주가 그래프 그려볼 것

# Step 04 ---- 시계열 데이터 이해 ----
# KOSPI는 다양한 요인에 의해 변동 (예: 금리, 통화 정책, 유가 등)
# 지수에 영향을 주는 대표적 요인
# -- KOSPI = f(금리, 통화 정책, 유가, 그외 요인)
# 미래 예측하는 형태의 모델 제시 
# 2일전 KOSPI 지수는 1일전, 1일전 KOSPI 지수는 오늘
# -- KOSPI = f(KOSPI-t-1, KOSPI-t-2, KOSPI-t-3, ..., 그외 요인)

# 시계열의 구성 요소
# 주요 참고자료: https://otexts.com/fppkr/
# 시계열 데이터: 계절성 요인(Seasonal), 추세-순환 요인(Trend-Cycle), 불규칙 요인(Remainder)
# 계절성 요인: 같은 해 또는 같은 분기 특정 기간에 유사한 패턴을 반복하는 경우 지칭
# -- 예) 따듯한 아메리카노 판매량 (여름 감소, 겨울 증가)
# 추세-순환요인: 주가 지수가 시간이 지남에 따라 꾸준히 상승하거나 하락하는 것
# 불규칙 요인: 측정하거나 예측하기 어려운 요인 의미 
# 코스피 지수 특징
# 2000년 이후에 꾸준히 상승
# 2008년 9월 국제금융위기 하락
# 2020년 전고대비 반으로 줄어듬 (코로나)

KOSPI = getSymbols("^KS11",
                   from = "2001-01-01",
                   to = Sys.time(),
                   auto.assign = FALSE)

str(KOSPI)

KOSPI_C = na.omit(KOSPI$KS11.Close)
KOSPI_C = as.numeric(KOSPI_C)

# frequency: https://otexts.com/fppkr/graphics-ts-objects.html
ts_KOSPI_C = ts(data = KOSPI_C, frequency = 365)
class(ts_KOSPI_C)
# [1] "ts"

# 가법모형 시계열 분해
# yt = 계절성 요인(S) + 추세 순환 요인(T) + 불규칙 요인(R)
?decompose
de_data_add = decompose(ts_KOSPI_C,
                        type = "additive") # 가법모형

str(de_data_add)

# 가법모형 시계열 분해 시각화
plot(de_data_add)

# 승법 모형 시계열 분해
# yt = 계절성 요인(S) x 추세 순환 요인(T) x 불규칙 요인(R)
de_data_multi = decompose(ts_KOSPI_C,
                          type = "multiplicative") # 승법모형

str(de_data_multi)

# 승법모형 시계열 분해 시각화
plot(de_data_multi)

# 고전적인 시계열 분해 방법의 이슈 
# 참조: https://otexts.com/fppkr/classical-decomposition.html
# 계절성 요인, 한 해를 기준으로 반복해서 발생한다 가정 (일상생활에서?)
# 처음 몇개와 마지막 몇 개의 관측값에 대한 추세 추정값 얻을 수 없음

# Step 05  ---- 단순 선형 회귀 & 다중 선형 회귀 ----
# 단순 선형 회귀: y = b + b1*x + e 
# -- 계수 b는 x가 0일 때의 y의 값 (절편)
# -- b1는 기울기이며 x가 1단위만큼 증가했을 때 y의 변화

# Step 06 ---- 시계열 회귀 모형 ----
# 추세 요인 반영
# y = b0 + b1(추세 요인t) + b2(계절성 요인t) + et
# t = 1, ..., T(시간)
# tslm() 함수 이용 (trend) & 계절성 요인(Season)

## (1) ---- 추세 요인 반영 하기 ---- 
KOSPI = getSymbols("^KS11",
                   from = "2020-01-01",
                   to = "2021-01-31",
                   auto.assign = FALSE)

head(KOSPI)

ggplot(KOSPI, aes(x = time(KOSPI), y = KS11.Close)) +
  geom_line()

# ts 객체로 변환
ts_data = ts(data = as.numeric(KOSPI$KS11.Close),
             frequency = 5) # 주 5일 반영
ts_data 

library(forecast)
fit_lm = tslm(ts_data ~ trend)
fit_lm

summary(fit_lm)

ggplot(KOSPI, aes(x = time(KOSPI), y = KS11.Close)) +
  geom_line() +
  geom_line(y = fit_lm$fitted.values, color = "grey") + 
  theme_minimal()

# 예측값 대입
pred = data.frame(forecast(fit_lm, h = 20),
                  stringsAsFactors = FALSE)

# 예측값 시각화
ggplot(pred, aes(x = index(pred), y = Point.Forecast)) +
  geom_line() +
  geom_ribbon(aes(ymin = Lo.95, ymax = Hi.95), alpha = 0.25) +
  geom_ribbon(aes(ymin = Lo.80, ymax = Hi.80), alpha = 0.5) + 
  theme_minimal()

## (2) ---- 계절성 요인 반영 하기 ---- 
KOSPI = getSymbols("^KS11",
                   from = "2020-01-01",
                   to = "2021-01-31",
                   auto.assign = FALSE)

head(KOSPI)

# 객체 변환
ts_data = ts(data = as.numeric(KOSPI$KS11.Close),
             frequency = 12)

# 모형 적합
fitted = tslm(ts_data ~ trend + season)
fitted

summary(fitted)

# 예측값 대입
pred = data.frame(forecast(fitted, h = 20),
                  stringsAsFactors = FALSE)

# 예측값 시각화
ggplot(pred, aes(x = index(pred), y = Point.Forecast)) +
  geom_line() +
  geom_ribbon(aes(ymin = Lo.95, ymax = Hi.95), alpha = 0.25) +
  geom_ribbon(aes(ymin = Lo.80, ymax = Hi.80), alpha = 0.5) + 
  theme_minimal()

## (3) ---- 가변수 활용하기 ---- 
ts_data = ts(data = as.numeric(KOSPI$KS11.Close),
             frequency = 20)


# 코로나 급락시점은 0으로 맞춤
t = time(ts_data)
t.break = data.frame(t, ts_data)

t.break[t.break$t < 3.65,] = 0
t.break[t.break$t > 3.75,] = 0

tb1 = ts(t.break$t, frequency = 20)

# 기존 방식
fit.t = tslm(ts_data ~ t)

# 아카이케의 정보기준
# 참고자료: https://otexts.com/fppkr/selecting-predictors.html
AIC(fit.t)


# 가변수를 활용한 방식
fit.tb = tslm(ts_data ~ t + I(t^2) + I(t^3) + I(tb1^3))
AIC(fit.tb)

# 두 데이터의 
ggplot(ts_data, aes(x = time(ts_data))) +
  geom_line(aes(y = ts_data)) +
  geom_line(aes(y = fit.t$fitted.values),
            color = "#A37E03", size = 1) +
  geom_line(aes(y = fit.tb$fitted.values),
            color = "#0A29F0") + 
  theme_minimal()

new = data.frame(t = t[length(t)] + seq(1, by = 0.05, length.out = 20))

forecast(fit.t, newdata = new)

# 7.6  auto.arima를 이용하여 KOSPI 지수 예측하기
# 7.6.1  정상성과 차분
library(urca)

KOSPI = getSymbols("^KS11",
                   from = "2020-01-01",
                   to = "2021-01-31",
                   auto.assign = FALSE)

ts_kospi = ts(as.numeric(KOSPI$KS11.Close), frequency = 20)

ur_test = ur.kpss(ts_kospi)

summary(ur_test)

dif_1 = diff(ts_kospi, differences = 1)
ur_test2 = ur.kpss(dif_1)
ur_test2

dif_2 = diff(ts_kospi, differences = 2)
ur_test3 = ur.kpss(dif_2)
summary(ur_test3)

log_dif_2 = diff(log(ts_kospi), differences = 2)
ur_test4 = ur.kpss(log_dif_2)
summary(ur_test4)

# 7.6.2  auto.arima 활용하기
ggplot(ts_kospi, aes(x = time(ts_kospi))) +
  geom_line(aes(y = ts_kospi))

library(forecast)
fit = auto.arima(ts_kospi)

fit

checkresiduals(fit)

fore = data.frame(forecast(fit, h = 5))
fore

ggplot(fore, aes(x = index(fore), y = Point.Forecast)) +
  geom_line() +
  geom_ribbon(aes(ymin = Lo.95, ymax = Hi.95), alpha = 0.25) +
  geom_ribbon(aes(ymin = Lo.80, ymax = Hi.80), alpha = 0.5)