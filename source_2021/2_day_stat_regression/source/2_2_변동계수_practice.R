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

stock_df <- stock %>% data.frame(date = index(stock))
stock_df

cv_fun <- function(data) {
  result = sd(data) / mean(data) * 100
  return(result)
}

cv_fun(stock_df$AAPL) # 4.034862
cv_fun(stock_df$TSLA) # 9.46726

ggplot(stock_df, aes(x = date)) + 
  geom_line(aes(y = AAPL, colour = "Apple")) + 
  geom_line(aes(y = TSLA, colour = "Tesla")) + 
  scale_color_manual(name = "Company", values = c("Apple" = "red", "Tesla" = "darkblue")) + 
  theme_bw()

