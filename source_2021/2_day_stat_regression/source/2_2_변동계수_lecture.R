#--------------------------------#
#### 변동계수 구하기 ####
#--------------------------------#

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
           to = "2022-01-31")

stock <- map(tickers, function(x) Ad(get(x)))
stock <- reduce(stock, merge)
colnames(stock) <- tickers

head(stock)



