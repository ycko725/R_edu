#--------------------------------------------------------
################# ggplot2 그래프 시각화 #################
#--------------------------------------------------------
#### 1. 더 많은 변수들을 보여주는 기술 (1) geom 속성 값 이용 ####
# 지난 시간까지 그래프를 그리는 여러가지 방법에 대해 배움
# 그러나, 대부분의 데이터셋은 변수가 1개 또는 2개에 머무르지 않고 최소 3개 이상인 경우가 대부분임
# 변수가 많은 다변량일 경우, 시각화시 크게 2가지 중 한개를 선택해야 합니다. 
# 첫번째, geom_*()의 속성값으로 다른 변수를 표시하는 방법
# 두번째, 제 3의 변수를 각 범주별로 구분하는 방법입니다. 
# 여기서, 주의점, Too Much is always Too Bad. 
# 시각화를 하는 목적은 간결함이지, 복잡도가 아닙니다. 
# 더 많은 변수들을 보여주기 전, 항상 보는 사람의 관점에서 그래프를 작성해야 합니다. 
# 자세한 설명은 여기를 참조하시기를 바랍니다. 
# Review
library(dplyr)
library(ggplot2)
iris <- iris
str(iris)

colours()

ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point(colour = "skyblue4")

str(mtcars)
ggplot(mtcars, aes(x = cyl)) + 
  geom_bar(fill = "#C4D950")


#### -- (1) colour and Fill ####
# 설정방법은 색상 이름을 지정하는 방법이 3가지 있음
# 1. 영어 이름으로 지정 (ex. red, blue 등) 색상의 이름이 궁금하다면, colours() 지정하면 됨.
colours()

# 2. rgb specification (ex. "#RRGGBB")
# 3. munsell 패키지 활용하여, 색상을 rgb로 형태로 도출 가능 (- 구체적으로 말하면 먼셀 색 체계: 색상, 명도, 채도 3가지 요소를 이용하여 색을 나타내는 색 공간)
# 위 패키지는 디자이너에게 요청 필요
# 개인적으로 한번도 사용해 본적은 없음
# 색상표 참고: http://rokmc65371.blog.me/221074220644

library(munsell)
mnsl("5R 4/14") # 빨간색

ggplot(mtcars, aes(x = cyl)) + 
  geom_bar(fill = "#BE1A34")

#### -- (2) Line ####
# Line의 형태는 size, linetype, linejoin, and lineend에 따라 달라짐
# linetype 
# An integer or name: 0 = blank, 1 = solid, 2 = dashed, 3 = dotted, 4 = dotdash, 5 = longdash, 6 = twodash
lty_type = c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash")

linetypes_df <- data.frame(
  y = seq_along(lty_type), 
  lty_type = lty_type, 
  lty_name = paste("_No.", seq_along(lty_type), lty_type)
)


# example
ggplot(linetypes_df, aes(0, y)) + 
  geom_segment(aes(xend = 5, yend = y, linetype = lty_type)) + 
  scale_linetype_identity() + 
  geom_text(aes(label = lty_name), hjust = 0, nudge_y = 0.2) + 
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_reverse(NULL, breaks = NULL) + 
  theme_minimal()

data("economics")
# 참조: https://ggplot2.tidyverse.org/reference/geom_path.html

glimpse(economics)
ggplot() + 
  geom_line(data = economics %>% filter(date < "1980-01-01"), aes(x = date, y = psavert), linetype = "solid", colour = "red") + 
  geom_line(data = economics %>% filter(date > "1980-01-01"), aes(x = date, y = psavert), linetype = "solid", colour = "black") + 
  theme_minimal()
  

#### -- (3) Size ####
# The size of a line is its width in mm
# 점의 모양
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point(shape = 3, colour = "skyblue4", size = 4)


# line의 두께
ggplot(economics) + 
  geom_line(aes(x = date, y = psavert), linetype = "solid", colour = "#4DF0AD", size = 2) + 
  theme_minimal()


#### -- (4) Shape ####
# integer는 1~25
shapes_df <- data.frame(
  shape = c(0:19, 22, 21, 24, 23, 20), 
  x = 0:24 %/% 5, 
  y = -(0:24 %% 5)
)

shapes_df

ggplot(shapes_df, aes(x, y)) + 
  geom_point(aes(shape = shape), size = 5, fill = "red") + 
  scale_shape_identity() + 
  geom_text(aes(label = shape), hjust = 0, nudge_y = 0.2) + 
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_reverse(NULL, breaks = NULL) + 
  theme_minimal()


#### (6) 최종 geom_*()의 속성값을 이용하여 객체를 추가하자. ####
p1 <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point(aes(size = Petal.Length, colour = Species)) + 
  theme(legend.position = "top")

p2 <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point()


# 위 두개의 그래프를 비교 해석해보세요.
library(gridExtra)
grid.arrange(p1, p2, ncol = 2)


# 실습 2. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요.


#### 2. 더 많은 변수들을 보여주는 기술 (2) facet_* 함수 사용 ####
# 한국적인 표현으로는 면 분할이라고 함
# 언제 사용이 필요한가? 
# 데이터 범주간 비교 분석 할 때 사용되며 방법은 크게 2가지가 있음
library(ggplot2)
library(reshape2)
library(gridExtra)

head(tips)

# (1) facet_grid
p1 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point() + 
  facet_grid(sex ~ .) # 행기준

p2 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point() + 
  facet_grid(. ~ sex) # 열기준


grid.arrange(p1, p2, ncol = 2)

ggplot(tips, aes(x = total_bill, y = tip, colour = time)) + 
  geom_point(size = 3) + 
  facet_grid(day ~ sex) + 
  theme_minimal()

# (2) facet_wrap
p1 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point()

p2 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point() +
  facet_wrap( ~ sex, ncol = 1) # 열 기준

ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point() +
  facet_wrap( ~ sex, nrow = 1) # 열 기준

?facet_wrap

#### 3. 그래프에 주석 추가하기 ####
# 실무 팁! 만약 PPT 또는 이미지 수정이 즉시 가능하다면, Adobe와 같은 이미지 툴을 바로 사용하자. 
# 경험적으로 이게 더 빠르다. 
# 가급적 시각화에 불필요한 텍스트 사용은 지양하자.
library(ggplot2)
library(dplyr)
str(iris)
ggplot(iris %>% filter(Species != "setosa"), 
       aes(x = Sepal.Length, y = Sepal.Width, colour = Species)) + 
  geom_point() + 
  theme_minimal()

p1 + annotate(geom = "text", x = 7, y = 2.3, label = "virginica", size = 5)

mtcars

ggplot(mtcars, aes(x = wt, y = hp)) + 
  geom_point(alpha = .5, colour = "red") + 
  geom_text(aes(label = rownames(mtcars)), hjust = 0, nudge_x = 0.3, check_overlap = TRUE) + 
  xlim(0, 10) + 
  theme_minimal()

# 참조: https://cran.r-project.org/web/packages/ggrepel/vignettes/ggrepel.html

# install.packages("ggrepel")
library(ggrepel)

ggplot(mtcars, aes(x = wt, y = hp)) + 
  geom_point(alpha = .5, colour = "red") + 
  geom_label_repel(aes(label = rownames(mtcars), fill = factor(cyl))) + 
  theme_minimal()


#### 4. 데이터의 축 다루기 ####
# x축과 y축은 표현된 데이터를 해석하는 데 필요한 맥락을 제공한다. 
# 그래프의 성격 또는 값의 갯수에 따라 x축과 y축을 바꿔서 정렬할 필요가 있음
# Case 1. x축과 y축 데이터 뒤바꾸기
library(ggplot2)
library(gridExtra)

mtcars

ggplot(mtcars, aes(x = reorder(rownames(mtcars), -mpg), y = mpg)) + 
  geom_bar(stat = "identity", fill = "orange") + 
  coord_flip() + 
  theme_minimal()


# Case 2. 연속적인 축의 범위 설정
# 주 목적: 최소값과 최대값의 범위를 조정한다. 로그값을 정하는 이유와 비슷함
ggplot(PlantGrowth, aes(x = group, y = weight)) + 
  geom_boxplot() + 
  theme_minimal() -> p

p + ylim(4, 6.5) # 강사의 선호
p + coord_cartesian(ylim = c(4, 6.5)) 

# 눈금 표시 방법
p + 
  scale_y_continuous(limits = c(0, 10), 
                     breaks = c(1, 3, 5, 7, 9), 
                     labels = c("1st", "third", "five", "seven", "9"))

  

# 범주형 축 항목 순서 변경하기
p + 
  scale_x_discrete(limits = c("trt1", "ctrl")) + 
  scale_y_continuous(limits = c(0, 10), 
                     breaks = c(1, 3, 5, 7, 9), 
                     labels = c("1st", "third", "five", "seven", "9\nnine"))


# 불필요한 범주형 항목은 아래와 같이 나타나지 않게 지정 가능


# 눈금 라벨의 텍스트 변경하기



# 
# 로그 축에 눈금 표시 목적
## 시각적인 거리가 일정한 ‘비율’의 변화를 나타낼 수 있음
## 이상치 데이터가 존재할 경우 매우 유용함
# 주요 함수
## scale_x(y)_log10() : x축의 눈금에 로그함수 취함 
## trans_format() : 지수표기법으로 변경 위해
library(MASS)
library(scales)

ggplot(Animals, aes(x = body, y = brain, label = rownames(Animals))) + 
  geom_text(size = 3) + 
  theme_minimal() + 
  theme(axis.text.x = element_text(size = 16)) + 
  scale_x_log10(breaks = 10^(-1:5), 
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_y_log10()

?trans_format


# R에서 표기법
10^(-1:5)
10^(0:3)

ggplot(Animals, aes(x = body, y = brain, label = rownames(Animals))) + 
  geom_text(size = 3) + 
  theme_minimal() + 
  theme(axis.text.x = element_text(size = 16)) + 
  scale_x_continuous(trans = log_trans(), 
                     breaks = trans_breaks("log", function(x) exp(x)), 
                     labels = trans_format("log", math_format(e^.x))) + 
  scale_y_continuous(trans = log10_trans())


# Case 6. 축에 날짜 사용하기
# 실무에서 가장 쉽게 접하는 데이터는 날짜가 있는 데이터임
## 기본적으로는 X축 대신 날짜를 대신 입력하는 개념
##  날짜 데이터 처리에 관해서는 추후 lubridate 패키지 사용 권장
### 단, 여기에서는 기본함수로 작성 예정
# 주요 함수
## scale_x_date() : x축의 눈금에 날짜 입력값 지정
library(lubridate)
library(dplyr)
library(ggplot2)
library(scales)

temp_date <- Sys.Date()
year(temp_date)

temp_date <- "2020.07.01" # 일자 / 월 / 연도
ymd(temp_date)

temp_date <- "Sep, 12th 2021 14:01:05"
mdy_hms(temp_date)

# 데이터를 2000년 1월 ~ 2010년 12월 데이터를 가져오자.
data("economics")
glimpse(economics)

economics_2010s = subset(economics, 
                         date >= as.Date("2000-01-01") &
                         date < as.Date("2010-12-01"))

breaks_date = seq(from = as.Date("2000-01-01"), 
                  to = as.Date("2010-12-01"), 
                  by = "6 month")

breaks_date

ggplot(economics_2010s, aes(x = date, y=uempmed)) + 
  geom_line() + 
  theme_minimal() + 
  scale_x_date(breaks = breaks_date, 
               date_labels = paste0("%Y","년 ", "%m", "월")) + 
  theme(axis.text.x = element_text(angle = 30, hjust = 1, family = "AppleGothic"))


#### 5. 그래프의 범례 다루기 ####
# 그래프의 범례 설정의 주 목적
## 그래프의 축과 같이 일종의 안내자 역할
## 독자에게 시각적인(에스테틱) 속성들을 데이터 값들로 어떻게 해석해야 하는지를 알려줌
## 그래프의 특징에 따라 범례를 별도 지정, 또는 삭제 해야 함
## 범례의 위치, 항목의 순서, 제목 지정 등을 코드로 익힘
library(ggplot2)
library(dplyr)

glimpse(mpg)

# 1. 범례 제거
ggplot(mpg, aes(x = class, y = hwy, fill = class)) + 
  geom_boxplot() + 
  theme(legend.position = "none")


# 2. 범례의 위치 변경하기
ggplot(mpg, aes(x = class, y = hwy, fill = class)) + 
  geom_boxplot() + 
  scale_fill_brewer(palette = "Pastel2") + 
  theme(legend.position = c(0.9, 0.4))


# 3. 범례의 제목 변경하기
ggplot(mpg, aes(x = class, y = hwy, fill = class)) + 
  geom_boxplot() + 
  scale_fill_brewer(palette = "Pastel2") + 
  scale_fill_discrete(name = "change_class") + 
  theme(legend.position = c(0.9, 0.4))

ggplot(mpg, aes(x = class, y = hwy, fill = class)) + 
  geom_boxplot() + 
  scale_fill_brewer(palette = "Pastel2") + 
  labs(title = "title", 
       subtitle = "subtitle", 
       x = "x-axis title", 
       y = "y", 
       caption = "Image Created by ??", 
       fill = "change_class") + 
  theme(legend.position = c(0.9, 0.4))

library(gcookbook)

str(heightweight)
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point(aes(size = weightLb)) + 
  scale_size_continuous(range = c(1, 4)) + 
  labs(colour = "Male/Female", size = "Weight\n(pounds)") + 
  scale_colour_discrete(labels = c("Female", "Male")) + 
  theme_minimal()

# 4. 범례에 속한 라벨 변경하기
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point(aes(size = weightLb)) + 
  scale_size_continuous(range = c(1, 4)) + 
  labs(colour = "Male/Female", size = "Weight\n(pounds)") + 
  scale_colour_discrete(labels = c("Female", "Male")) + 
  theme_minimal()
  
# 5. 범례제목 지우기
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point(aes(size = weightLb)) + 
  scale_size_continuous(range = c(1, 4)) + 
  labs(colour = "Male/Female", size = "Weight\n(pounds)") + 
  scale_colour_discrete(labels = c("Female", "Male")) + 
  guides(colour = guide_legend(title = NULL), 
         size = guide_legend(title = NULL)) + 
  theme_minimal()


# 6. 그래프의 테마(theme) 다루기
# 그래프의 배경 등 외형 제어할 수 있도록 도와줌
# 분석가는 데이터를 다루는 것이 중요하나, 독자에게는 그래프의 외형, 색깔, 글씨 폰트 등이 중요함
# 그래프의 제목, 외형, 테마 설정, 외형 변경
# 사용자 정의 테마 만들기 

library(gcookbook)
library(ggplot2)

# 1. 그래프의 제목 
ggplot(heightweight, aes(x = ageYear, y = heightIn)) + 
  geom_point() + 
  labs(title = "Plot Title Here") + 
  theme_minimal() + 
  theme(plot.title = element_text(vjust = -8, hjust = 0.01))


# 2. 텍스트의 외형 변경하기
ggplot(heightweight, aes(x = ageYear, y = heightIn)) + 
  geom_point() + 
  labs(title = "Plot Title Here") + 
  theme_minimal() + 
  theme(plot.title = element_text(vjust = -8, hjust = 0.01), 
        axis.title = element_text(size = 16, 
                                  lineheight = .9, 
                                  family = "Times", 
                                  face = "bold.italic", 
                                  colour = "red"))

# 3. 테마 사용하기
ggplot(heightweight, aes(x = ageYear, y = heightIn)) + 
  geom_point() + 
  labs(title = "Plot Title Here") + 
  theme(plot.title = element_text(vjust = -8, hjust = 0.01), 
        axis.title = element_text(size = 16, 
                                  lineheight = .9, 
                                  family = "Times", 
                                  face = "bold.italic", 
                                  colour = "red"))


# 테마 설정하기
theme_set(theme_minimal())
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point()



# 4. 테마 요소의 외형 변경하기 예제


## 1. 그래프 관련 옵션
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point() + 
  theme(
    panel.grid.major = element_line(colour = "yellow"), 
    panel.grid.minor = element_line(colour = "blue", linetype = "dashed"),
    panel.background = element_rect(fill = "lightblue"), 
    panel.border = element_rect(colour = "blue", fill = NA, size = 3)
  )


## 2. 텍스트 항목 관련 옵션들
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point() + 
  labs(title = "Title Plot Here") + 
  theme(
    plot.title = element_text(colour = "red", size = 20, face = "bold.italic")
  )


## 3. 범례 관련 옵션들
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point() + 
  theme(
    legend.background = element_rect(fill = "grey85", colour = "red", size = 1), 
    legend.title = element_text(colour = "blue", face = "bold", size = 14), 
    legend.text = element_text(colour = "red"), 
    legend.key = element_rect(colour = "blue", size = 0.25)
  )


## 4. 면 분할 관련 옵션들
ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point() + 
  facet_grid(sex ~ .) + 
  theme(
    strip.background = element_rect(fill = "pink"), 
    strip.text.y = element_text(size = 14, angle = -90, face = "bold")
  )


# 5. 사용자 정의 테마 설정
library(ggthemes)
my1stTheme <- theme_wsj() + 
  theme(axis.title.x = element_text(size = 20), 
        panel.grid.major = element_line(colour = "red", linetype = "dashed")
        )

ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point() + 
  my1stTheme
