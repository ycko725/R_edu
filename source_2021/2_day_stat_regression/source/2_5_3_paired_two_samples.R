#--------------------------------#
#### 1. 데이터 수집 ####
#--------------------------------#

# 쥐 실험 몸무게 데이터 샘플
data <- read.csv("paired_t_test.csv")
print(data)

#--------------------------------#
#### 2. 데이터 전처리 및 시각화 ####
#--------------------------------#

# 라이브러리 불러오기
library(dplyr)
library(reshape2)
library(ggplot2)

data2 = melt(data, 
             measure.vars = c("Prior", "Post"),
             variable.name = "group", 
             value.name= "weight")

# 평균 및 표준편차 구하기
data2 %>% 
  group_by(group) %>% 
  summarise(
    count = n(), 
    mean  = mean(weight), 
    sd    = sd(weight)
  )

# 시각화
ggplot(data2, aes(x = group, y = weight)) + 
  geom_boxplot()

#--------------------------------#
#### 3. 사전 체크 ####
#--------------------------------#
# 표본의 개수가 30개보다 적으면 정규성 검정를 진행한다. 
# 귀무가설: 데이터는 정규분포를 이룬다
# 대립가설: 데이터는 정규분포를 이루고 있지 않다. 

data3 <- data %>% 
  mutate(differences = Prior - Post)

shapiro.test(data3$differences)

# p-value가 0.5156은 귀무가설 채택
# 데이터는 정규분포를 이룸. 

#--------------------------------#
#### 3. t.test 검정 ####
#--------------------------------#
# 귀무가설: 00치료법은 쥐 몸무게 변화에 영향이 없다
# 대립가설: 00치료법은 쥐 몸무게 변화에 영향을 준다
t.test(data$Prior, data$Post, paired = TRUE, alternative = "two.sided")

# 검정 통계량 (-4.1849)
# P-value (0.0007003)
# 00치료법은 쥐 몸무게 변화에 영향을 준다.

# 만약, 치료법 전후 몸무게 측정을 하고 싶다면, 
# 치료법 전 몸무게 < 치료법 후 몸무게: less 
# 치료법 전 몸무게 > 치료법 후 몸무게: greater

#--------------------------------#
#### 4. Manual 검정 ####
#--------------------------------#

N <- length(data$Prior - data$Post)
df_mean <- mean(data$Prior - data$Post) # 평균
df_sd   <- sd(data$Prior - data$Post) # 표준편차
t_statistic <- df_mean / (df_sd / sqrt(N))
# t = -4.1849

pt(t_statistic, df=N-1) * 2
# [1] 0.0007002531
