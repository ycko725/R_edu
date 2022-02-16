#--------------------------------#
#### 1. 데이터 수집 ####
#--------------------------------#

# 가상의 두 데이터 검정
women_height <- c(138.9, 161.7, 172.3, 120.8, 165.4, 163.6, 147.4, 147.8, 148.3)
men_height <- c(167.2, 160.5, 166.4, 176, 189.3, 173.2, 167.1, 161.3, 162.4) 


data <- data.frame( 
  group = rep(c("Woman", "Man"), each = 9),
  height = c(women_height,  men_height)
)

#--------------------------------#
#### 2. 데이터 전처리 및 시각화 ####
#--------------------------------#

# 라이브러리 불러오기
library(dplyr)
library(reshape2)
library(ggplot2)


# 평균 및 표준편차 구하기
data %>% 
  group_by(group) %>% 
  summarise(
    count = n(), 
    mean  = mean(height), 
    sd    = sd(height)
  )

# 시각화
ggplot(data, aes(x = group, y = height)) + 
  geom_boxplot()

#--------------------------------#
#### 3. 사전 체크 ####
#--------------------------------#
# Q. 두개의 데이터는 서로 독립인가?
# A. 남자와 여자는 다름

# Q. 두개의 데이터는 각각 모두 정규성을 만족하는가? 
# 귀무가설: 데이터는 정규성을 만족한다. 
# 대립가설: 데이터는 정규성을 만족하지 않는다. 
shapiro.test(data[data$group == "Man", ]$height) # p = 0.09
shapiro.test(data[data$group == "Woman", ]$height) # p = 0.5347

# A. 모두 만족한다. 

# Q. 두개의 그룹은 같은 등분산성을 만족하는가? 
# 귀무가설: 두개 그룹의 분산은 서로 같다. 
# 대립가설: 두개 그룹의 분산은 서로 같지 않다. 
var.test(height ~ group, data = data) # p-value = 0.1382

# A. 두개 그룹의 분산은 서로 같다. 

#--------------------------------#
#### 3. t.test 검정 ####
#--------------------------------#
# 귀무가설: 여자 평균 키는 남자의 평균 키와 서로 같다. 
# 대립가설: 여자 평균 키는 남자의 평균 키와 서로 다르다. 

t.test(data$height ~ data$group, 
       mu = 0, 
       alternative = "two.sided", 
       var.equal = TRUE)


# t 통계량 2.8606
# df 자유도 16
# p-value 0.01133
# 결론: 남자의 평균키와 여자의 평균키는 통계적으로 유의하게 다르다. p-value = 0.01327