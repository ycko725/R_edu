# --------------------------------------------------------------------------------
# 한글 인코딩 관련 R 함수들
# --------------------------------------------------------------------------------

# 현재 컴퓨터에 설정된 로케일에 따른 한글 인코딩 방식을 확인합니다. 
localeToCharset()
## Mac : [1] "UTF-8"
## Windows : [1] "CP949"


# --------------------------------------------------------------------------------

# 문자열의 인코딩 방식을 확인 및 설정합니다. 
# 새로운 문자열을 하나 생성합니다. 
text <- '안녕하세요?'
print(x = text)
## Mac : [1] "안녕하세요?"
## Windows : [1] "안녕하세요?"

# 문자열의 인코딩 방식을 확인합니다. 
Encoding(x = text)
## Mac : [1] "UTF-8"
## Windows : [1] "unknown"


# --------------------------------------------------------------------------------

# 한글 인코딩 방식을 latin1으로 설정합니다. 
Encoding(x = text) <- 'latin1'
Encoding(x = text)
## Mac : [1] "latin1"
## Windows : [1] "latin1"

# text 객체를 출력합니다.
print(x = text)
## Mac : [1] "ì•ˆë…•í•˜ì„¸ìš”?"
## Windows : [1] "¾È³çÇÏ¼¼¿ä?"


# --------------------------------------------------------------------------------

# 한글 인코딩 방식을 bytes로 설정합니다. (16진수)
Encoding(x = text) <- 'bytes'
Encoding(x = text)
## Mac : [1] "bytes"
## Windows : [1] "bytes"

# text 객체를 출력합니다.
print(x = text)
## Mac : [1] "\\xec\\x95\\x88\\xeb\\x85\\x95\\xed\\x95\\x98\\xec\\x84\\xb8\\xec\\x9a\\x94?"
## Windows : [1]Error in print.default(x = text) : 
## translating strings with "bytes" encoding is not allowed


# [번외] 16진수(bytes) 인코딩 문자를 해독해보겠습니다. 

# Windosw 사용자는 아래 문자열을 string에 저장합니다. 
string <- '\\xbe\\xc8\\xb3\\xe7\\xc7\\xcf\\xbc\\xbc\\xbf\\xe4?'

# Mac 사용자는 아래 문자열을 string에 저장합니다. 
string <- '\\xec\\x95\\x88\\xeb\\x85\\x95\\xed\\x95\\x98\\xec\\x84\\xb8\\xec\\x9a\\x94?'


# 아래 라인부터는 OS에 상관없이 실행됩니다. 
# string 객체를 출력하고 속성을 확인합니다. 
print(x = string)
class(x = string)

# 여러 기호와 x를 삭제합니다. 
string <- string %>% str_remove_all(pattern = '[:punct:]|x')
print(x = string)

# 2글자씩 자릅니다. 
n <- nchar(x = string)
r <- seq(from = 1, to = n, by = 2)
string <- string %>% str_sub(start = r, end = r + 1)
print(x = string)

# 16진수 숫자로 변환하고 raw 객체 속성 변경 후 다시 글자로 변환합니다. 
string %>% strtoi(base = 16L) %>% as.raw() %>% rawToChar()


# --------------------------------------------------------------------------------

# 한글 인코딩 방식을 UTF-8으로 설정합니다. 
Encoding(x = text) <- 'UTF-8'
Encoding(x = text)
## Mac : [1] "UTF-8"
## Windows : [1] "UTF-8"

# text 객체를 출력합니다.
print(x = text)
## Mac : [1] "안녕하세요?"
## Windows : [1] "�ȳ\xe7\xc7\u03fc��\xe4?"  


# [Windiws only] CP949 / EUC-KR로 설정합니다. 
Encoding(x = text) <- 'CP949'
Encoding(x = text)
## Mac : [1] "unknown"
## Windows : [1] "unknown"

# text 객체를 출력합니다.
print(x = text)
## Mac : [1] "안녕하세요?"
## Windows : [1] "안녕하세요?"


# --------------------------------------------------------------------------------

# 문자열의 인코딩 방식을 변경하려면 iconv() 함수를 사용합니다. 
# 매우 유용한 함수이니 반드시 기억하시기 바랍니다. 

# 아래는 Windows 사용자만 실행해보세요! 

# CP949를 EUC-KR로 변경합니다. 
iconv(x = text, from = 'CP949', to = 'EUC-KR')
## Mac : NA
## Windows : [1] "안녕하세요?"

# CP949를 UTF-8로 변경합니다. 
iconv(x = text, from = 'CP949', to = 'UTF-8')
## Mac : NA
## Windows : [1] "안녕하세요?"

# CP949를 ASCII로 변경합니다. 
iconv(x = text, from = 'CP949', to = 'ASCII')
## Mac : NA
## Windows : [1] NA
## 해당하는 코드가 없으므로 NA가 반환되었습니다. 


# 아래는 Mac 사용자만 실행해보세요! 

# UTF-8을 EUC-KR로 변경합니다. 
iconv(x = text, from = 'UTF-8', to = 'EUC-KR')
## Mac : [1] "\xbeȳ\xe7\xc7\u03fc\xbc\xbf\xe4?"
## Windows : NA

# UTF-8을 CP949로 변경합니다. 
iconv(x = text, from = 'UTF-8', to = 'CP949')
## Mac : [1] "\xbeȳ\xe7\xc7\u03fc\xbc\xbf\xe4?"
## Windows : NA

# UTF-8을 ASCII로 변경합니다. 
iconv(x = text, from = 'UTF-8', to = 'ASCII')
## Mac : [1] NA
## 해당하는 코드가 없으므로 NA가 반환되었습니다. 
## Windows : NA


# --------------------------------------------------------------------------------

# 컴퓨터에 저장된 파일 또는 URL의 문자 인코딩 방식을 확인합니다.

# readr 패키지를 불러옵니다. 
detach(package:rvest)
library(readr)

# 관심 있는 URL에 사용된 문자 인코딩 방식을 확인합니다. 
guess_encoding(file = 'https://www.naver.com/')
##   encoding     confidence
##   <chr>             <dbl>
## 1 UTF-8              1   
## 2 windows-1252       0.31

guess_encoding(file = 'https://www.daum.net/')
##   encoding     confidence
##   <chr>             <dbl>
## 1 UTF-8              1   
## 2 windows-1252       0.35

guess_encoding(file = 'http://www.isuperpage.co.kr/')
##   encoding   confidence
##   <chr>           <dbl>
## 1 EUC-KR          1    
## 2 GB18030         0.7  
## 3 ISO-8859-1      0.32 
## 4 Big5            0.290

## 출력된 결과 중 confidence가 가장 높은 것을 선택합니다. 

# --------------------------------------------------------------------------------
# 로케일 관련 함수들
# --------------------------------------------------------------------------------

# Windows 사용자만 해보세요! 

# 현재 설정된 로케일을 확인합니다. 
Sys.getlocale()
## [1] "LC_COLLATE=Koren_Korea.949;
## LC_CTYPE=Koren_Korea.949;
## LC_MONETARY=Koren_Korea.949;
## LC_NUMERIC=Koren_Korea.949;
## LC_TIME=Koren_Korea.949;"

# 현재 설정된 로케일에 따른 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "CP949


# 미국 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'english')
## [1] "LC_COLLATE=English_United States.1252;
## LC_CTYPE=English_UnitedS tates.1252;
## LC_MONETARY=English_United States.1252;
## LC_NUMERIC=C;
## LC_TIME=English_United States.1252"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "ISO8859-1"


# 중국 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'chinese')
## [1] "LC_COLLATE=Chinese (Simplified)_China.936;
## LC_CTYPE=Chinese (Simplified)_China.936;
## LC_MONETARY=Chinese (Simplified)_China.936;
## LC_NUMERIC=C;
## LC_TIME=Chinese (Simplified)_China.936"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "CP936"


# 일본 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'japanese')
## [1] "LC_COLLATE=Japanese_Japan.932;
## LC_CTYPE=Japanese_Japan.932;
## LC_MONETARY=Japanese_Japan.932;
## LC_NUMERIC=C;
## LC_TIME=Japanese_Japan.932"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "CP932"


# Unix Default 로케일로 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'C')
## [1] "C"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "ASCII"


# 우리나라 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'korean')
## [1] "LC_COLLATE=Korean_Korea.949;
## LC_CTYPE=Korean_Korea.949;
## LC_MONETARY=Korean_Korea.949;
## LC_NUMERIC=C;
## LC_TIME=Korean_Korea.949"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "CP949"


# --------------------------------------------------------------------------------

# Mac 사용자만 해보세요! 

# 현재 설정된 로케일을 확인합니다. 
Sys.getlocale()
## [1] "ko_KR.UTF-8/ko_KR.UTF-8/ko_KR.UTF-8/C/ko_KR.UTF-8/en_US.UTF-8"

# 현재 설정된 로케일에 따른 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "UTF-8"


# 미국 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'en_US.UTF-8')
## [1] "en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "UTF-8"


# 중국 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'zh_CN.UTF-8')
## [1] "zh_CN.UTF-8/zh_CN.UTF-8/zh_CN.UTF-8/C/zh_CN.UTF-8/en_US.UTF-8"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "UTF-8"


# 일본 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'ja_JP.UTF-8')
## [1] "ja_JP.UTF-8/ja_JP.UTF-8/ja_JP.UTF-8/C/ja_JP.UTF-8/en_US.UTF-8"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "UTF-8"


# Unix Default 로케일로 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'C')
## [1] "C/C/C/C/C/en_US.UTF-8"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "ASCII"


# 우리나라 UTF-8으로 로케일을 변경합니다. 
Sys.setlocale(category = 'LC_ALL', locale = 'ko_KR.UTF-8')
## [1] "ko_KR.UTF-8/ko_KR.UTF-8/ko_KR.UTF-8/C/ko_KR.UTF-8/en_US.UTF-8"

# 문자 인코딩 방식을 확인합니다. 
localeToCharset()
## [1] "UTF-8"
