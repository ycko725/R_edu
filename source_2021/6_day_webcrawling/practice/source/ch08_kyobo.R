# GET 방식으로 교보문고에서 검색 결과 수집하기

library(httr)
library(urltools)
library(stringr)
library(rvest)

url <- "https://search.kyobobook.co.kr/web/search"
keyword <- "인공지능"

# https://search.kyobobook.co.kr/web/search?vPstrKeyWord=%25EB%258D%25B0%25EC%259D%25B4%25ED%2584%25B0%25EA%25B3%25BC%25ED%2595%2599&vPstrTab=PRODUCT&searchPcondition=1&currentPage=5&orderClick=LAG#container

res <- GET(url = url, 
           query = list(vPstrKeyWord = keyword, 
                        vPstrTab = "PRODUCT", 
                        searchPcondition = 1, 
                        currentPage = 10))

# ---- 전체 페이지 갯수 ----
#searchCategory_0 > small

#searchCategory_0 > small
res %>% 
  read_html() %>% 
  html_node(css = "a#searchCategory_0 > small") %>% 
  html_text() %>% 
  str_remove(pattern = ",") %>% # 숫자에 쉼표가 있을 때 사용
  str_trim(side = "both") %>% 
  as.integer() -> total_books

total_pages = ceiling(total_books / 20)

# ---- 전체 테이블 ----
#contents_section > div.list_search_result > form:nth-child(1) > table
res %>% 
  read_html() %>% 
  html_node(css = "table.type_list") %>% 
  html_table()



# ---- 전체 책 가져오기 ----
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

head(df, 21) %>% tail()
tail(df)
