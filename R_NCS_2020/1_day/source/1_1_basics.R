# --------------------------------------------------------------------------------
# R을 처음 접하는 사람들을 위한 입문 강의입니다. 
# 기존에 R을 하셨던 분들은 가볍게 들어주시면 됩니다. 
# --------------------------------------------------------------------------------

# 데이터 분석의 기본 흐름
# 데이터 수집, 저장, 가공, 시각화, 모델링, 보고서 (대시보드)
# 입문자, 서비스 기획자는 전체의 생태계를 보자. 
# PDF - 메뉴얼 참조

#### 1. CRAN 생태계 이해하기 ####
# (1) CRAN의 역할
# 전세계의 수많은 사람들과 조직들이 데이터, 통계, 머신러닝 등 다양한 문제를 해결하기 위해 여러 함수를 만들어 공유하는 곳입니다.  (집단지성의 요체)
## 이중에는 아마존, 구글, MS 데이터 팀들이 내놓은 패키지도 존재함
## 오픈소스의 매우 특기할만 강점입니다. 
## 새로운 패키지는 앞으로도 계속 만들어질 것이며, 스스로 학습할 수 있는 능력이 중요합니다. 
### 데이터 입문자: 다양한 책과 스터디에 참석 권유
### 서비스 기획자: R 컨퍼런스 참여 권유 (빅데이터 생태계의 발전 속도에 뒤쳐지지 말자!)
### 흐름은 똑같다! 다만, 무엇이 더 효율적이냐의 싸움입니다. 

#### 2. R 코딩 기초 ####
# (1) R은 계산기입니다. 
# 실행방법은 Windows: Ctrl + Enter / Mac: Command + Enter
1 / 200 * 30
# > [1] 0.15

(59 + 73 + 2) / 3
# > [1] 44.7

sin(pi / 2)
# > [1] 1

# (2) 변수 저장 시, R은 '<-' 사용하는 것을 권장합니다. (단축키: Alt + - (the minus sign))
# 특별한 이유는 없습니다. 타 언어와의 차이점이라고 이해해도 좋습니다. 
# 객체이름 <- 값 
# 예) 
x <- 3 * 4

# 저장된 변수를 호출하는 방법
print(x)

x
## Tip: 강사는 가급적 print(x) 사용하는 것을 권유합니다. 

# (3) 변수이름 저장 방법에는 여러가지가 있습니다. (프로그래밍 기초)
## (A) i_use_snake_case
## (B) otherPeopleUseCamelCase
## (C) some.people.use.periods
## (D) And_aFew.People_RENOUNCEconvention

# 위 4가지 중에서 어떤것이 가독성이 좋아 보이나요? 
# 여러가지를 써봤지만, 강사는 (A)를 추천합니다. 

# (4) 가장 기본적인 에러 확인
r_basics <- 2 ^ 3

# 에러 유형 확인 (실행 후 에러를 확인하세요!!)
r_basic 
# Error: object 'r_basic' not found
R_basics
# Error: object 'R_basics' not found

## Tip: 당황하지 마세요. 위 이름으로 된 변수가 없다는 뜻입니다. 

## 에러 연습
my_variable <- "나의 첫번째 변수"
my_varlable
# Error: object 'my_varlable' not found
# 왜 에러 메시지가 나왔는지 맞춰보세요. 
# 입문자가 흔히 범하는 실수! 그리고 잊지 말아야 할 코딩의 기본자세! 
# 세상은 정직하지 않지만, 컴퓨터는 정직하다! 

#### 3. R Studio 환경 소개 ####
# 강사와 함께 진행합니다. 
# 더 많은 최신의 RStudio Tips는 https://twitter.com/rstudiotips 에서 확인하세요~ ^^

# 4. 주요 변수 타입의 특징 공부
## 변수의 종류별 예시 코드
# 숫자형 변수
my_numeric <- 42

# 문자형 변수
my_character <- "universe"

# 논리형 변수
my_logical <- FALSE

## 변수 유형 확인 예시 코드
# 숫자형 변수
class(my_numeric)

# 문자형 변수
class(my_character)

# 논리형 변수
class(my_logical)

#### 4. 벡터 생성 ####
# 벡터는 동질성의 특징을 가지고 있습니다. 
# 예시
numeric_vector <- c(1, 2, 3)
class(numeric_vector)
print(numeric_vector)

character_vector <- c("A", "B", "C")
class(character_vector)
print(character_vector)

logical_vector <- c(TRUE, FALSE, TRUE)
class(logical_vector)
print(logical_vector)

# 실무 Tip
# 실제로 엑셀 또는 DB에는 잘못된 값이 들어오는 경우도 종종 있습니다. 
# 특히, 입문자에게 조금 어려운 것 중 하나가 데이터 유형에 대한 구분인데, 
# 데이터 셋이 많으면 많아질수록 판별하기 어렵습니다. 
# 아래 간단한 예를 들도록 하겠습니다. 
numeric_character_vector <- c(1, "'1", 3)
numeric_character_vector
class(numeric_character_vector)

numeric_logical_vector <- c(4, FALSE, TRUE)
numeric_logical_vector
class(numeric_logical_vector)

character_logical_vector <- c("FALSE", FALSE, TRUE)
character_logical_vector
class(character_logical_vector)

# 위 3가지 예시를 통해서 알 수 있는 것은, 
# 데이터 타입이 섞여 있을 경우, 컴퓨터는 문자, 숫자, 논리형 순으로 저장이 된다는 것입니다. 
# 특히 엑셀 데이터를 수집할 경우, 숫자와 문자 데이터가 섞여 있는 경우가 종종 있습니다. 꼭 주의하시기를 바랍니다. 

#### 5. 범주형 변수 ####
# 명목형 자료형 Factor
locaiton_vector <- c("서울", "인천", "부산")
factor_location_vector <- factor(locaiton_vector)
factor_location_vector

# 순서형 자료형 Factor
temperature_factor <- c("기온높음", 
                        "기온보통", 
                        "기온낮음", 
                        "기온높음", 
                        "기온보통", 
                        "기온보통")

factor_temperature_factor <- factor(temperature_factor, 
                                    ordered = TRUE, 
                                    levels = c("기온낮음", 
                                               "기온보통", 
                                               "기온높음"))
factor_temperature_factor
table(factor_temperature_factor)

class(factor_location_vector)
class(factor_temperature_factor)
factor_temperature_factor

#### 6. Factor Levels ####
# 범주형의 이름 또는 순서를 바꾼다. 
sex_vector <- c("남", "여", "남")
factor_sex_vector <- factor(sex_vector)
factor_sex_vector

# 1단계, 남, 여를 남성, 여성으로 바꾼다. 
levels(factor_sex_vector) <- c("남성", "여성")
factor_sex_vector

# 2단계, 여성과 남성을 바꾼다. 
factor_sex_vector <- factor(factor_sex_vector, 
                            levels = c("여성", 
                                       "남성"))
factor_sex_vector

# 1+2단계 적용하기
factor_sex_vector2 <- factor(sex_vector, 
                             levels = c("여", "남"), 
                             labels = c("여성", "남성"))
factor_sex_vector2


# End of Document

