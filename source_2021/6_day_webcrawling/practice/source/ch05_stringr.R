# 필요한 패키지를 불러옵니다. 
library(stringr)
library(magrittr)

# 전처리할 문자열을 할당합니다. 
# 뉴스기사: https://economist.co.kr/2021/10/12/stock/stockNormal/20211012182440025.html

new_text = "이번 인수로 토스와 타다, 쏘카 등 3사의 몸값은 더욱 오를 것으로 보인다. 우선 토스의 주식 가격이 급등했다. 비상장주식 거래 플랫폼 서울거래소 비상장에 따르면, 토스의 타다 지분인수 소식이 전해진 지난 8일 비바리퍼블리카 주식은 전날(10만4900원)보다 2.57% 오른 10만7600원에 거래됐다."

# 글자 패턴 확인
new_text %>% str_detect(pattern = "거래")
# [1] TRUE

# 패턴 삭제 
new_text %>% str_remove(pattern = ' ')

# 특정 패턴 모두 삭제
new_text %>% str_remove_all(pattern = ' ')

# 패턴 바꾸기
new_text %>% str_replace(pattern = ',', replacement = '!!!')
new_text %>% str_replace_all(pattern = ' ', replacement = '!!!')

# 패턴 추출
new_text %>% str_extract(pattern = '주식')
new_text %>% str_extract_all(pattern = '주식')

# 인덱스 활용한 특정 문자열 추출
new_text %>% str_sub(start = 1L, end = 10L)

# 문자 분리
new_text %>% str_split(pattern = '토스')

# 공백 제거
new_text = '\t\t\t\t\t\t 이번 \r\t\t\t\t\t'
new_text %>% str_trim()
