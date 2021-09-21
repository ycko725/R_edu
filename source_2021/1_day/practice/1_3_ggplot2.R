# --------------------------------------------------------------------------------
# 이번시간에는 시각화의 다양한 기법에 대해 배우도록 합니다.  
# --------------------------------------------------------------------------------

#### 1. 기본 이론 ####
# EDA란 무엇인가요? 
## 1 .EDA는 탐색적 자료 분석이라 보통 말합니다. 
## 2. 데이터를 수집할 때, 이를 다양한 각도에서 관찰하고 이해하는 과정을 말합니다. 
## 3. 실제 데이터 분석가가 통계 기법을 사용하여 가설을 검정하기 전, 들어온 데이터가 정상적으로 들어왔는지, 추가적으로 가공할 필요가 없는지 데이터 가공 - 시각화 - 데이터 가공 - 재시각화.. 순으로 적용합니다. 
## 4. 이 때, 데이터 분석가가 도메인 지식이 있다면 크게 상관이 없지만, 만약 업에 대한 깊은 지식이 없다면, 이 때 협력이 필요합니다. 
## 5. 예) Wconcept 페이지, 
###    https://www.wconcept.co.kr/Product/300516792 (재질: 천연소가죽)
###    https://www.wconcept.co.kr/Product/300736663 (재질: leather 100)
###    위 두 제품 재질의 차이가 있는가? 

#### 2. 시각화 이론 ####
## (1) 시각화 기본원리 (모든 시각화 공통)
# 시각화의 절대적 기본원리, 단순, 명료, 그리고 전달성
# “The simple graph has brought more information to the data analyst’s mind than any other device.” — John Tukey
# 자세한 이론은 교재를 참고하세요

## (2) ggplot2 이론
# 관심있는 사람만 보세요: http://vita.had.co.nz/papers/layered-grammar.pdf
# 주요 내용은 '그래프에도 문법이 있다.' '좋은(good) 문법을 만들자' 
# 그래프 단계별 층(Layer)을 만들자

#### 3. 데이터 수집 ####
setwd("/Users/jihoonjung/Documents/R_edu/R_NCS_2020/1_day")
who_disease <- readxl::read_xlsx("data/who_disease.xlsx")

#### 4. 데이터 확인 ####
library(dplyr)
glimpse(who_disease)

#### 5. 데이터 시각화 ####
# ----- (1) 무작정 그려보기 -----
library(ggplot2)
ggplot(who_disease) + 
  geom_point(mapping = aes(x = year, y = cases))

# 그래프 공식
# ggplot(data = <DATA>) + 
#  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# (1) 투명도 주기
ggplot(who_disease) + 
  geom_point(mapping = aes(x = year, y = cases), alpha = 0.3)

# (2) 색상주기
ggplot(who_disease) + 
  geom_point(mapping = aes(x = year, y = cases), colour = "red")

# (3) 그 외 옵션들
# ?geom_point() 에서 확인합니다.

# 그 외 기본적인 내용은 https://r4ds.had.co.nz/data-visualisation.html#first-steps 여기를 참조하세요. 
# 영어원문 읽을 필요 굳이 없습니다. 
# 소스코드 직접 보면서 실행하면서 익히면 됩니다. 

# Options
options(scipen = 1)
?options

#### 5-1. Univariate ####
# ----- (1) Categorical Pie Chart 그리기 -----
# 언제 Pie Chart를 그릴까요? 
# 특정 범주형 변수에, 요약한 수치를 비율로 표시하려고 할 때.. 
# 이번 PieChart는 region별 cases 숫자를 집계합니다.

# 이 때, 1주차에 배운 데이터 가공이 필요합니다. 
region_counts <- who_disease %>% 
  group_by(region) %>% 
  summarise(total_cases = sum(cases))

ggplot(region_counts, aes(x = 1, y = total_cases, fill = region)) +
  geom_col() +
  coord_polar(theta = "y") + 
  theme_void() + 
  ggtitle("Proportion of Region")

# 위 그래프의 장단점은? 무엇인가요? 
# install.packages("waffle")
library(waffle)
# waffle chart 작성해보기
region_counts <- who_disease %>%
  group_by(region) %>%
  summarise(total_cases = sum(cases)) %>% 
  mutate(percent = round(total_cases/sum(total_cases)*100))

# waffle 함수에 적용할 수 있도록 변환 (named vector)
case_counts <- region_counts$percent
names(case_counts) <- region_counts$region

# ?waffle() 함수 일반 데이터 셋이 아니라, named vector of values to use for the chart
?waffle
waffle(case_counts)

# Pie Chart와 Waffle 차트 중 가독성이 뛰어난 것이 무언인가요? 
# 왜 그런가요? 퍼센트 기반으로 작성된 그래프가 단지 선을 긋는 정도의 그래프보다 더 나은 대안일 수 있습니다. 

# ----- (2) Quantitative  -----
# 이 그래프를 그리는 주요 목적은 데이터의 분포를 확인하자 입니다. 
# 그런데, Histogram 그래프를 그릴 때, 
glimpse(who_disease)

# 질병 데이터 중, AMR 데이터, 연도는 1980년도, disease는 'pertussis' (백일해)
#  새로운 데이터를 생성합니다. 
amr_pertussis <- who_disease %>% 
  filter(   # filter data to our desired subset
    region == 'AMR', 
    year == 1980, 
    disease == 'pertussis', 
    cases > 0
  )


# Histogram
ggplot(amr_pertussis, aes(x = cases)) + 
  geom_histogram(fill = "cornflowerblue", 
                 color = "white") + 
  theme_minimal()

# 히스토그램의 가장 큰 문제점은 bin의 갯수에 따라 그래프의 형태가 달라집니다. 
# 그럼 숫자 세팅은 어떻게 하는게 좋을까요? (메뉴얼 참조)

# 히스토그램의 대안은 Kernel Density Plot입니다. 
ggplot(amr_pertussis, aes(x = cases)) + 
  geom_density(fill = "cornflowerblue", 
               color = "white", bw = 1000) + 
  theme_minimal()

# Kernel Density Plot의 가장 큰 장점 중 하나는 여러 그룹별로 비교할 때 차이점이 명확하게 나타날 수 있습니다. 
# 'AMR'과 'EUR' region별로 차이점을 구분하는 그래프를 작성합니다. 

amr_eur_pertussis <- who_disease %>% 
  filter(   # filter data to our desired subset
    region %in% c('AMR', 'EUR'), 
    year == 1980, 
    disease == 'pertussis', 
    cases > 0
  )

ggplot(amr_eur_pertussis, aes(x = cases)) + 
  geom_density(aes(fill = region), 
               color = "white", alpha = 0.5) + 
  theme_minimal()

# 위 그래프를 보면서 어떻게 해석할 수 있을까요? 
# 시각적으로 볼 때, AMR cases가 더 많다는 것을 직감적으로 느낄 수 있습니다. 

# 지금까지 일변량 그래프의 작성법에 대해 배웠습니다. 

#### 5-2. bivariate - Categorical VS. Quantitative ####
# ----- (1) Bar Chart? Point & theme 재활용법 -----
# 시각화 기본 이론 중 하나는 그래프 뒤 배경이 없는 것이 좋습니다. 
# 배경색을 지우지 않은 그래프
glimpse(who_disease)

# 질병 데이터 중, EUR 데이터, 연도는 1980년도, disease는 'pertussis' (백일해)
#  새로운 데이터를 생성합니다. 
eur_pertussis <- who_disease %>% 
  filter(   # filter data to our desired subset
    region == 'EUR', 
    year == 1980, 
    disease == 'pertussis'
  )

# 이제 각 나라별 Case를 비교하는 그래프를 그립니다. 
# reorder()와 coord_flip() 함수에 관한 내용은 교재를 참고하시기를 바랍니다. 
ggplot(eur_pertussis, aes(x = reorder(country, cases), y = cases)) +
  geom_col() +
  # 축 바꿈
  coord_flip()

# 위 그래프를 보니 어떤가요? 배경색이 무언가 방해를 주는 느낌이 있습니다. 
# 이 때 해결법 중 하나가 theme 테마를 지정하는 것입니다. 
# cases가 없는 나라들은 굳이 표시할 필요가 있을까요? 없을까요? 
# 불필요한 항목들은 제거하는 것이 좋습니다. 

eur_pertussis %>% 
  # case가 0보다 작은 것 행에서 제거하기. 
  filter(cases > 0) %>% 
  ggplot(aes(x = reorder(country, cases), y = cases)) +
  geom_col() +
  coord_flip() +
  theme(
    # x축 선 제거하기
    panel.grid.major.x = element_blank()
  )

# 여전히 이쁘지가 않습니다. 나머지 배경도 지워보도록 합니다. 
eur_pertussis %>% 
  # case가 0보다 작은 것 행에서 제거하기. 
  filter(cases > 0) %>% 
  ggplot(aes(x = reorder(country, cases), y = cases)) +
  geom_col() +
  coord_flip() + 
  theme_minimal()

# 조금 깔끔해졌지만, 값의 차이가 많이 나서 무언가 비대칭성이 있어보이지 않나요? 
# 정확한 값의 표현이 중요한 것이 아니라면, 단지 상징적으로 그래프를 보여주고자 한다면, scale_y_log10() 함수를 쓰는 것도 좋은 예가 될 수 있습니다.
eur_pertussis %>% 
  # case가 0보다 작은 것 행에서 제거하기. 
  filter(cases > 0) %>% 
  ggplot(aes(x = reorder(country, cases), y = cases)) +
  geom_point(size = 3) +
  scale_y_log10() + 
  theme_minimal() + 
  coord_flip()

# geom_point() 함수를 단지 산점도에 그리기 보다, 이렇게 응용할 수 있는 아이디어도 시각적으로 합니다. 
# 막대그래프 VS Point 상황에 맞게 시각화를 그리는 것이 무엇보다 중요합니다. 

# ----- (2) 기본 Box Plots와 여러 대안들 -----
# 박스플롯의 기본 데이터는 비교군을 선정할 때 많으면 많을수록 좋습니다. 
# install.packages("carData")
data(Salaries, package="carData")

ggplot(Salaries, 
       aes(x = rank, 
           y = salary)) +
  geom_boxplot()

# 박스플롯의 장점은 직관적이기는 하지만, 박스플롯을 모르는 사람들에게는 다시 해석을 해드려야 하는 불편함이 있습니다. 
# 우리가 보고해야 하는 상사와 고객은 통계 지식이 없다는 것을 늘 가정하고 작성해야 합니다. 

# 평균, 표준편차, 표준오차 등을 담고 싶다면 어떻게 할까? 
# 우선 dplyr 패키지를 활용하여 데이터를 요약합니다. 

rank_data <- Salaries %>%
  group_by(rank) %>%
  summarize(n = n(),
            mean = mean(salary),
            sd = sd(salary),
            se = sd / sqrt(n))

print(rank_data)  

# 평균과 오차에 관한 그래프 그리기
ggplot(rank_data, aes(x = rank, y = mean, group = 1)) +
  geom_point(size = 3) +
  geom_line() +
  geom_errorbar(aes(ymin = mean - se, 
                    ymax = mean + se), 
                width = .1)

# 이번에는 성별을 기준으로 측정하도록 합니다. 
gender_data <- Salaries %>%
  group_by(rank, sex) %>%
  summarize(n = n(),
            mean = mean(salary),
            sd = sd(salary),
            se = sd/sqrt(n))

# 평균과 오차에 관한 그래프 그리기 (성별 기준)
ggplot(gender_data, aes(x = rank, y = mean, group = sex, colour = sex)) +
  geom_point(size = 3) +
  geom_line(size = 1) +
  geom_errorbar(aes(ymin = mean - se, 
                    ymax = mean + se), 
                width = .1)

# 문제가 하나 있네요! 데이터가 겹치기 때문에 성별로 구분을 하도록 합니다. 
# position_dodge를 활용합니다. 
pd <- position_dodge(0.3)
ggplot(gender_data, 
       aes(x = rank, 
           y = mean, 
           group=sex, 
           color=sex)) +
  geom_point(position = pd, 
             size = 3) +
  geom_line(position = pd,
            size = 1) +
  geom_errorbar(aes(ymin = mean - se, 
                    ymax = mean + se), 
                width = .1, 
                position= pd) +   
  scale_y_continuous(label = scales::dollar) +
  scale_color_brewer(palette="Set1") +
  theme_minimal()

# 여전히 통계에 관한 내용이 나와 어렵습니다. 좀 더 쉬운 그래프가 없을까요?
# 전체 데이터를 나타날 수 있도록 만드는 그래프를 작성해봅니다. 
library(ggpol)
library(scales)
ggplot(Salaries, 
       aes(x = factor(rank,
                      labels = c("Assistant Professor",
                                 "Associate Professor",
                                 "FullTime Professor")), 
           y = salary, 
           fill=rank)) +
  geom_boxjitter(color="black",
                 jitter.color = "darkgrey",
                 errorbar.draw = TRUE) +
  scale_y_continuous(label = dollar) +
  labs(x = "",
       y = "") +
  theme_minimal() +
  theme(legend.position = "none")

# 위와 같은 형태로 작성 시, 기존의 박스플롯 그래프보다 시각적으로 쉽게 나타낼 수 있습니다. 

# ----- (3) 산점도그래프와 회귀식의 만남 -----
# 가장 기본적인 그래프 작성은 아래와 같습니다. 
# simple scatterplot
ggplot(Salaries, 
       aes(x = yrs.since.phd, 
           y = salary)) +
  geom_point()

# 위 그래프에서 확인할 수 있는 정보는 많지 않습니다. 
# 산점도를 그릴 때 가장 중요한 포인트는 X와 Y축의 관계를 통해서, 수치가 증가하는지, 감소하는지, 큰 관련이 없는지를 찾는 것이 중요합니다. 
# 이 때 가장, 확실한 방법은 회귀식을 그려보는 것입니다. 
ggplot(Salaries, 
       aes(x = yrs.since.phd, 
           y = salary)) +
  geom_point(color= "steelblue") +
  geom_smooth(color = "tomato")

# 위 그래프보다 아래 그래프를 보면 무언가 조금 더 세련되게 그래프가 작성됨을 볼 수 있습니다. 
ggplot(Salaries, 
       aes(x = yrs.since.phd, 
           y = salary)) +
  geom_point(color="cornflowerblue", 
             size = 2, 
             alpha = .6) +
  geom_smooth(size = 1.5,
              color = "darkgrey") +
  scale_y_continuous(label = scales::dollar, 
                     limits = c(50000, 250000)) +
  scale_x_continuous(breaks = seq(0, 60, 10), 
                     limits = c(0, 60)) + 
  labs(x = "Years Since PhD",
       y = "") + 
  theme_minimal()

#### 5-3. 통계쟁이들을 위한 그래프 ####
# ----- (1) 상관관계 그래프 -----
data("mtcars")

# 숫자 데이터만 가져올 것
df <- dplyr::select_if(mtcars, is.numeric)

# calulate the correlations
r <- cor(df, use="complete.obs")
round(r,2)

library(ggplot2)
library(ggcorrplot)
ggcorrplot(r)

ggcorrplot(r, 
           hc.order = TRUE, 
           type = "lower",
           lab = TRUE)

# ----- (2) 회귀모형 그래프 -----
# 부동산 예측 가격에 대한 그래프를 작성해봅니다. 
install.packages("mosaicData")
data(SaratogaHouses, package="mosaicData")

houses_lm <- lm(price ~ lotSize + age + landValue +
                  livingArea + bedrooms + bathrooms +
                  waterfront + heating, 
                data = SaratogaHouses)

summary(houses_lm) # 통계를 처음 접하시는 분은 일단 넘어가세요.
library(ggplot2)
library(visreg)
visreg(houses_lm, "livingArea", gg = TRUE) 

visreg(houses_lm, "waterfront", gg = TRUE) +
  scale_y_continuous(label = scales::dollar) +
  labs(title = "Relationship between price and location",
       subtitle = "controlling for lot size, age, land value, bedrooms and bathrooms",
       caption = "source: Saratoga Housing Data (2006)",
       y = "Home Price",
       x = "Waterfront") + 
  theme_minimal()

# ---- (3) 로지스틱 회귀식 그래프 -----
# fit logistic model for predicting
# marital status: married/single
data(CPS85, package = "mosaicData")

cps85_glm <- glm(married ~ sex + age + race + sector, 
                 family="binomial", 
                 data=CPS85)

# plot results
library(ggplot2)
library(visreg)
visreg(cps85_glm, "age",
       by = "sex",
       gg = TRUE, 
       scale="response") +
  labs(y = "Prob(Married)", 
       x = "Age",
       title = "Relationship of age and marital status",
       subtitle = "controlling for race and job sector",
       caption = "source: Current Population Survey 1985") + 
  theme_minimal()

# 이번 시간의 목적은 ggplot2 패키지를 활용하여 어디까지 가능할 것인지 탐색하는 과정이었습니다. 
# 코드 한줄한줄에 관한 내용은 아래 링크에서 구체적으로 참고하시기를 바랍니다. 
# https://r4ds.had.co.nz/graphics-for-communication.html
# https://r4ds.had.co.nz/data-visualisation.html

# 위에 있는 코드를 직접 실행하면서 익히시기를 바랍니다. 
# 조금더 디텔이하게 코드를 분석 및 연습하고 싶다면, week_3_2_R_ggplot2.R을 week_3_3_R_ggplot2.R을 참조하시기를 바랍니다. 

# 소스코드 출처: 

# End of Document

