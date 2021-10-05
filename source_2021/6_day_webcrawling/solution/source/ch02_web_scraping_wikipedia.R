library(httr)
library(rvest)
library(dplyr)
library(ggplot2)

# 사이트 확인
res <- GET('https://en.wikipedia.org/wiki/Anscombe%27s_quartet')

# HTTP 응답 결과 확인
print(x = res)

# 상태 코드 확인
status_code(res)

# 테이블 데이터 가져오기
# 참조: https://adv-r.hadley.nz/functions.html
res %>% 
  read_html() %>% 
  html_nodes(".wikitable") %>% 
  `[[`(2) %>% 
  html_table() %>% 
  setNames(., c("x1", "y1", "x2", "y2", "x3", "y3", "x4", "y4")) %>% 
  slice(-1) %>% 
  select(x1, x2, x3, x4, y1, y2, y3, y4) %>% 
  mutate_if(is.character, as.double) -> anscombe

## summary
summary(anscombe)
apply(anscombe, 2, sd)

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
ggplot(anscombe) +
  geom_point(aes(x1, y1), color = "red", size = 1) +
  geom_abline(intercept = 3.0001, slope = 0.5001, color = "green") + 
  scale_x_continuous(breaks = seq(0,18,2)) +
  scale_y_continuous(breaks = seq(0,12,2)) +
  labs(x = "x1", y = "y1",
       title = "Dataset 1" ) +
  theme_bw()

