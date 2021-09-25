# --------------------------------------------------------------------------------
# 기본적으로 데이터 파일을 불러오고 읽고 쓰는 것을 연습합니다. 
# 매우 쉬운 예제부터 출발해서 입문자분들에게 조금 어려운 과정을 모두 담았습니다. 
# --------------------------------------------------------------------------------

#### Step 1. 기본 예제 ####
# 아래 예제를 통해서, 직접 데이터를 만들어보는 작업을 수행합니다. 
#### 1. 가상 데이터 만들기 ####


# 데이터 객체를 확인
str(학생)

#### 2. 파일 내보내기 ####
# 1. CSV 파일로 내보내기


# 경로 유의


# 2. 엑셀파일로 내보내기
# install.packages("writexl")


# 모두 지우기


#### 3. 파일 불러오기 ####
# 현재 경로 불러오는 함수


#### Step 2. dplyr 소개 및 패키지 설치 ####
# dplyr 패키지 설치
# 패키지 개발자: Hadley Wickham, (http://hadley.nz/)

# dplyr을 사용하는 방법에는 크게 2가지 방법이 있습니다. 
# 두가지 방법이 있음
# The easiest way to get dplyr is to install the whole tidyverse:


# Alternatively, install just dplyr:


#### Step 3. 데이터 처리와 관련된 주요 함수 소개 ####
# 데이터 가져오기


# 실무 할 때, 우리는 데이터를 모른다는 전제하에 출발합니다. 
# 생각보다 데이터셋이 매우 큽니다. 
# 아래 데이터를 가지고 훈련할 때, 탐색하는 마음으로 소스코드를 작성하시면 매우 큰 도움이 됩니다. 

# ----- (1) glimpse() -----
## 데이터를 전체적으로 개괄적으로 확인합니다. 


## 무엇이 먼저 보이나요? 
# 데이터 보는 법
# 우선 관측갯수, 변수의 갯수, 변수의 유형(문자, 숫자, 논리), 그리고 변수의 이름
## 만약 변수의 이름이 제대로 정의가 되어 있지 않는다고 한다면,, 어떻게 해야 할까요? 
## 데이터 분석가의 입장에서, 데이터 엔지니어 입장에서, 데이터 서비스 기획자 입장에서, 경영자 입장에서 생각해보기

# ----- (2) select() -----
# 주요 변수들을 추출합니다. 
## 데이터 분석가의 입장에서, 데이터 엔지니어 입장에서, 데이터 서비스 기획자 입장에서, 경영자 입장에서 생각해보기
# 코드 작성
# state, county, population, employed 변수를 추출하세요. 


# 코드 연습
# 수강생이 원하는 변수를 추출하세요. 


# ----- (3) arrange() -----
# public_work 변수를 기준으로 내림차순으로 정렬합니다. 
counties_selected <- counties %>%
  select(state, private_work, public_work, self_employed)

counties_selected %>% 
  arrange(desc(public_work))

# self_employed 변수를 기준으로 오름차순으로 정렬합니다. 
# 수강생이 직접입력합니다. (주석을 풉니다. )
# counties_selected %>% 
# 


# ----- (4) filter() -----
# 조건에 따라 불필요한 관측치는 제거합니다. 
## 데이터 분석가의 입장에서, 데이터 엔지니어 입장에서, 데이터 서비스 기획자 입장에서, 경영자 입장에서 생각해보기


# 조건이 한가지 일 때 
# 인구가 1000000명이 넘는 state & county를 추출하세요. 


# 인구가 1000명이 아래인 state & county를 추출하세요. 
# (주석을 풉니다. )
# counties_selected %>% 

# 조건이 두가지 일 때
# state가 캘리포니아이면서 인구가 백만명 이상인 지역을 추출하세요. (AND 조건)


# state가 Colorado이거나 또는 인구가 천명 이하인 지역을 추출하세요 (OR 조건)


# ----- (5) filter() & Arrange() -----
# 두개의 함수 중복 사용하기


# 10000명이 넘는 캘리포니아 지역을 추출한 뒤; public_work 기준으로 내림차순으로 정렬하세요. 


# ----- (6) mutate() -----
# mutate는 영어 사전에서 보면 돌연변이 또는 변이라는 의미를 내포하고 있습니다. 
# 즉, 단순히 변수를 하나 더 추가하자는 뜻이 아니라 무언가 의미있는 데이터를 발견하고자 할 때 쓰는 경우가 좋습니다. 
## 데이터 분석가의 입장에서, 데이터 엔지니어 입장에서, 데이터 서비스 기획자 입장에서, 경영자 입장에서 생각해보기


# private_work에서 일하는 사람의 숫자를 구하는 변수를 추가해보세요. 


# 수강생 실습


# mutate()를 사용하여, 각 county당 여성의 인구비율을 구하시고, 내림차순으로 정렬하세요. 
# 추가할 변수명: proportion_women


# Norton City와 Pulaski 이쪽 지역에 유독 여성의 인구비율이 높은 이유는 무엇일까? 
# 이러한 질문을 하면서 질적으로 연구하는 것이 데이터 과학의 묘미입니다. 

## (번외) 데이터 기반으로 문제를 해결하고 싶은 조직이 있다면 강사 기준에 3가지 최소 기준 중 1가지는 만족되어야 합니다. 

### 시간이 넉넉하게 주어지는 문제인가? 
### Input 대비 Output의 영향력 또는 가치가 큰 문제인가? 
### 데이터 분석을 통해 비즈니스 문제를 해결할 수 있는 것인가? 

# 위 3가지 조건이 아니라면 빅데이터는 그저 시간 낭비에 불과한 프로젝트가 될 공산이 큽니다. 
# 위 내용은 지극히 필자 생각입니다. 

#### Step 4. 피벗테이블 작성과 관련된 주요 함수 소개 ####
# 피벗 테이블이란? 데이터 요약을 말합니다. 
# ----- (1) count() -----


# count() 함수를 사용하면 각 값의(행) 갯수를 자동적으로 카운팅해줍니다. 


# 가중치를 적용한 count


# 가중치를 적용하지 않은 count


# 위 두개의 차이를 확인할 수 있나요?
# count(state, wt = citizens, sort = TRUE) 함으로써, citizens 값이 자동으로 합계가 만들어집니다. 
# 굉장히 Powerful한 함수입니다. 

# 퀴즈


# 아래 주석을 풀고 문제를 풉니다. 
# counties_selected %>% 
## mutate() 함수를 활용해서 walk의 인구수를 구하세요. (아래 주석을 푸세요)
# mutate(pop_wakers = population * walk / 100) %>% 
## count() 함수를 활용하며, pop_wakers에 가중치를 둔 후, 각 state별 내림차순으로 집계를 합니다. 
# count(state, wt = pop_wakers, sort = TRUE)

# ----- (2) summarise() -----
# summarise() 함수는 데이터를 (기초통계량) 요약해주는 함수입니다. 
# 함께 사용하는 기본함수는
# sum(), min(), median(), max(), mean(), n() 함수가 있습니다. 
# 실습 코드는 아래와 같습니다. 


# min_population, max_unemployment, average_income을 구하세요. 

# 연습코드


# min_private_work, max_public_work, average_self_employed을 구하세요. 


# ----- (3) group_by -----
# 각 주별로 요약을 한다면 어떻게 될까요? 
# summarise() 앞에 group_by만 추가하면 됩니다. 


# ----- (4) multiple summarise() -----
# state와 region별로 평균과 중간값을 구하는 방법입니다. 


# summarise()를 한번만 사용하게 되면, 무언가 원하는 그림이 아닙니다. 


# 일차적으로 구한다면, 각 주와 state별로 전체 인구수를 구합니다. 
# summarise()를 한번만 사용하게 되면, 무언가 원하는 그림이 아닙니다. 


# ----- (5) top_n() -----
# top_n() 함수와 Group_by()를 같이 활용하면 최중요지표를 보다 쉽게 추출할 수 있습니다.  
# Group by region and find the greatest number of citizens who walk to work


# 실습 예제


# 문제, region & state 그룹에서 평균 Income이 가장 높은 것 1행씩을 추출하세요. 


#### Step 5. 그 외 사용하는 주요 함수 소개 ####
# 이 부분에 대한 연습은 과제로 남겨둡니다. 
# select & rename https://dplyr.tidyverse.org/reference/select.html
# transmute() https://dplyr.tidyverse.org/reference/mutate.html
# ungroup() https://dplyr.tidyverse.org/reference/group_by.html

# 위 함수를 사용하면 보다 더 효율적으로 피벗테이블을 만들 수 있습니다. 

# End of Document