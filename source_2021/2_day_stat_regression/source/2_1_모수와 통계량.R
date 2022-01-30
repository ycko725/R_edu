#--------------------------------#
#### 1. 음반 판매량 데이터 수집 ####
#--------------------------------#
albums = read.csv("album.csv")
str(albums)

#--------------------------------#
#### 2. 최댓값과 최솟값 ####
#--------------------------------#
# 앨범 판매량의 최솟값과 최댓값을 구한다. 
albums$sales

sort(albums$sales) # 오름차순
sort(albums$sales)[1] # 최솟값
sort(albums$sales)[200] # 최댓값
sort(albums$sales)[length(albums$sales)] # 최댓값
sort(albums$sales, decreasing = TRUE)[1] # 최댓값

min(albums$sales)
max(albums$sales)

#--------------------------------#
#### 3. 최빈값 ####
#--------------------------------#
table(albums$sales)
sort(table(albums$sales), decreasing = TRUE)[1]

#--------------------------------#
#### 4. 평균과 중앙값 ####
#--------------------------------#
sales = albums$sales
weight = (1/length(sales)) 
sum(sales * weight)
mean(sales)


# 결측치 데이터 추가
sales = c(sales, NA)
tail(sales, n = 4)
mean(sales)
mean(sales, na.rm = TRUE)

# which(x)
# 논리를 전달 받아 참값의 인덱스를 반환함
which(sales == 190)
x = 1:4
x%%2 == 0
which(x%%2 == 0)
sales == 190
which(sales >= 200)
which((sales > 200) & (sales <= 211))
sales[8]

# 평균의 가장 큰 단덤은 양 끝 값의 변화에 대해 민감하게 반응하는 것
sales = albums$sales
mean(sales) # [1] 193.2

sales = c(sales, 3000000)
# 값 하나 추가되었지만, 평균 값이 처음보다 매우 크게 상승함
sales
mean(sales) # 15117.61 <- 193.2

# 중앙값은 극단값이 들어와도 큰 변동성이 없는 것을 의미
sales = albums$sales
median(sales) # 200


# 극단값 추가
sales = c(sales, 3000000)
median(sales) # 200


# 중앙값은 양 끝 값의 변화에 민감하게 반응하지 않음. 
# 이러한 특징을 강건하다(robust)라고 함. 
#--------------------------------#
#### 5. 표준편차 ####
#--------------------------------#

# 분산 구하기
weight = c(64, 68, 70, 72, 76)
weight_mean = mean(weight) # 70
weight_deviation = weight - weight_mean
sum(weight_deviation)

weight_deviation_2 = weight_deviation ^ 2
sum(weight_deviation_2)
mean(weight_deviation_2) # 분산값 16


# 표준편차 구하기
sqrt(mean(weight_deviation_2)) # 표준편차 4

# R의 내장 함수
var(weight) # 분산값 20 # 표본의 분산
sd(weight) # 4.472136 # 표본의 표준편차


# 대선 여론조사
# 표본(=Sampling)
# 모집단의 분산
var(weight) * (4/5)


# 모집단의 표준편차
sqrt((4)/5) * sd(weight) 
