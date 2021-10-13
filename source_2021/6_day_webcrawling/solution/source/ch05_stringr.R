# 필요한 패키지를 불러오기. 
library(stringr)
library(magrittr)

# 전처리할 문자열을 할당하기 
# 뉴스기사: https://economist.co.kr/2021/10/12/stock/stockNormal/20211012182440025.html
string <- '이번 인수로 토스와 타다, 쏘카 등 3사의 몸값은 더욱 오를 것으로 보인다. 우선 토스의 주식 가격이 급등했다. 비상장주식 거래 플랫폼 서울거래소 비상장에 따르면, 토스의 타다 지분인수 소식이 전해진 지난 8일 비바리퍼블리카 주식은 전날(10만4900원)보다 2.57% 오른 10만7600원에 거래됐다.'


# 패턴이 포함되어 있는지 확인하기.  
string %>% str_detect(pattern = '타다') 
string %>% str_detect(pattern = '삼성') 



# 처음 나오는 패턴을 한 번 삭제합니다. 띄어쓰기  
string %>% str_remove(pattern = ' ')


# 지정한 패턴이 여러 번 나오는 경우, 모두 삭제할 수 있습니다. 띄어쓰기
string %>% str_remove_all(pattern = ' ')


# 처음 나오는 패턴으로 한 번 교체 한다.  
string %>% str_replace(pattern = ' ', replacement = '_')


# 지정한 패턴이 여러 번 나오는 경우, 모두 교체할 수 있다. 
string %>% str_replace_all(pattern = ' ', replacement = '_')



# 처음 나오는 패턴으로 한 번 추출한다.  
string %>% str_extract(pattern = '주식')


# 지정한 패턴이 여러 번 나오는 경우, 모두 추출할 수 있습니다. 
string %>% str_extract_all(pattern = '주식')


# 문자열의 인덱스를 이용하여 필요한 부분만 자를 수 있습니다. 
string %>% str_sub(start = 1, end = 2)


# 두 개 이상의 문자열을 하나로 묶습니다. 
str_c('토스', '타다') 
str_c('토스', '타다',  sep = ' ') 



# 하나의 문자열을 구분자 기준으로 여러 개의 문자열로 분리할 수 있습니다. 
string %>% str_split(pattern = ' ') 


# 문자열의 양 옆에 있는 공백을 제거합니다. 
string <- '\r\n\t\t\t\t\t\t  이번  \r\n\t\t\t\t\t\t'
string %>% str_trim()

# 
