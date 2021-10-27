## ---- 패키지 설치 ----

install.packages("extrafont")
install.packages("remotes")
remotes::install_version("Rttf2pt1", version = "1.3.8")
# References https://stackoverflow.com/questions/61204259/how-can-i-resolve-the-no-font-name-issue-when-importing-fonts-into-r-using-ext

library(extrafont)
library(remotes)
library(ggplot2)

## ---- 폰트 다운로드 ----
# https://www.kopus.org/biz-electronic-font2-2/
# https://hangeul.naver.com/font
# https://www.woowahan.com/#/fonts
font_import(paths = "~/Desktop/fonts")
loadfonts()
fonts()

library(ggplot2)
# font NanumMyeongjoBold, NanumPen, Consolas

ggplot(iris, aes(x = Species, y = Sepal.Width)) + 
  labs(title = "안녕하세요", 
       x = "X축") + 
  theme_gray() + 
  theme(axis.title.x = element_text(family = "NanumPen", size = 20))



# 출처: https://kkokkilkon.tistory.com/180 [꼬낄콘의 분석일지]

font_add_google("Gochi Hand", "gochi") 
font_add_google("Schoolbell", "bell")


