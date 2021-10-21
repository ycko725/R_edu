# 패키지
library(tabulizer)
library(pdftools)
library(magrittr)
library(stringr)

file_lists = list.files("pdf/")

# text 추출
txt = extract_text(file = paste0("pdf/", file_lists[1]), pages = 1)
gsub("[\r\n]", '', txt)

# 테이블 추출
df = extract_areas(file = paste0("pdf/", file_lists[1]), pages = 1)
df %>% as.data.frame() -> data
names(data) <- as.character(unlist(data[1, ]))
data = data[-1, ]


