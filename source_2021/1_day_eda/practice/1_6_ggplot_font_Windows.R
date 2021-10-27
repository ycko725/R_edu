## ---- 패키지 설치 ----

install.packages("extrafont")
install.packages("remotes")
writeLines('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"', con = "~/.Renviron")
Sys.which("make")
remotes::install_version("Rttf2pt1", version = "1.3.8")
# References https://stackoverflow.com/questions/61204259/how-can-i-resolve-the-no-font-name-issue-when-importing-fonts-into-r-using-ext

library(extrafont)
library(ggplot2)


## ---- 폰트 다운로드 ----
# https://www.kopus.org/biz-electronic-font2-2/
# https://hangeul.naver.com/font
# https://www.woowahan.com/#/fonts

font_import(paths = "C:/Users/b/Desktop/fonts")
loadfonts()
fonts()

# font NanumMyeongjoBold, NanumPen, Consolas


ggplot(iris, aes(x = Species, y = Sepal.Width)) + 
  geom_point() + 
  labs(title = "안녕하세요", 
       x = "X축") + 
  theme_gray(base_family = "NanumSquare Bold") +
  theme(
        axis.title.y = element_text(family = "NanumSquare", size = 14),
        axis.title.x = element_text(family = "NanumBarunpen", size = 14), 
        plot.title = element_text(family = "BM Euljiro 10 years later", size = 20))

library(showtext)
font_add_google("Schoolbell", "bell")

showtext_auto()


