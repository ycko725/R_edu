#--------------------------------------------------------
################# ggplot2 그래프 시각화 #################
#--------------------------------------------------------
#### 수량형 변수 1개일 때 ####
# 1. 그래프 종류
# : Frequency Polygon, Kernel Density Estimator, Histogram
# 2. 그래프 해석 시 고려사항
# : 이상점은 없는가?
# : 전반적 분포의 모양은 어떠한가? 
# : 어떤 변환을 하면 데이터가 종모양에 가까워지는가?
# : 히스토그램이 거칠지 않은가?

# install.packages("gapminder")
library(gapminder) # 데이터셋 
library(dplyr) # 데이터 전처리 패키지
library(ggplot2) # 시각화 패키지 
library(gridExtra) # 시각화의 화면분할 패키지

data("gapminder")
glimpse(gapminder)

# 전반적 분포의 모양은 어떠한가요?
ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_histogram()

# 분포의 모양이 치우쳐져 있다면, log변환을 해봅니다. 
ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_histogram() + 
  scale_x_log10()

# 다른 그래프로 그려봅니다. 
ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_freqpoly()

ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_freqpoly() + 
  scale_x_log10()

p1 <- ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_histogram() + 
  labs(title = "Basic Histogram ggplot")

p2 <- ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_histogram() + 
  scale_x_log10() + 
  labs(title = "Log Transformation Histogram ggplot")

p3 <- ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_freqpoly() + 
  labs(title = "Basic Freqpoly ggplot")

p4 <- ggplot(gapminder, aes(x = gdpPercap)) + 
  geom_freqpoly() + 
  scale_x_log10() + 
  labs(title = "Log Transformation Freqpoly ggplot")

grid.arrange(p1, p2, p3, p4)

# 실습 1. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요. 
data("mtcars")
glimpse(mtcars)

# gapminder 
help("gapminder")

# Color by continent
theme_set(theme_classic())

ggplot(gapminder, aes(gdpPercap)) + 
  geom_density()

ggplot(gapminder, aes(gdpPercap)) + 
  geom_density(aes(fill = continent), alpha = .8)

# 실습 2. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요. 
data("USArrests")
glimpse(USArrests)

#### 범주형 변수 1개일 때 ####
# 1. 그래프 종류
# : 막대 그래프, Pie Chart, Dot 그래프
# 2. 그래프 해석 시 고려사항
# : 범주별 도수분포, 상대도수 어떻게 되는가? 
data("diamonds")
glimpse(diamonds)

theme_set(theme_classic())

help("diamonds")

# 기본 막대그래프
p1 <- ggplot(diamonds, aes(cut)) + 
  geom_bar(fill = "#007777") + 
  labs(title = "Basic Bar Graph")

p1

# 갯수를 막대그래프에 표현하기
count_df <- diamonds %>% 
  group_by(cut) %>% 
  summarise(counts = n())
count_df

p2 <- ggplot(count_df, aes(x = cut, y = counts)) + 
  geom_bar(fill = "#007777", stat = "identity") + 
  geom_text(aes(label = counts), vjust = -0.3) + 
  labs(title = "Basic Bar Graph with Text")
p2

# pie Charts
# 퍼센트 구하기
df <- count_df %>% 
  dplyr::arrange(desc(cut)) %>% 
    mutate(prop = round(counts * 100 / sum(counts), 1), 
           lap.ypos = cumsum(prop) - 0.5 * prop)

df

p3 <- ggplot(df, aes(x = "", y = prop, fill = cut)) + 
  geom_bar(width = 1, stat = "identity", color = "white") + 
  geom_text(aes(y = lap.ypos, label = prop), color = "white") + 
  coord_polar("y", start = 0) + 
  ggpubr::fill_palette("jco") + 
  theme_void() + 
  labs(title = "Pie Chart")

p3

# dot charts
library(ggpubr)
p4 <- ggplot(df, aes(x = cut, y = prop)) + 
  geom_linerange(aes(x = cut, ymin = 0, ymax = prop), 
                 color = "lightgray", size = 1.5) + 
  geom_point(aes(color = cut), size = 2) + 
  ggpubr::color_palette("jco") + 
  labs(title = "Dot Graph")

grid.arrange(p1, p2, p3, p4)

# 실습 2. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요. 
data("Titanic")
data <- Titanic %>% as_tibble()
class(data)
glimpse(data)

#### 수량형 변수 2개일 때 ####
# 1. 그래프 종류
# : 산점도(scatterplot), Bubble Chart, 2D Density Estimation
# 2. 그래프 해석 시 고려사항
# : 데이터의 개수가 많을 때는 약 1000개로 샘플링
# : 데이터의 개수가 너무 많을 때는 alpha= 값을 줄여서 점들을 좀 더 투명하게 만든다. 
# : x나 y변수에 제곱근 혹은 로그변환이 필요한지 살펴본다. 
# : 데이터의 상관 관계가 강한지 혹은 약한지 살펴본다. 
# : 데이터의 관계가 선형인지 혹은 비선형인지 살펴본다. 
# : 이상점이 있는지 살펴본다. 
# : X와 Y의 관계가 인과 관계인지 확인한다. 
library(gapminder)
library(dplyr)
library(ggplot2)
data("gapminder")
glimpse(gapminder)

p1 <- gapminder %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
    geom_point() + 
    labs(title = "Basic Scatterplot Graph")

gapminder %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
    geom_point() + 
    scale_x_log10()

glimpse(mpg)

mpg %>% 
  ggplot(aes(x = cyl, y = hwy)) + 
    geom_point()

mpg %>% 
  ggplot(aes(x = cyl, y = hwy)) + 
    geom_jitter()

p2 <- gapminder %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
  geom_point() + 
  scale_x_log10() + 
  geom_smooth(method = "lm") + 
  ggpubr::stat_cor(method = "pearson", 
           label.x = 3.5, label.y = 85) + 
  labs(title = "Basic Scatterplot Graph with correlation value")

p2

levels(diamonds$cut)
library(RColorBrewer)
display.brewer.all()
pal <- brewer.pal(5, "Spectral")
p3 <- ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(aes(color = cut, size = depth), alpha=0.8) +
  scale_color_manual(values = pal) + 
  labs(title = "Basic Bubble Chart")

library(datasets)
data("faithful")
glimpse(faithful)

ggplot(faithful, aes(x = waiting, y = eruptions)) + 
  geom_point(color = "lightgray") + 
  geom_density_2d()

p4 <- ggplot(faithful, aes(x = waiting, y = eruptions)) +
  geom_point(color = "lightgray") + 
  stat_density_2d(aes(fill = ..level..), geom = "polygon") + 
  scale_fill_gradientn(colours = c("#FFEDA0", "#FEB24C", "#F03B20")) + 
  labs(title = "Basic 2d Chart")

library(gridExtra)
grid.arrange(p1, p2, p3, p4)

# 실습 2. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요. 
data("iris")

#### 수량형 변수 1개와 범주형 변수 1개일 때 ####
# 1. 그래프 종류
# : 병렬상자그림(box plot)
# 2. 그래프 해석 시 고려사항
# : 범주형 x변수의 적절한 순서를 고려한다. 
# : 수량형 y 변수의 제곱근과 로그변환을 통해 비교한다.
# : x와 y축을 교환할 필요는 없는가? coord_flip() 함수를 사용한다. 
# : 유용한 차트를 얻기 위해서는 다양한 옵션 시도한다. 
library(dplyr)
library(ggplot2)

theme_set(theme_classic())
glimpse(mtcars)
p1 <- mtcars %>% 
  ggplot(aes(x = as.factor(cyl), y = mpg)) + 
    geom_jitter(col = "gray") + 
    geom_boxplot(alpha=.5, varwidth=T, fill="plum") + 
    labs(title = "Basic Box Plot")

p1

mtcars$cyl <- as.factor(mtcars$cyl)
mtcars %>% 
  ggplot(aes(x = cyl, y = mpg)) + 
  geom_jitter(alpha = .5) + 
  geom_boxplot(notch = TRUE, varwidth=T, fill="plum") + 
  stat_summary(fun.y = mean, geom = "point", shape = 15, size = 2.5, color = "red") + 
  labs(title = "Basic Box Plot with Stat")

# Box plot & Dot Plot
library(gapminder)
data(gapminder)
sample <- sample_n(gapminder, size = 100)
p2 <- sample %>% 
  ggplot(aes(x = continent, y = lifeExp)) + 
  geom_boxplot() + 
  geom_dotplot(binaxis='y', 
               stackdir='center', 
               dotsize = .5, 
               fill="red") + 
  labs(title = "Basic Box Plot with Dotplots")

p2

# Tufte Boxplot
library(ggthemes)
p3 <- sample %>% 
  ggplot(aes(x = continent, y = lifeExp)) + 
  geom_tufteboxplot() + 
  geom_dotplot(binaxis='y', 
               stackdir='center', 
               dotsize = .5, 
               fill="red") + 
  labs(title = "Basic tufteBoxPlot")
p3
  
# Violin Graph
p4 <- sample %>% 
  ggplot(aes(x = continent, y = lifeExp)) + 
  geom_violin() + 
  geom_dotplot(binaxis='y', 
               stackdir='center', 
               dotsize = .5, 
               fill="red") + 
  labs(title = "Basic Violin")

library(gridExtra)
grid.arrange(p1, p2, p3, p4)

# 실습 2. 
# 다음 데이터를 활용하여 위 그래프를 그려보세요. 
install.packages("nycflights13")
library(nycflights13)
library(dplyr)
data(flights)
glimpse(flights)

#### 범주형 변수 2개일 때 ####
# 1. 그래프 종류
# : bar plot, balloon plot, mosaic plot
# 2. 그래프 해석 시 고려사항
# : 범주형 변수간 관계를 파악한다.
# : 비율 or 갯수 등 어떤 표시를 해야할지 고려한다.
# : 실제로, 두 범주형 변수만 다루는 일은 아주 많지 않음
# : ggplot 그래프 외, 다른 패키지 사용 필요 (vcd 등) 

library(ggplot2)
library(ggpubr)
theme_set(theme_pubr())
par(mfrow=c(2,2))

data("HairEyeColor")
HairEyeColor <- as.data.frame(HairEyeColor)
glimpse(HairEyeColor)
ggplot(HairEyeColor, aes(x = Hair, y = Freq, fill = Eye))+
  geom_bar(stat = "identity", 
           color = "white", 
           position = position_dodge(0.9)
  ) + 
  facet_wrap(~Sex)

housetasks <- read.delim(
  system.file("demo-data/housetasks.txt", package = "ggpubr"),
  row.names = 1
)
ggballoonplot(housetasks, fill = "value")+
  scale_fill_viridis_c(option = "C")

ggballoonplot(HairEyeColor, x = "Hair", y = "Eye", size = "Freq",
              fill = "Freq", facet.by = "Sex",
              ggtheme = theme_bw()) +
  scale_fill_viridis_c(option = "C")

# install.packages("vcd")
library(vcd)
data("HairEyeColor")
glimpse(HairEyeColor)
mosaic(HairEyeColor, shade = TRUE, legend = TRUE) 

library(FactoMineR)
library(factoextra)
res.ca <- CA(housetasks, graph = FALSE)
fviz_ca_biplot(res.ca, repel = TRUE)
?fviz_ca_biplot

