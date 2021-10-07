# --------------------------------------------------------------------------------
# 로케일의 인코딩 방식에 따라 퍼센트 인코딩 방식을 달리 적용하는 함수 생성
# --------------------------------------------------------------------------------

# Mac 사용자를 위한 EUC-KR 변환 후 퍼센트 인코딩 해주는 함수
pcntEncoding2Euckr <- function(string) {
  
  # 필요한 패키지를 불러옵니다. 
  library(urltools)
  
  # 로케일의 인코딩 방식을 확인합니다. 
  if (localeToCharset() == 'UTF-8') {
    
    string <- iconv(x = string, from = 'UTF-8', to = 'EUC-KR')
    
  } else if (localeToCharset() %in% c('CP949', 'EUC-KR')) {
    
    string <- string
    
  }
  
  # 퍼센트 인코딩합니다. 더블 인코딩 회피를 위해 I()도 적용합니다. 
  pcntEncoded <- string %>% url_encode() %>% I() 
  
  # 결과를 반환합니다. 
  return(pcntEncoded)
}


# Windows 사용자를 위한 UTF-8 변환 후 퍼센트 인코딩 해주는 함수
pcntEncoding2Utf8 <- function(string) {
  
  # 필요한 패키지를 불러옵니다. 
  library(urltools)
  
  # 로케일의 인코딩 방식을 확인합니다. 
  if (localeToCharset() == 'UTF-8') {
    
    string <- string
    
  } else if (localeToCharset() %in% c('CP949', 'EUC-KR')) {
    
    string <- iconv(x = string, from = 'EUC-KR', to = 'UTF-8')
    
  }
  
  # 퍼센트 인코딩합니다. 더블 인코딩 회피를 위해 I()도 적용합니다. 
  pcntEncoded <- string %>% url_encode() %>% I() 
  
  # 결과를 반환합니다. 
  return(pcntEncoded)
}


# --------------------------------------------------------------------------------
# UTF-8 문자열을 UCS-2 문자열로 변환하는 사용자 정의 함수 생성
# --------------------------------------------------------------------------------

# UCS-2 인코딩은 고정된 2바이트 유니코드를 표현하는 방식
# 하지만 유니코드에 매핑되는 문자의 수가 증가함에 따라 고정 2바이트로 불가능
# 대안으로 UTF-16(가변 4바이트), UTF-32(고정 4바이트) 및 UTF-8(가변 인코딩) 등 추가
# UTF-16은 ASCII와 호환되지 않는 단점 때문에 UTF-8이 가장 널리 사용되고 있음 

# 필요한 패키지를 불러옵니다. 
library(stringr)

# UTF-8 문자열을 UCS-2 문자열로 변환하는 함수
UCS2encoder <- function(string) {
  
  # 한 글자씩 자릅니다. 
  string <- string %>% str_split(pattern = '') %>% `[[`(1)
  
  # 각 글자를 16진수(raw)로 변환합니다. 
  string <- string %>% 
    sapply(FUN = function(x) x %>% iconv(from = 'UTF-8', to = 'UCS-2', toRaw = TRUE) ) %>% 
    lapply(FUN = function(x) x %>% as.character() %>% str_c(collapse = '') ) %>% 
    unlist()
  
  # 10진수로 바꾼 뒤 앞뒤로 '&#'와 ';'을 추가한 다음 하나의 문자열로 합칩니다. 
  string <- string %>% 
    sapply(FUN = function(x) x %>% strtoi(base = 16L) %>% str_c('&#', ., ';') ) %>% 
    str_c(collapse = '')
  
  # 결과를 반환합니다. 
  return(string)
  
}


# UCS-2 문자열을 UTF-8 문자열로 변환하는 함수
UCS2decoder <- function(string) {
  
  # 글자수를 확인합니다. 
  numOfChar <- string %>% str_count(pattern = ';')
  
  # UCS-2 문자열 앞의 '&#'를 제거하고 ';'로 나눕니다. 
  string <- string %>% 
    str_remove_all(pattern = '&#') %>% 
    str_split(pattern = ';')
  
  # 리스트형 자료에서 첫 번째 원소만 선택하고 글자수만큼 자릅니다. 
  string <- string %>% `[[`(1) %>% `[`(1:numOfChar)
  
  # 마지막으로 10진수를 UTF-8으로 변환합니다. 
  string <- intToUtf8(x = string)
  
  # 결과를 반환합니다. 
  return(string)
  
}


## End of Document