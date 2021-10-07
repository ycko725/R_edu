library(rvest)

## classes
html = read_html("data/css2.html", encoding = "utf-8")
html %>% 
  html_nodes('a.link')

html = read_html("data/css3.html", encoding = "utf-8")
html %>% 
  html_nodes(".link.italic_font")

## ids
html = read_html("data/css3.html", encoding = "utf-8")
html %>% 
  html_nodes("#div_tag")


html %>% 
  html_nodes("div#div_tag")


## ol li
html = read_html("data/css4.html", encoding = "utf-8")
html %>% 
  html_nodes("li:first-child")

html %>% 
  html_nodes("li:nth-child(2)")

html %>% 
  html_nodes("li:nth-child(3)") %>% 
  html_text()




