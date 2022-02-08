#--------------------------------#
#### 1. 데이터 수집 ####
#--------------------------------#

iris <- iris
sepal_length <- iris$Sepal.Length
all_mean = mean(sepal_length) # 5.843333

#--------------------------------#
#### 2. 문제 1 ####
#--------------------------------#
# versicolor 종 데이터만 추출한다. 
new_df = subset(iris, Species=="versicolor")

# sepal_length의 평균과 표준편차를 구한다. 
mean_ver = mean(new_df$Sepal.Length)
sd_ver = sd(new_df$Sepal.Length)

# 문제, t-분포에 의하여 다음 가설검정에 해당하는 통계 분석을 실시하세요. 

# 귀무가설: 전체 데이터의 sepal_length의 평균과 versicolor sepal_length의 평균의 차이는 없다. 
# 대립가설: 전체 데이터의 sepal_length의 평균과 versicolor sepal_length의 평균의 차이는 있다. 

N = length(new_df$Sepal.Length)
t_val <- (mean_ver - all_mean) / (sd_ver / sqrt(N))

# 유의수준 및 임계값 구하기
alpha = 0.05 
c.u = qt(1-alpha, df = N-1) # 1.67655

# 유의확률
p_value = 1 - pt(t_val, df = N-1) 
p_value # [1] 0.1051389 x 2

# t.test 활용
t.test(new_df$Sepal.Length, mu = all_mean, alternative = "two.sided")


#--------------------------------#
#### 2. 문제 2 ####
#--------------------------------#
# 이번에는 setosa 종과 함께 평균 비교를 해본다. 

# versicolor 종 데이터만 추출한다. 
new_df = subset(iris, Species=="setosa")

# sepal_length의 평균과 표준편차를 구한다. 
mean_ver = mean(new_df$Sepal.Length)
sd_ver = sd(new_df$Sepal.Length)

# 문제, t-분포에 의하여 다음 가설검정에 해당하는 통계 분석을 실시하세요. 

# 귀무가설: 전체 데이터의 sepal_length의 평균과 versicolor sepal_length의 평균의 차이는 없다. 
# 대립가설: 전체 데이터의 sepal_length의 평균과 versicolor sepal_length의 평균의 차이는 있다. 

N = length(new_df$Sepal.Length)
t_val <- (all_mean - mean_ver) / (sd_ver / sqrt(N))

# 유의수준 및 임계값 구하기
alpha = 0.05 
c.u = qt(1-alpha, df = N-1) # 1.67655

# 유의확률
p_value = 1 - pt(t_val, df = N-1) 
p_value # [1] 0.1051389 x 2

# t.test 활용
t.test(new_df$Sepal.Length, mu = all_mean, alternative = "two.sided")

