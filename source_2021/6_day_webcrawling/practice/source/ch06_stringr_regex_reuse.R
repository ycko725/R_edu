# 필요한 패키지를 불러옵니다. 
library(stringr)

# 기본 매칭 
x = c("apple", "banana", "pear", "berry")
str_view(x, "an")

str_view(x, ".a.")

# 정규표현식(regular expression)
# 특수 문자 "."은 어떻게 매칭 시킬 수 있을까?
dot = "\\."
writeLines(dot)

x = c("abc", "a.c", "be.f")
str_view(x, "a\\.c")

# 특수 문자 "\"은 어떻게 매칭 시킬 수 있을까?
slash = "a\\b"
writeLines(slash)

x = c("ab\\c", "a.c", "be.f")
str_view(x, "\\\\")

# ^와 $
x = c("apple", "banana", "pear", "berry")
str_view(x, "^a")
str_view(x, "a$")

x = c("감자", "씨감자", "감자탕")
str_view(x, "감자")
str_view(x, "^감자")
str_view(x, "감자$")
str_view(x, "^감자$")

# 문자열을 지정합니다. 
text = "가나abXY12345 \r\n\t,._/?\\-"

nchar(x = text)
# [1] 21

# \\w 영어 대소문자, 한글 등
text %>% str_extract_all(pattern = "\\w")

# \\d 숫자만 출력한다. 
text %>% str_extract_all(pattern = "\\d")

# \\s 공백과 개행(\r\n) 및 탭(\t)을 지정한다. any whitespace
text %>% str_extract_all(pattern = "\\s")

#--- 

# \\W 특수문자 + whitespace
text %>% str_extract_all(pattern = "\\W")

# \\D 한글 + 영어 대소문자 + 특수문자 + whitespace
text %>% str_extract_all(pattern = "\\D")

# \\S 한글 + 영어 대소문자 + 숫자 + 특수문자
text %>% str_extract_all(pattern = "\\S")

# 한글 추출
# \\p{Hangul}
text %>% str_extract_all(pattern = "\\p{Hangul}")
text %>% str_extract_all(pattern = "[ㄱ-ㅣ]")

# '.' \r\n을 제외한 모든 문자
text %>% str_extract_all(pattern = ".")

# 태그 한꺼번에 추출하기
# 수량자
tag_text = "<p>이것은<span>html 태그</span>입니다.</p>"

tag_text %>% str_remove_all(pattern = "<.+?>")
