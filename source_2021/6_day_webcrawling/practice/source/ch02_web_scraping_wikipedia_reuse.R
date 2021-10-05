library(httr)
library(rvest)
library(dplyr)
library(ggplot2)

# 사이트 확인


# HTTP 응답 결과 확인


# 상태 코드 확인


# 테이블 데이터 가져오기
# 참조: https://adv-r.hadley.nz/functions.html


## summary


## 선형회귀계수
ls_fit <- function(x) {
  result <- lsfit(anscombe[, x], anscombe[, x+4])
  result$coefficients
}

sapply(1:4, ls_fit)

## 상관계수
sapply(1:4, function(x) cor(anscombe[, x], anscombe[, x+4]))

## R^2
sapply(1:4, function(x) cor(anscombe[, x], anscombe[, x+4])^2)

## 시각화


