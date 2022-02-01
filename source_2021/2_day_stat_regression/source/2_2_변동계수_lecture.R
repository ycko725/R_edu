#--------------------------------#
#### 변동계수 구하기 ####
#--------------------------------#
# 두 자료의 측정 단위가 달라 평균의 차이로 인해 두 자료의 분포를 직접 비교할 수 없을때 사용

# 변동계수 
# cv = sd(data) / mean(data) * 100

# 주식 데이터
library(tidyquant)
library(quantmod)
library(purrr)
library(ggplot2)
library(tibble)

tickers = c("AAPL", "TSLA")
getSymbols(tickers,
           from = "2022-01-02",
           to = "2022-01-30")

stock <- map(tickers, function(x) Ad(get(x)))
stock <- reduce(stock, merge)
colnames(stock) <- tickers

head(stock)
tail(stock)

stock_df <- stock %>% data.frame(date = index(stock))
stock_df

cv_fun <- function(data) {
  result = sd(data) / mean(data) * 100
  return(result)
}

# 통계 수치
cv_fun(stock_df$AAPL) # 4.034862
cv_fun(stock_df$TSLA) # 9.46726

# 시각화
ggplot(stock_df, aes(x = date)) + 
  geom_line(aes(y = AAPL, colour = "Apple")) + 
  geom_line(aes(y = TSLA, colour = "Tesla")) + 
  scale_color_manual(name = "company", 
                     values = c("Apple" = "red", 
                                "Tesla" = "darkblue")) + 
  theme_bw()

class_A = c(160, 170, 180, 190, 200) # 키 cm 
sd(class_A) # 표준 편차 큼

class_B = c(1.6, 1.7, 1.8, 1.9, 2.0) # 키 m
sd(class_B) # 표준 편차 작음


cv_fun(class_A)
cv_fun(class_B)
