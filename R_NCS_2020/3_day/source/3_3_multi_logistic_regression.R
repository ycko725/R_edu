#### III. 다항 로지스틱 회귀분석 해석 및 보고서 작성 ####
#### 단계 1. 패키지 설치 ####
library(mlogit) # 다항 로지스틱 회귀

#### 단계 2. 데이터 불러오기 ####
setwd("~/Documents/R_edu")
chatData <- read.csv('R_NCS_2020/3_day/data/chat-up_lines.csv', header = TRUE)
head(chatData)

# 여기에서 종속변수는 Success 이다. 
# 예측변수는 아래와 같음
# Funny: 웃긴 정도를 평가함 (0 = 전혀 웃기지 않음, 10 = 제일 웃김)
# Sex: 성적 내용을 평가함 (0 = 성적 내용 없음, 10 = 매우 노골적임)
# Good_mate: 좋은 성격의 반영 정도를 평가함 (0 = 성격 매우 안 좋음, 10 = 바람직한 성격을 잘 드러냄)
# Gender: 1은 여성 2는 남성

str(chatData)

#### 단계 3. 데이터 처리 ####
# Gender에서 male이 기저 범주가 되도록 한다. 
# 연구의 목적은 대화문에 대한 여성의 반응이 남성의 반응과는 다르다는 점에 기초함. 
# 이러한 변경을 통해서, 주 효과들에 대한 매개변수 추정값들에 영향을 미치기는 하나, 우리의 관심사인 상호작용 항들에는 영향이 미미하다. 
chatData$Gender <- relevel(chatData$Gender, ref = "Male")

# 데이터 변경
# 새 데이터 프레임 <- mlogit.data(기존데이터프레임, choice = "결과변수", shape = "wide" 또는 "long")
mlChat <- mlogit.data(chatData, choice = "Success", shape = "wide")
head(mlChat)

# 위 표에 대한 설명은 교재 참조
chatModel <- mlogit(Success ~ 1 | Good_Mate + Funny + Gender + Sex + Gender:Sex + Funny:Gender, data = mlChat, reflevel = 3)

# 위 formula에 대한 설명이 필요하다. 
# 결과변수 ~ 예측변수(들) 
# 여기서 중요한 것은 상호작용이다. 
# Sex X Gender의 상호작용, Funny X Gender의 상호작용
# 이런 상호작용들을 평가하려면 주 효과(main effect)들도 포함시켜야 한다.
# 이러한 조합은 사실 연구자의 의도가 분명해야지만 공식을 세울 수 있기 때문에, 연구 목적이 매우 중요하다.

# reflevel = 결과 기저 범주 번호
# 기저 범주로 사용할 결과 범주를 나타내는 번호
# 기저 범주로 삼기에 가장 적합한 것은 아마 무반응("No Response / Walk off")일 것임. 

#### 단계 4. 모형 해석 ####
summary(chatModel)

# Likelihood ratio test : chisq = 278.52 (p.value = < 2.22e-16)
# 로그 가능도는 교재에서 본 것처럼, 자료에서 설명되지 않은 변동이 어느 정도인지 말해주는 측도이다. 
# 로그 가능도의 차이 또는 변화는 새 변수가 모형을 어느 정도나 설명하는지를 나타낸다. 
# 기저 모형만 분석해보자.
chatBase <- mlogit(Success ~ 1, data = mlChat, reflevel = 3)
summary(chatBase)

# 기저 모형의 로그 가능도는 -1008
# 최종모형의 로그 가능도는 -868.74
# 위 두개의 차이는 139.26이고, 카이제곱 검정은 2를 곱한다. 
# chisq = 278.52
# 다른 뜻으로 말하면 최종 모형이 원래 모형보다 변이성을 더 유의하게 더 많이 설명하고 있다. 

data.frame(exp(chatModel$coefficients))
# 이 값은 승산비이다. 
# 승산비에 대한 설명은 교재를 참고한다. 
# 어떻게 해석해야 할까
# 우선 기저변수인 No Response/walk off와 범주를 비교한 결과를 말한다. 
# 이 계수들의 신뢰구간은 confint() 함수로 구할 수 있다. 
exp(confint(chatModel))

# 각각의 해석 또한 교재를 참고한다. 

