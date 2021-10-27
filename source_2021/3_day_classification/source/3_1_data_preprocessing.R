# ------------------
# 로지스틱 회귀분석 - 분류문제
# ------------------

# 지난시간에는 기초 통계와 수치형 데이터를 예측하는 것에 배웠습니다. 
# 또한 caret 패키지를 활용하는 것에 대해 배웠습니다. 
# 오늘 시간에는 데이터 전처리 시, 기본적인 원리, caret을 활용한 모형 튜닝, 그리고 H2O패키지에 대해 소개하려고 합니다. 

# 데이터셋은 대출과 관련된 것으로 준비했습니다.

#### 데이터 전처리 시 기본적원 방법 정리 ####
#### (2) 데이터 불러오기 ####
setwd("~/Documents/R_edu")
loan_data <- read.csv("R_NCS_2020/3_day/data/raw_loan_data.csv", stringsAsFactors = FALSE)
str(loan_data)

#### (3) 데이터 탐색하기 ####
# Load the gmodels package 
library(gmodels)

# 종속변수가 되는 loan_status에 대해 데이터를 탐색합니다. 
CrossTable(loan_data$loan_status)
# 0의 의미는 채무 이행, 즉 대출금을 상환한 사람 숫자
# 1의 의미는 채무 불이행, 즉 대출금을 상환하지 못한 사람 숫자

CrossTable(x = loan_data$home_ownership, 
           y = loan_data$loan_status, 
           prop.r = TRUE, prop.c = FALSE, prop.t = FALSE, prop.chisq = FALSE)

?CrossTable
# prop.r의 경우, y값에 대한 x의 비율을 알 수 있음
# prop.c의 경우, 각 변수에 대한 비율을 알 수 있음
# prop.t의 경우, 전체 테이블의 비율을 알 수 있음
# prop.chisq의 경우 각 셀에 해당하는 카이제곱의 비율을 알 수 있음
# But, 각 변수, 전체 테이블, 카이제곱은 현재로써는 필요 없음

# 위 데이터 탐색에서 봐야 하는 것은 loan_status기준으로 데이터가 불균형하다는 것에 있음
# 분류 문제 다룰 시, 이와 같은 문제에 직면하는 경우가 많음. 

#### (4) 데이터 시각화 하기 #### 
library(ggplot2)

summary(loan_data)

# 수치형 데이터 - 히스토그램으로 대출금액 파악하기 
ggplot(loan_data, aes(x = loan_amnt)) + 
  geom_histogram(bins = 200) + 
  labs(title = "Total Amount of Loan") + 
  theme_minimal()

ggplot(loan_data, aes(x = int_rate)) + 
  geom_histogram(bins = 200) + 
  labs(title = "Interest Rate of Loan") + 
  theme_minimal()

ggplot(loan_data, aes(x = annual_inc / 100)) + 
  geom_histogram(bins = 200) + 
  scale_x_log10() + 
  labs(title = "Annual Income") + 
  theme_minimal()

ggplot(loan_data, aes(x = age)) + 
  geom_histogram() + 
  labs(title = "Age") + 
  theme_minimal()

#### (5) 이상치 제거 ####
# 시각화의 목적은 크게 두가지가 있다. 
# 변수간의 관계성, 분포도 등 확인이 필요하다. 
# 가장 좋은 것 중 하나는, missing data를 잡아내거나, 이상치를 잡아낼 수 있다. 
# 산점도를 확인해보자
ggplot(loan_data, aes(x = age, y = annual_inc / 100)) + 
  geom_point(alpha = .3) + 
  theme_minimal()

# 위 그래프에서 보이는 것처럼 age가 150에 가까운 데이터가 존재했다.
# 이상치에 대한 접근방법은 크게 2가지다
# (1) 도메인 전문가의 직관 및 의견
# (2) 통계적인 방법으로 제거
# (3) (1) + (2)을 혼합해서 사용하는 것
# 즉, 현업 담당자와 커뮤니케이션을 통해서 이상치를 제거한다. 

# (1) 방법으로 제거
# 상식적으로 140세는 존재할 수 없다. (현재 의학으로는..)
# 다행히, 데이터가 1개만 존재하기 때문에, 삭제해도 무방하다.
# 이상치인 데이터의 Index를 찾아본다. 
index_highage <- which(loan_data$age > 122) # 이 코드는 특정 Index를 유용하기 때문에 꼭 참고한다. 

index_highage # 19486번째 사람인 것 확인

# 새로운 데이터를 만든다. loan_data2 로 저장한다. 
loan_data2 <- loan_data[-index_highage, ]

# (2) 방법으로 제거
# 사분위수 Q3 + 1.5 * IQR 보다 큰것을 이상치로 판단 후 제거
outlier_cutoff <- quantile(loan_data$annual_inc, 0.75) + 1.5 * IQR(loan_data$annual_inc)

print(outlier_cutoff) 

index_outlier_ROT <- which(loan_data$annual_inc > outlier_cutoff)
length(index_outlier_ROT) # 이상치로 측정된 전체 Index는 1382개수로 확인됨
loan_data_ROT <- loan_data[-index_outlier_ROT, ] # 이상치 제거한 데이터

rm(loan_data_ROT) # 이 데이터는 사용하지 않을 것이기 때문에 제거

# 위와 같은 방법으로 이상치를 제거할 수 있다. 

#### (6) 결측치 처리 방법 ####
summary(loan_data2)

# int_rate와 emp_length에 결측치가 제법 많음이 보인다.
# int_rate의 경우 2776
# emp_length의 경우 809

# 만약 여러분이, 데이터 처리를 해야 하는 상황이라면 어떻게 해야 할까요?
# 크게 3가지 방법이 있습니다. 
# 첫번째, 행 또는 열 삭제
# 두번째, 대치법
# 세번째, 그 상태로 유지하는 법

# 어떤 방법이 더 좋은지는 상황에 따라 다릅니다. 
# 여기서는 각각의 방법에 대해 코드 처리법을 알려드립니다. 
# 이 원칙은 어떤 언어를 사용해도 동일하게 적용됩니다. 

#### (6-1) 결측치 제거 #### 
## 행 제거
# 결측치에 해당하는 Index 확인
na_index <- which(is.na(loan_data$int_rate))
length(na_index)
# 2776개 확인

# Index 활용 제거
loan_data_delrow_na <- loan_data[-na_index, ]

## 변수 제거
loan_data_delcol_na <- loan_data
loan_data_delcol_na$int_rate <- NULL # 간단하게 변수 제거

#### (6-2) 중간값 대치 ####
# 우선, 결측치를 제외한 중간값을 구한다. 
median_ir <- median(loan_data$int_rate, na.rm = TRUE)

# 다른 데이터로 변환
loan_data_replace <- loan_data

# 결측치 index에 중간값 대치
loan_data_replace$int_rate[na_index] <- median_ir

# 요약 통계량으로 결측치 유무 재확인
summary(loan_data_replace$int_rate)

# Tip: 중간값 대치가 꼭 합리적인 것은 아닙니다. 
# R에서는 다중대치법에 관한 패키지가 있습니다. 
# 이 부분은 개인적으로 소화하시는 것으로 남겨 놓겠습니다. 
# https://www.analyticsvidhya.com/blog/2016/03/tutorial-powerful-packages-imputing-missing-values/

#### (6-3) 결측치를 사용하기 ####
# 단, 중요한 것은 수치형이나 범주형이나, NA를 하나의 값으로 생각하고 치환하는 것이 핵심 포인트입니다. 
loan_data$emp_cat <- rep(NA, length(loan_data$emp_length))
loan_data$emp_cat[which(loan_data$emp_length <= 15)] <- "0-15"
loan_data$emp_cat[which(loan_data$emp_length > 15 & loan_data$emp_length <= 30)] <- "15-30"
loan_data$emp_cat[which(loan_data$emp_length > 30 & loan_data$emp_length <= 45)] <- "30-45"
loan_data$emp_cat[which(loan_data$emp_length > 45)] <- "45+"
loan_data$emp_cat[which(is.na(loan_data$emp_length))] <- "Missing"

loan_data$emp_cat <- as.factor(loan_data$emp_cat)

# 근속년수에 따른 데이터를 변환하면 'Missing'으로 하나의 의미있는 값으로 치환할 수 있습니다. 
# 강사가 가장 좋아하는 소스코드 중의 하나입니다. 

# End of Document



