library(rvest)
library(xml2)

## html 파일 불러오기
html_df <- read_html("data/intro.html", encoding = "utf-8")
html_df

## xml_structure로 확인하기
xml_structure(html_df)

## 내부 구조 확인
html_df <- read_html("data/intro2.html", encoding = "utf-8")
html_df %>% 
  html_children() %>% 
  html_text()

## html_node 함수 사용
html_df %>% 
  html_node('body')

## html_nodes 함수 사용 
html_df %>% 
  html_nodes('div p')

## Attribute 추출하기
html_df %>% 
  html_node('a') %>% 
  html_attr('href')

html_df %>% 
  html_nodes('a') %>% 
  html_attrs()

## table 태그 확인하기
html_df <- read_html("data/intro3.html", encoding = "utf-8")
html_df %>% 
  html_table()
