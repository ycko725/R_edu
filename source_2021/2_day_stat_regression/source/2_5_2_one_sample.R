#--------------------------------#
#### 1. 문제 ####
#--------------------------------#

# 사건 개요
# 00 과자 가격의 무게는 150g으로 표시가 되어 있음
# 총 10개의 과자를 구매한 결과, 평균 148g, 표준편차는 7.5g으로 판명됨
# 실제 과자의 평균 무게는 150g 아닌지 검정한다. 

pop_mean    = 150
sample_mean = 145
sd          = 7.5
N           = 10

t_val = (sample_mean-pop_mean) / (sd / sqrt(N))
t_val

p.value <- pt(t_val, df=N-1) * 2
p.value



#--------------------------------#
#### 1. 문제 ####
#--------------------------------#
# 단일 모집단의 비율에 대한 가설 검정
# 가설 설정
# 귀무가설: 핸드폰 액정의 불량률은 10% 미만이다
# 대립가설: 핸드폰 액정의 불량률은 10%를 넘는다
# 데이터 현황
# 표본의 수는 200개, 총 22개가 불량으로 확인됨

N               = 200
defec_prod      = 22 
pop_def_rate    = 0.1
sample_def_rate = 22 / 200

z = (sample_def_rate - pop_def_rate) / sqrt(pop_def_rate*(1 - pop_def_rate) / N)

alpha <- 0.05
(c.u <- qnorm(1-alpha) )
(p.value <- 1 - pnorm(z) )

# prop.test
prop.test(defec_prod, N, p = 0.1, alternative = "greater", correct = FALSE)


#--------------------------------#
#### 2. 데이터 수집 ####
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
# 왼쪽 검정 (less)
# 오른쪽 검정 (greater)


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


