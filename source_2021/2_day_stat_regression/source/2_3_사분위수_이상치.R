#--------------------------------#
#### 1. 음반 판매량 데이터 수집 ####
#--------------------------------#
albums = read.csv("album.csv")
str(albums)

#--------------------------------#
#### 2. 사분위수 ####
#--------------------------------#
quantile(albums$sales)

# 25%  --> 1사분위 (Q1)
# 50%  --> 2사분위 (Q2) == 중앙값
# 75%  --> 3사분위 (Q3)
# 100% --> 4사분위 (Q4)

qs_df <- quantile(albums$sales)
qs_df

qs_df[4] - qs_df[2] # 3사분위에서 제1사분위를 뺀 값 출력
IQR(albums$sales)

# 시각화
boxplot(albums$sales)

#--------------------------------#
#### 3. 이상치 판별 ####
#--------------------------------#

# 상한 극단값 추가
sales2 = c(albums$sales, 450, 460, -100, -1000)

# q1 - 1.5*(q3 - q1) # 하한 극한값 경계 
# q3 + 1.5*(q3 - q1) # 상한 극한값 경계

q = quantile(sales2)
q


# 하한 극단 경계값 찾기
bottom_outlier = q[2] - 1.5 * (q[4] - q[2])

# 상한 극단 경계값 찾기
top_outlier    = q[4] + 1.5 * (q[4] - q[2])
top_outlier

# 실제 극단값 존재하는지 출력
sales2[sales2 < bottom_outlier] # 
# [1]  -100 -1000

sales2[sales2 > top_outlier]

# 시각화
boxplot(sales2)

