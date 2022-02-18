# 라이브러리 불러오기
library(dplyr)
library(ggplot2)

# 데이터 수집 및 가공
my_data = PlantGrowth
my_data$group <- ordered(my_data$group,
                         levels = c("ctrl", "trt1", "trt2"))

my_data %>% 
  group_by(group) %>% 
  summarise(
    count = n(),
    mean = mean(weight, na.rm = TRUE),
    sd = sd(weight, na.rm = TRUE)
  )
  
# 시각화
ggplot(my_data, aes(x = group, y = weight)) + 
  geom_boxplot() 

## One-Way ANOVA 테스트 
# 통계량 계산 및 오차 제곱합 구하기
# 오차제곱합(SSE)
ctrl <- my_data$weight[my_data$group == "ctrl"]
trt1 <- my_data$weight[my_data$group == "trt1"]
trt2 <- my_data$weight[my_data$group == "trt2"]

ctrl_mean = mean(ctrl)
trt1_mean = mean(trt1)
trt2_mean = mean(trt2)

ctrl_sse <- sum((ctrl - ctrl_mean)^2)
trt1_sse <- sum((trt1 - trt1_mean)^2)
trt2_sse <- sum((trt2 - trt2_mean)^2)

# 오차의 제곱합
sse <- ctrl_sse + trt1_sse + trt2_sse
print(sse)

# 오차의 자유도
dfe <- (length(ctrl) - 1) + (length(trt1) - 1) + (length(trt2) - 1)

# 처리의 제곱합 구하기 (SST)
total_mean = mean(my_data$weight)
ctrl_sst = length(ctrl) * sum((ctrl_mean - total_mean) ^ 2)
trt1_sst = length(ctrl) * sum((trt1_mean - total_mean) ^ 2)
trt2_sst = length(ctrl) * sum((trt2_mean - total_mean) ^ 2)

# 처리제곱합
sst = ctrl_sst + trt1_sst + trt2_sst

# 처리제곱합의 자유도
dft = length(levels(my_data$group)) - 1

# 전체제곱합과 분해된 제곱합의 합 구하기
tsq = sum((my_data$weight - total_mean)^2)
ss  = sst + sse

# 만약 숫자가 같다면, TRUE 
all.equal(tsq, ss)


# 검정통계량 구하기
mst = sst / dft
mse = sse / dfe

f.t = mst / mse

alpha = 0.05
tol <- qf(1-alpha, 2, 27)

p.value = 1-pf(f.t, 2, 27)
p.value

# ANOVA 함수
res.aov <- aov(weight ~ group, data = my_data)
summary(res.aov)
