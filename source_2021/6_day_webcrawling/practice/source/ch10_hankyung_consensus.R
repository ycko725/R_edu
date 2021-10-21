# 필요한 패키지를 불러옵니다. 

library(httr)
library(urltools)
library(stringr)
library(rvest)

# pdf download
url = "http://consensus.hankyung.com/apps.analysis/analysis.list"

res <- GET(url = url)

res %>% 
  read_html(encoding = "EUC-KR") %>%
  html_node(css = "div.table_style01") %>% 
  html_table() -> data01

res %>% 
  read_html(encoding = "EUC-KR") %>% 
  html_nodes(css = "div.dv_input > a") %>% 
  html_attr("href") -> pdf_links

res %>% 
  read_html(encoding = "EUC-KR") %>% 
  html_nodes(css = "div.dv_input > a") %>% 
  html_attr("title") -> pdf_titles


data01$첨부파일 = paste0("http://consensus.hankyung.com/", pdf_links)
data01$파일제목 = pdf_titles


url = "http://consensus.hankyung.com/apps.analysis/analysis.downpdf?report_idx=599422"
download.file(url = data01$첨부파일[2], 
              destfile = paste0("pdf/", data01$파일제목[2]), 
              mode = "wb")

pdfpath <- "https://www.census.gov/content/dam/Census/library/publications/2011/dec/c2010br-08.pdf"


library(pdftools)
library(tidyverse)
library(tabulizer)

txt <- pdftools::pdf_text("pdf/IBK20211021팬엔터테인먼트.pdf")
data = extract_tables("pdf/IBK20211021팬엔터테인먼트.pdf", pages = 2, output = "data.frame")
data[[1]] %>% as.data.frame()

extract_areas("pdf/IBK20211021팬엔터테인먼트.pdf")
