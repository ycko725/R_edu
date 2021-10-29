library(httr)  # 요청
library(rvest) # 데이터 추출
library(dplyr) # 데이터 가공 
library(ggplot2) # 데이터 시각화

# 사이트 확인
res = GET('https://en.wikipedia.org/wiki/Anscombe%27s_quartet')
  
  
# HTTP 응답 결과 확인
print(x = res)

# 상태 코드 확인
status_code(res)

# 테이블 데이터 가져오기
#mw-content-text > div.mw-parser-output > table:nth-child(11)
#//*[@id="mw-content-text"]/div[1]/table[2]
# 참조: https://adv-r.hadley.nz/functions.html

res %>% 
  read_html() %>% 
  html_nodes("table.wikitable") %>% 
  `[[`(2) %>% 
  html_table() %>% 
  setNames(., c("x1", "y1", "x2", "y2", "x3", "y3", "x4", "y4")) %>% 
  slice(-1) %>% 
  select(x1, x2, x3, x4, y1, y2, y3, y4) %>% 
  mutate_if(is.character, as.double) -> anscombe

glimpse(anscombe)

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
  geom_point(aes(x1, y1), color = "#FFA601", size = 2) + 
  geom_abline(intercept = 3.00, slope = 0.500, color = "#9998FF") + 
  scale_x_continuous(breaks = seq(2, 20, 2)) + 
  scale_y_continuous(breaks = seq(2, 16, 2)) + 
  theme_bw() -> p1

ggplot(anscombe) + 
  geom_point(aes(x2, y2), color = "#FFA601", size = 2) + 
  geom_abline(intercept = 3.00, slope = 0.500, color = "#9998FF") + 
  scale_x_continuous(breaks = seq(2, 20, 2)) + 
  scale_y_continuous(breaks = seq(2, 16, 2)) + 
  theme_bw() -> p2

ggplot(anscombe) + 
  geom_point(aes(x3, y3), color = "#FFA601", size = 2) + 
  geom_abline(intercept = 3.00, slope = 0.500, color = "#9998FF") + 
  scale_x_continuous(breaks = seq(2, 20, 2)) + 
  scale_y_continuous(breaks = seq(2, 16, 2)) + 
  theme_bw() -> p3

ggplot(anscombe) + 
  geom_point(aes(x4, y4), color = "#FFA601", size = 2) + 
  geom_abline(intercept = 3.00, slope = 0.500, color = "#9998FF") + 
  scale_x_continuous(breaks = seq(2, 20, 2)) + 
  xlim(4, 20) + 
  scale_y_continuous(breaks = seq(2, 16, 2)) + 
  theme_bw() -> p4

library(gridExtra)
grid.arrange(p1, p2, p3, p4)

