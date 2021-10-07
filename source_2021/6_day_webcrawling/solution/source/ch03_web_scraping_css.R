library(rvest)

## classes
html_df <- read_html("data/css2.html", encoding = "utf-8")
html_df %>% 
  html_nodes(".link")

html_df <- read_html("data/css3.html", encoding = "utf-8")
html_df %>% 
  html_nodes(".link")

html_df %>% 
  html_nodes(".link.italic_font")

## ids
html_df <- read_html("data/css3.html", encoding = "utf-8")
html_df %>% 
  html_nodes("#div_tag")

html_df %>% 
  html_nodes("div#div_tag")

## ol li
html_df <- read_html("data/css4.html", encoding = "utf-8")
html_df %>% 
  html_nodes("li:first-child") %>% 
  html_text()

html_df %>% 
  html_nodes("li:nth-child(2)") %>% 
  html_text()

html_df %>% 
  html_nodes("li:nth-child(3)") %>% 
  html_text()

