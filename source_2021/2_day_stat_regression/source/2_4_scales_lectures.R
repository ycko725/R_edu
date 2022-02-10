#--------------------------------#
#### 1. 음반 판매량 데이터 수집 ####
#--------------------------------#
albums = read.csv("album.csv")

#--------------------------------#
#### 2. scale() 함수 적용 ####
#--------------------------------#
z_score_sales = scale(albums$sales)

#--------------------------------#
#### 3. 기본함수 시각화 ####
#--------------------------------#

par(mfrow = c(1, 2))
hist(albums$sales, main = "Original Data", xlab = "Sales")
hist(z_score_sales, main ="Scaled Data", xlab = "Z-Score")
