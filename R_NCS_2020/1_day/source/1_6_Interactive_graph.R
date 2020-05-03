# --------------------------------------------------------------------------------
# 동적시각화와 관련된 다양한 패키지를 소개합니다.   
# --------------------------------------------------------------------------------

# 이번 장은 다양한 패키지를 일괄적으로 나열하여 보여드립니다. 
#### 1. plotly ####
# plotly(이하 플로틀리)의 미션은 
# Plotly is helping leading organizations close the gap between Data Science teams and the rest of the organization. With Plotly, your teams can easily design, develop, and operationalize data science initiatives that deliver real results.(출처: https://plot.ly/)

# 플로틀리가 지향하는 철학이 시각화의 철학과 일맥상통합니다. 
# 데이터 싸이언티스트가 만들어내는 시각화 결과물을 데이터와 친하지 않는 사람들에게 어떻게 보다 쉽게 실제 결과물을 전달 (deliver) 할 수 있는지가 오늘 수업의 핵심입니다. 

# plotly가 지원하는 주요언어: Python, R, JavaScript
# 현직이 프론트엔드 개발자이며, JavaScript와 친숙하다면, JavaScript를 배우는 것 추천
# 현직이 응용프로그램 개발자이며, Python과 친숙하다면, Python으로 배우는 것 추천
# 현직이 보고서 작성, PT와 관련있는 업종이라면, R로 배우는 것 추천

# 기본차트 예시
# ggplot2 그래프를 객체화해서 ggplotly() 에서 구현하는 것을 말합니다. 
# 필자경험상 plotly의 문법을 새로 익히는 것보다, ggplot2 문법을 마스터한 상태에서 ggplotly()로만 구현하는 것을 추천합니다. 
library(ggplot2)
library(plotly)

p <- ggplot(mpg, aes(x=displ, 
                     y=hwy, 
                     color=class)) +
  geom_point(size=3) +
  labs(x = "Engine displacement",
       y = "Highway Mileage",
       color = "Car Class") +
  theme_bw()

ggplotly(p)

# 모델링 그래프도 plotly에서 표현될 수 있습니다. 
data(CPS85, package = "mosaicData")

cps85_glm <- glm(married ~ sex + age + race + sector, 
                 family="binomial", 
                 data=CPS85)

p <- visreg(cps85_glm, "age",
       by = "sex",
       gg = TRUE, 
       scale="response") +
  labs(y = "Prob(Married)", 
       x = "Age",
       title = "Relationship of age and marital status",
       subtitle = "controlling for race and job sector",
       caption = "source: Current Population Survey 1985") + 
  theme_minimal()

ggplotly(p)

# ggplot2 패키지를 사용하지 않는다면, plotly의 문법을 새로 익혀야 하는데, 
# 처음 입문자들에게는 추천하지 않습니다. 
# 아래 예시
library(dplyr)
plot_ly(diamonds, x = ~cut) %>%
  add_histogram()

# 보시면 ggplot2와 형태는 유사하지만, 문법이 조금 상이함을 볼 수 있습니다. 
# 선택과 집중이라는 측면에서 봤을 때, ggplot2 패키지에 집중하시되, plotly에서는 가급적 ggplotly() 함수를 사용하는 것을 권유합니다. 

# ----- (1) 시계열 그래프 작성 -----
library(plotly)
data(economics, package = "ggplot2")

economics %>%
  arrange(psavert) %>%
  plot_ly(x = ~date, y = ~psavert) %>%
  add_lines()


# 그룹별 시계열 그래프
library(dplyr)
top5 <- txhousing %>%
  group_by(city) %>%
  summarise(m = mean(sales, na.rm = TRUE)) %>%
  arrange(desc(m)) %>%
  top_n(5)

tx5 <- semi_join(txhousing, top5, by = "city")

p <- ggplot(tx5, aes(x = date, y = median, colour = city)) + 
  geom_line() + 
  theme_minimal()

ggplotly(p)

# ----- (2) Error Bars -----
data <- ToothGrowth %>%
  group_by(supp, dose) %>% 
  dplyr::summarise(n = n(), 
                   mean = mean(len),
                   sd = sd(len),
                   se = sd/sqrt(n)) %>% 
  dplyr::mutate(dose = as.factor(dose)) %>% 
  ungroup()

glimpse(data)

# ggplot2 방식
p <- ggplot(data, aes(x = dose, y = mean, group = supp, colour = supp)) +
  geom_point(size = 2) +
  geom_line(size = 1) +
  geom_errorbar(aes(ymin = mean - se, 
                    ymax = mean + se), 
                width = .1) + 
  theme_minimal()

ggplotly(p)

# plotly 방식
plot_ly(data = data[which(data$supp == 'OJ'),], x = ~dose, y = ~mean, type = 'scatter', mode = 'lines+markers',
             name = 'OJ',
             error_y = ~list(array = sd,
                             color = '#000000')) %>%
  add_trace(data = data[which(data$supp == 'VC'),], name = 'VC')

# 어떤 것이 더 편한지는 각자 선택하시기를 바랍니다. 

# ---- (3) Financial Plot -----
library(plotly)

funnel_data <- data.frame(
  percent = c(39, 27.4, 20.6, 11, 2), 
  path = c("웹사이트 방문", "다운로드", "잠재고객", "장바구니", "실제구매"), 
  stringsAsFactors = FALSE
)

plot_ly() %>%
  add_trace(
    type = "funnel",
    y = funnel_data$path,
    x = funnel_data$percent) %>%
  layout(yaxis = list(categoryarray = funnel_data$path))

# 위 그래프의 경우에는 ggplot2으로 작성하기에는 매우 어려울 것입니다. 
# 실제로 그릴수는 있습니다만, 추천하지는 않습니다. 
# https://beta.rstudioconnect.com/content/5294/funnel_plot.nb.html

# 강사가 생각하는 시각화 잘 작성하는 요령은, 
# 한 패키지에 의존하기보다, 새로운 패키지들을 잘 찾아서 응용하는 것에 초점을 맞추자입니다. 
# 그러려면, 정보가 가장 중요하며, 어딘가에 늘 정리하는 습관이 중요합니다. 

#### 2. Leaflet ####
# Leaflet 패키지는 지도 시각화에 특화가 되어 있습니다. 
# Leaflet 패키지 역시, 오픈소스 JavaScript용으로 나왔고, R로 확장되었습니다. 
# 특히, 지도시각화에 최적화되었기 때문에, 공간시각화를 하시는 분이 있다면, 많이 활용해보는 것을 추천합니다. 
# Plotly와 마찬가지로 특유의 문법이 존재하기 때문에 초기 학습 곡선이 필요합니다. 
# 이 영역은 ggplot2와 패키지와 연관성이 크게 없습니다. 
# 다만, 차주에 배울 shiny앱에 적용시킬 수 있는 장점이 있기 때문에, 배워두면 응용이 가능합니다. 
# 미리 말씀드리면, shiny앱 시각화 부터는 일종의 플랫폼에 기반한 개발의 영역이 짙습니다. 
# 이 때에는 사내에 이 시스템을 도입할 것인가? 말 것인가?는 기존 시각화 솔루션과 냉정하게 비교 분석 하셔야 합니다. 

# 간단하게 그래프 그리기
library(leaflet)
leaflet() %>%
  addTiles() %>%
  addMarkers(lng=127.027696, 
             lat=37.498124, 
             popup="강남역입니다.")


# DataFrames
library(htmltools)

# 데이터셋을 코로나 기반으로 바꿀 것
df <- read.csv(textConnection(
  "Name,Lat,Long
Samurai Noodle,47.597131,-122.327298
Kukai Ramen,47.6154,-122.327157
Tsukushinbo,47.59987,-122.326726"))

leaflet(df) %>% addTiles() %>%
  addMarkers(~Long, ~Lat, label = ~htmlEscape(Name))

# 각 옵션에 대해 자세하게 알고 싶다면, https://rstudio.github.io/leaflet/popups.html
# 참고하세요. 

