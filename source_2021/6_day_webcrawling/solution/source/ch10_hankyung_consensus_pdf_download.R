# 필요한 패키지를 불러옵니다. 
library(httr)
library(urltools)
library(stringr)
library(rvest)

# pdf download
url = "http://consensus.hankyung.com/apps.analysis/analysis.list"

res <- GET(url = url, 
           query = list(sdate="2021-10-28", 
                        edate="2021-10-28", 
                        order_type="", 
                        now_page=1))

# 테이블
res %>% 
  read_html(encoding = "EUC-KR") %>%
  html_node(css = "div.table_style01") %>% 
  html_table() -> data01

# 첨부파일 링크
res %>% 
  read_html(encoding = "EUC-KR") %>% 
  html_nodes(css = "div.dv_input > a") %>% 
  html_attr("href") -> pdf_links

# pdf 타이틀
res %>% 
  read_html(encoding = "EUC-KR") %>% 
  html_nodes(css = "div.dv_input > a") %>% 
  html_attr("title") -> pdf_titles

# 데이터 추가
data01$첨부파일 = paste0("http://consensus.hankyung.com/", pdf_links)
data01$파일제목 = pdf_titles

# 다운로드
for (i in 1:nrow(data01)) {
  download.file(url = data01$첨부파일[i], 
                destfile = paste0("pdf/", data01$파일제목[i]), 
                mode = "wb") 
}

# list files
list.files("pdf/")
