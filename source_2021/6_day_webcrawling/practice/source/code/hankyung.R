# 필요한 패키지 불러오기
library(httr)
library(urltools)
library(stringr)
library(rvest)

# url 
url <- "http://consensus.hankyung.com/apps.analysis/analysis.list"


res <- GET(url = url, 
           query = list(sdate="2021-12-01", 
                        edate="2021-12-20", 
                        order_type = "", 
                        now_page = 1))

# 첨부파일 링크
#contents > div.table_style01 > table > tbody > tr:nth-child(1) > td:nth-child(6) > div
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

data01 <- data.frame(첨부파일 = paste0("http://consensus.hankyung.com", pdf_links), 
                     파일제목 = pdf_titles)

data01

# 다운로드
for (i in 1:nrow(data01)) {
  download.file(url = data01$첨부파일[i], 
                destfile = paste0("pdf/", data01$파일제목[i]), mode = "wb")
}

# list
length(list.files("pdf/"))








