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
library(ggplot2)
ggplot(iris, 
       aes(x = Sepal.Length, 
           y = Sepal.Width)) + 
  geom_point(colour = "skyblue4")

ggplot(mtcars, aes(x = cyl)) + 
  geom_bar(fill = "tomato3")

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
lty_type <- c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash")

linetypes <- data.frame(
  y = seq_along(lty_type), 
  lty_type = lty_type,
  lty_name = paste("_No.", seq_along(lty_type), "", lty_type)
)

ggplot(linetypes, aes(0, y)) + 
  geom_segment(aes(xend = 5, yend = y, linetype = lty_type)) + 
  scale_linetype_identity() + 
  geom_text(aes(label = lty_name), hjust = 0, nudge_y = 0.2) +
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_reverse(NULL, breaks = NULL)

# example
data("economics")

library(dplyr)
glimpse(economics)
ggplot(economics, aes(x = date, y = uempmed)) + 
  geom_line(linetype = 3)

#### -- (3) Size ####
# The size of a line is its width in mm
# 점의 모양
ggplot(iris, 
       aes(x = Sepal.Length, 
           y = Sepal.Width)) + 
  geom_point(colour = "skyblue4", size = 10)

# line의 두께
ggplot(economics, aes(x = date, y = uempmed)) + 
  geom_line(linetype = 1, size = 10)

#### -- (5) Shape ####
# integer는 1~25
shapes <- data.frame(
  shape = c(0:19, 22, 21, 24, 23, 20),
  x = 0:24 %/% 5,
  y = -(0:24 %% 5)
)

ggplot(shapes, aes(x, y)) + 
  geom_point(aes(shape = shape), size = 5, fill = "red") +
  geom_text(aes(label = shape), hjust = 0, nudge_x = 0.15) +
  scale_shape_identity() +
  expand_limits(x = 4.1) +
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_continuous(NULL, breaks = NULL)

ggplot(iris, 
       aes(x = Sepal.Length, 
           y = Sepal.Width)) + 
  geom_point(colour = "red", shape = 3)

#### (6) 최종 geom_*()의 속성값을 이용하여 변수를 추가하자. ####
p1 <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point(aes(size = Petal.Length, colour = Species)) + 
  ggtitle("add more vars using aes functions") + 
  theme(legend.position = "top")

p1

p2 <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point() + 
  ggtitle("basic")

library(gridExtra)
grid.arrange(p1, p2, ncol = 2)

# 위 두개의 그래프를 비교 해석해보세요.

# 실습 2. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요.
library(nycflights13)
library(dplyr)
data(flights)
glimpse(flights)

#### 2. 더 많은 변수들을 보여주는 기술 (2) facet_* 함수 사용 ####
# 한국적인 표현으로는 면 분할이라고 함
# 언제 사용이 필요한가? 
# 데이터 범주간 비교 분석 할 때 사용되며 방법은 크게 2가지가 있음
# (1) facet_grid
library(ggplot2)
library(reshape2)

head(tips)
p1 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1) + 
  ggtitle("Basic Graph")

p2 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1) + 
  facet_grid(sex ~ .) + # 행 기준
  ggtitle("Facet_grid divided by a row")

p3 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1) + 
  facet_grid(. ~ sex) + # 열 기준
  ggtitle("Facet_grid divided by a column")

glimpse(tips)
p4 <- ggplot(tips, aes(x = total_bill, y = tip, colour = time)) + 
  geom_point(shape = 1) + 
  facet_grid(day ~ sex) + # 행 기준 day / 열 기준 tip
  ggtitle("Facet_grid divided by row - day and column - sex")

p4

library(gridExtra)
grid.arrange(p1, p2, p3, p4)

# (2) facet_wrap
p1 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1) + 
  ggtitle("Basic Graph")

p2 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1) + 
  facet_wrap(~ day, ncol = 1) + # 열 기준
  ggtitle("Facet_wrap divided by column numbers") 

p3 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1) + 
  facet_wrap(~ day, nrow = 1) + # 행 기준
  ggtitle("Facet_wrap divided by row numbers") 

p4 <- ggplot(tips, aes(x = total_bill, y = tip)) + 
  geom_point(shape = 1, size = 3, aes(colour = sex)) + 
  facet_wrap(~ day, nrow = 1) + # 행 기준 + 변수 추가
  ggtitle("Facet_wrap divided by row numbers & by colour") 

library(gridExtra)
grid.arrange(p1, p2, p3, p4)

#### 3. 그래프에 주석 추가하기 ####
# 실무 팁! 만약 PPT 또는 이미지 수정이 즉시 가능하다면, Adobe와 같은 이미지 툴을 바로 사용하자. 
# 경험적으로 이게 더 빠르다. 
# 가급적 시각화에 불필요한 텍스트 사용은 지양하자.
library(ggplot2)
library(dplyr)
p <- ggplot(iris %>% filter(Species != "virginica"), aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point(aes(colour = Species)) + 
  theme_classic()

p1 <- p + annotate(geom = "text", x = 4.7, y = 4, label = "setosa", size = 5) + 
  ggtitle("Using annoate() - 1")

p1

p2 <- p + 
  annotate(geom = "text", x = 4.7, y = 4, label = "setosa", size = 5) + 
  annotate(geom = "text", x = 6.5, y = 3.5, label = "versicolor", size = 5) + 
  ggtitle("Using annoate() - 2")

p2

g <- ggplot(mtcars, aes(x = wt, y = mpg)) + 
  geom_point(alpha = .5, colour = "red")

g + 
  geom_text(aes(label = rownames(mtcars)), hjust = 0, nudge_x = 0.05)

g3 <- g + 
  geom_text(aes(label = rownames(mtcars)), check_overlap = TRUE, hjust = 0, nudge_x = 0.05) + # overlaps 제거하기
  ggtitle("Using geom_text()")

g3

library(ggrepel)
set.seed(42)
g4 <- g + 
  geom_label_repel(aes(label = rownames(mtcars), fill = factor(cyl))) + 
  ggtitle("Using geom_label_repel()")

g4 

library(gridExtra)
grid.arrange(p1, p2, g3, g4)

#### 4. 데이터의 축 다루기 ####
# x축과 y축은 표현된 데이터를 해석하는 데 필요한 맥락을 제공한다. 
# 그래프의 성격 또는 값의 갯수에 따라 x축과 y축을 바꿔서 정렬할 필요가 있음
# Case 1. x축과 y축 데이터 뒤바꾸기
library(ggplot2)
library(gridExtra)

p1 <- ggplot(mtcars, aes(x = reorder(rownames(mtcars), mpg), y = mpg)) + 
  geom_bar(stat = "identity", fill = "purple") + 
  theme_classic() + 
  ggtitle("Basic Grpah")

p1
p2 <- ggplot(mtcars, aes(x = reorder(rownames(mtcars), mpg), y = mpg)) + 
  geom_bar(stat = "identity", fill = "tomato2") + 
  coord_flip() + 
  theme_classic() + 
  ggtitle("Using coord_flip")

p2

grid.arrange(p1, p2, ncol = 2)

# Case 2. 연속적인 축의 범위 설정
# 주 목적: 최소값과 최대값의 범위를 조정한다. 로그값을 정하는 이유와 비슷함
p <- ggplot(PlantGrowth, aes(x = group, y = weight)) + geom_boxplot() + theme_bw()

p

p1 <- p + ggtitle("Basic Graph")

p2 <- p + 
  ylim(0, max(PlantGrowth$weight)) + 
  theme_bw() + 
  ggtitle("By Max Value of Weight")

p3 <- p + 
  ylim(0, 10) + 
  ggtitle("The Range 0 to 10")

p4 <- p + 
  coord_cartesian(ylim = c(4, 6.5)) + 
  ggtitle("Using coord cartesian (4 ~ 6.5)")

grid.arrange(p1, p2, p3, p4)

# 눈금 표시 방법
ggplot(PlantGrowth, 
       aes(x = group, y = weight)) + 
  geom_boxplot() + 
  scale_y_continuous(limits = c(0, 10), # 축 범위
                     breaks = c(1, 3, 5, 7, 9), # 축의 숫자 지정 
                     labels = c("1st", "three", "five", "seven", "nine"))
  

# 범주형 축 항목 순서 변경하기
p <- ggplot(PlantGrowth, aes(x = group, weight)) + 
  geom_boxplot() + 
  theme_bw() + 
  ggtitle("Basic Graph")

p1 <- p + 
  scale_x_discrete(limits = c("trt1", "trt2", "ctrl")) + 
  ggtitle("Change the order of X-Values")

grid.arrange(p, p1)

# 불필요한 범주형 항목은 아래와 같이 나타나지 않게 지정 가능
p2 <- p + 
  scale_x_discrete(limits = c("ctrl", "trt1"))

p2

# 눈금 라벨의 텍스트 변경하기
p <- ggplot(heightweight, aes(x = ageYear, y = heightIn)) + 
  geom_point() + 
  theme_bw()

p1 <- p + ggtitle("Basic Graph")
p2 <- p + 
  scale_y_continuous(breaks = c(50, 55, 60, 65, 70), 
                       labels = c("Tiny", "Really\nshort", "Short", "Medium", "Tallish")) + 
  ggtitle("Transforming Axis Text Label")

grid.arrange(p1, p2)  

# 
# 로그 축에 눈금 표시 목적
## 시각적인 거리가 일정한 ‘비율’의 변화를 나타낼 수 있음
## 이상치 데이터가 존재할 경우 매우 유용함
# 주요 함수
## scale_x(y)_log10() : x축의 눈금에 로그함수 취함 
## trans_format() : 지수표기법으로 변경 위해
library(MASS)
p <- ggplot(Animals, aes(x = body, y = brain, label = rownames(Animals))) + 
  geom_text(size = 3) + 
  theme_bw() +
  theme(axis.text.x = element_text(size = 24), 
        axis.text.y = element_text(size = 24))

p1 <- p + ggtitle("Basic Graph")
p2 <- p + scale_x_log10() + scale_y_log10() + ggtitle("Basic Graph with log10 Scale")
p1
p2

# R에서 표기법
10^(-1:5)
10^(0:3)

library(scales)
p3 <- p + 
  scale_x_log10(breaks = 10^(-1:5), 
                labels = trans_format("log10", 
                                      math_format(10^.x))) + 
  scale_y_log10() + 
  ggtitle("Basic Graph Using trans_format function")

p4 <- p + 
  scale_x_continuous(trans = log_trans(), 
                     breaks = trans_breaks("log", function(x) exp(x)), 
                     labels = trans_format("log", math_format(e^.x))) + 
  scale_y_continuous(trans = log2_trans(), 
                     breaks = trans_breaks("log2", function(x) 2^x), 
                     labels = trans_format("log2", math_format(2^.x))) + 
  ggtitle("Basic Graph Using log on X log2 on Y")

grid.arrange(p1, p2, p3, p4)

# Case 6. 축에 날짜 사용하기
# 실무에서 가장 쉽게 접하는 데이터는 날짜가 있는 데이터임
## 기본적으로는 X축 대신 날짜를 대신 입력하는 개념
##  날짜 데이터 처리에 관해서는 추후 lubridate 패키지 사용 권장
### 단, 여기에서는 기본함수로 작성 예정
# 주요 함수
## scale_x_date() : x축의 눈금에 날짜 입력값 지정

str(economics)

p1 <- ggplot(economics, aes(x = date, y = uempmed)) + 
  geom_line() + 
  theme_bw() + 
  theme(axis.text.x = element_text(size = 24), 
        axis.text.y = element_text(size = 24)) + 
  ggtitle("Basic Graph")

data("economics")

# 데이터를 2000년 1월 ~ 2010년 12월 데이터를 가져오자.
economics_2010s <- subset(economics, 
                          date >= as.Date("2000-01-01") & 
                          date < as.Date("2010-12-01"))

# 데이터를 6개월 단위로 표시하자
datebreaks <- seq(from = as.Date("2000-01-01"), 
                  to = as.Date("2010-12-01"), 
                  by = "6 month")

p2 <- ggplot(economics_2010s, aes(x = date, y = uempmed)) + 
  geom_line() + 
  ggtitle("Basic Graph with 2010s Data")

# 그래프 그리기
p3 <- ggplot(economics_2010s, aes(x = date, y = uempmed)) + 
  geom_line() + 
  scale_x_date(breaks = datebreaks, labels = date_format("%Y %b")) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 30, hjust = 1), 
        axis.text.y = element_text()) + 
  ggtitle("Date_format on X-Axis in English")

p4 <- ggplot(economics_2010s, aes(x = date, y = uempmed)) + 
  geom_line() + 
  scale_x_date(breaks = datebreaks, date_labels = paste0("%Y","년 " ,"%m", "월")) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 30, hjust = 1, family = "AppleGothic"), 
        axis.text.y = element_text()) + 
  ggtitle("Date_format on X-Axis in Korean")
grid.arrange(p1, p2, p3, p4)

#### 5. 그래프의 범례 다루기 ####
# 그래프의 범례 설정의 주 목적
## 그래프의 축과 같이 일종의 안내자 역할
## 독자에게 시각적인(에스테틱) 속성들을 데이터 값들로 어떻게 해석해야 하는지를 알려줌
## 그래프의 특징에 따라 범례를 별도 지정, 또는 삭제 해야 함
## 범례의 위치, 항목의 순서, 제목 지정 등을 코드로 익힘
library(ggplot2)
library(dplyr)

glimpse(mpg)
?scale_fill_manual

# 1. 범례 제거
ggplot(mpg, aes(x = class, y = hwy, fill = class)) + 
  geom_boxplot() + 
  theme(legend.position = "none")

# 2. 범례의 위치 변경하기
p <- ggplot(PlantGrowth, aes(x = group, y = weight, fill = group)) + 
  geom_boxplot() + 
  scale_fill_brewer(palette = "Pastel2") 

p + theme(legend.position = "top")
p + theme(legend.position = "bottom")
p + theme(legend.position = c(0.8,0.2))

# 3. 범례의 제목 변경하기
p
p + scale_fill_discrete(name = "Condition_1")
p + labs(fill = "Condition_2")

library(gcookbook)
p <- ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + 
  geom_point(aes(size = weightLb)) + 
  scale_size_continuous(range = c(1, 4))
p 
p + labs(colour = "Male/Female", size = "Weight\n(pounds)")

# 4. 범례에 속한 라벨 변경하기
p <- ggplot(PlantGrowth, aes(x = group, y = weight, fill = group)) + geom_boxplot()

p + scale_fill_discrete(labels = c("Control", "Treatment 1", "Treatment 2"))

p + 
  scale_fill_discrete(labels = c("Control", "Treatment 1", "Treatment 2")) + 
  scale_x_discrete(breaks = c("ctrl", "trt1", "trt2"), 
                   labels = c("Control", "Treatment 1", "Treatment 2"))
  
# 5. 범례제목 지우기
p <- ggplot(PlantGrowth, aes(x = group, y = weight, fill = group)) + geom_boxplot()

p
p + guides(fill = guide_legend(title = NULL))

# 6. 그래프의 테마(theme) 다루기
# 그래프의 배경 등 외형 제어할 수 있도록 도와줌
# 분석가는 데이터를 다루는 것이 중요하나, 독자에게는 그래프의 외형, 색깔, 글씨 폰트 등이 중요함
# 그래프의 제목, 외형, 테마 설정, 외형 변경
# 사용자 정의 테마 만들기 

# 1. 그래프의 제목 
library(gcookbook)
library(ggplot2)

p <- ggplot(heightweight, aes(x = ageYear, y = heightIn)) + geom_point()

p + labs(title = "Title Text")
p + 
  labs(title = "Title Text") +
  theme_bw() + 
  theme(plot.title = element_text(vjust = -8, hjust = 0.01))

# 2. 텍스트의 외형 변경하기
p + theme(axis.title = element_text(size = 16, lineheight = .9, family = "Times", face = "bold.italic", colour = "red"))

# 3. 테마 사용하기
p + theme_classic()
p + theme_bw()
p + theme_gray()

# 테마 설정하기
theme_set(theme_classic())
p

# 4. 테마 요소의 외형 변경하기 예제
p <- ggplot(heightweight, aes(x = ageYear, y = heightIn, colour = sex)) + geom_point()

p

## 1. 그래프 관련 옵션
p + theme(
  panel.grid.major = element_line(colour = "red"), 
  panel.grid.minor = element_line(colour = "red", linetype = "dashed"),
  panel.background = element_rect(fill = "lightblue"), 
  panel.border = element_rect(colour = "blue", fill = NA, size = 2)
)

## 2. 텍스트 항목 관련 옵션들
p + labs(title = "Plot Title Here") + 
  theme(
    axis.title.x = element_text(colour = "red", size = 14), 
    axis.text.x = element_text(colour = "blue"), 
    axis.title.y = element_text(colour = "red", size = 14, angle = 90), 
    axis.text.y = element_text(colour = "blue"), 
    plot.title = element_text(colour = "red", size = 20, face = "bold")
  )

## 3. 범례 관련 옵션들
p + theme(
  legend.background = element_rect(fill = "grey85", colour = "red", size = 1), 
  legend.title = element_text(colour = "blue", face = "bold", size = 14), 
  legend.text = element_text(colour = "red"), 
  legend.key = element_rect(colour = "blue", size = 0.25)
)

## 4. 면 분할 관련 옵션들
p + facet_grid(sex ~ .) + 
  theme(
    strip.background = element_rect(fill = "pink"), 
    strip.text.y = element_text(size = 14, angle = -90, face = "bold")
  )

# 5. 사용자 정의 테마 설정
my1stTheme <- theme_classic() + 
  theme(axis.title.x = element_text(size = 20))



glimpse(iris)
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + 
  geom_point() + my1stTheme


