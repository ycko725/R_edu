# install.packages("quantmod")
# 라이브러리 불러오기
# https://finance.yahoo.com/quote/%5EKS11?p=^KS11&.tsrc=fin-srch

library(quantmod)
library(ggplot2)

# Data
KOSPI = getSymbols("^KS11", 
                   from = "2001-01-01", 
                   to = Sys.time(), 
                   auto.assign = FALSE)

# 데이터 미리보기
head(KOSPI)

# 데이터 프레임으로 변환
str(KOSPI)

sample = data.frame(date = time(KOSPI), 
                    KOSPI, 
                    growth = ifelse(Cl(KOSPI) > Op(KOSPI), "up", "down"))

colnames(sample) = c("date", "Open", "High", "Low", "Close", "Volume", "Adjusted", "growth")

# summary()
summary(sample)

# 시각화
ggplot(sample, aes(x = date)) + 
  geom_line(aes(y = Low)) + 
  theme_minimal()

