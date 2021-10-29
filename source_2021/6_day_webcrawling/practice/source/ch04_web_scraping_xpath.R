library(rvest)

html = read_html(x = "data/xpath.html", encoding = "utf-8")

# p태그만 추출 한다. 
html %>% 
  html_nodes(css = "p")

html %>% 
  html_nodes(xpath = "//p")

# p태그에서 class가 second 인 것만 추출한다. 

html %>% 
  html_nodes(css = "div p.second")

html %>% 
  html_nodes(xpath = "//p[@class = 'second']")

# div태그에서 id가 third이면서, p태그를 추출 한다. 
html %>% 
  html_nodes(css = "div#third > p.second")

html %>% 
  html_nodes(xpath = "//div[@id = 'third']/p[@class = 'second']")

## position
html = read_html(x = "data/xpath2.html", encoding = "utf-8")
html %>% 
  html_nodes(xpath = '//div/p[position() = 3]')

html %>% 
  html_nodes(xpath = '//div/p[position() != 2]')

html %>% 
  html_nodes(xpath = '//div[position() = 2]/*[position() !=2]')

## text
html = read_html(x = "data/xpath2.html", encoding = "utf-8")

html %>% 
  html_node(xpath = "//table") %>% 
  html_table()

## 배우만 추출
html %>% 
  html_nodes(xpath = '//table//td[@class = "actor_name"]') %>% 
  html_text() -> actors

## 극중 역할만 추출
html %>% 
  html_nodes(xpath = '//table//td[@class = "movie_role"]/em') %>% 
  html_text() -> roles


## ( ) 내용 추출
html %>% 
  html_nodes(xpath = '//table//td[@class = "movie_role"]/text()') %>% 
  html_text(trim = TRUE) -> etcs

data.frame(actor = actors, 
           role = roles, 
           etc = etcs) -> df

