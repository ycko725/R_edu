# 패키지
library(tabulizer)
library(pdftools)
library(magrittr)
library(stringr)
library(dplyr)
library(tidytext)
library(KoNLP)
library(wordcloud)
library(ggplot2)

file_lists = list.files("pdf/")
file_names = gsub(".pdf$", "", file_lists)

# text 추출
raw_txt = extract_text(file = paste0("pdf/", file_lists[1]), pages = 1)
article_df = data.frame(
  file_names = file_names[1], 
  raw_text = raw_txt
)
  
# 데이터 프레임
articles = article_df %>% 
  mutate(clean_text = str_replace_all(raw_text, "[^가-힣]", " "), 
         clean_text = str_squish(clean_text))

# 단어 분리
noun <- extractNoun(articles$clean_text)
noun <- Filter(function(x) {nchar(x)>=2}, noun)
wordcount <- table(noun)
sort(wordcount, decreasing = T)

palete <- brewer.pal(9,"Set3")
wordcloud(names(wordcount),
          freq=wordcount,
          scale=c(5,1),
          rot.per=0.25,
          min.freq=1, 
          random.order=F,
          random.color=T,
          family = "AppleGothic", 
          colors=palete)



# 테이블 추출
df = extract_areas(file = paste0("pdf/", file_lists[1]), pages = 1)
df %>% as.data.frame() -> data
names(data) <- as.character(unlist(data[1, ]))
data = data[-1, ]


