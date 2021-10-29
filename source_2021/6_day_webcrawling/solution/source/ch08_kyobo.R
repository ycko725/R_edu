# GET 방식으로 교보문고에서 검색 결과 수집하기 

# 필요한 패키지를 불러옵니다. 
library(httr)
library(urltools)
library(stringr)
library(rvest)

url <- "https://search.kyobobook.co.kr/web/search"
keyword = "데이터과학"

res <- GET(url = url, 
           query = list(vPstrKeyWord = keyword, 
                        vPstrTab = "PRODUCT", 
                        searchPcondition = 1, 
                        currentPage = 1))

res %>% 
  read_html() %>% 
  html_node(css = "a#searchCategory_0") %>% 
  html_text() %>% 
  str_sub(start = 5, end = -1) %>% as.integer() -> total_pages

total_pages = ceiling(total_pages / 20)

df = data.frame()
for (i in 1:total_pages) {
  res <- GET(url = url, 
             query = list(vPstrKeyWord = keyword, 
                          vPstrTab = "PRODUCT", 
                          searchPcondition = 1, 
                          currentPage = i))
  kyobo_df = res %>% 
    read_html() %>% 
    html_node(css = "table.type_list") %>% 
    html_table()
    
  df = rbind(df, kyobo_df)
  
}


