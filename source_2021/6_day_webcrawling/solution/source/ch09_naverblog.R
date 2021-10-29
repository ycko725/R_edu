# --------------------------------------------------------------------------------
# 네이버 블로그 중 검색어를 일자별로 수집하기 
# --------------------------------------------------------------------------------

# 네이버 메인에서 '검색어'를 입력하고 블로그가 등록된 일자로 검색합니다. 
# 크롬 개발자도구 네트워크 탭의 XHR에서 관련 파일을 찾습니다. 
# General 항목에서 찾은 Request URL을 분해하면 아래와 같습니다. 

# 'https://section.blog.naver.com/ajax/SearchList.nhn'
# '?countPerPage=7' <- 고정
# '&currentPage=1'
# '&startDate=yyyy-mm-dd'
# '&endDate=yyyy-mm-dd'
# '&keyword=%EA%B0%95%EB%82%A8%EC%97%AD%EB%A7%9B%EC%A7%91'
# '&orderBy=sim'    <- 필요 없음 
# '&type=post'      <- 필요 없음 


# 다음과 같은 순서로 작업합니다. 

# 1. 검색어 인코딩 방식을 UTF-8으로 변환하고, 다시 퍼센트 인코딩하는 함수를 불러옵니다. 

# 2. 검색어와 조회일자를 입력하면 조건에 맞는 블로그 수를 반환하는 함수를 만듭니다. 

# 3. 검색어와 조회일자 및 페이지번호를 입력하면 조건에 맞는 블로그 데이터를 수집하여 
# 데이터프레임으로 반환하는 함수를 만듭니다.

# 4. 검색어와 조회일자를 입력하면 조건에 맞는 전체 블로그 수를 추출하고 전체 페이지 수를 
# 계산한 다음, 반복문을 실행하여 전체 블로그 데이터를 수집하는 함수를 만듭니다. 

# 5. 검색어와 조회구간을 설정하면 조회구간으로부터 날짜 벡터를 생성한 다음, 
# 4번 함수로 반복문을 실행하여 조회구간 전체 블로그 데이터를 한꺼번에 수집합니다! 


# --------------------------------------------------------------------------------

# 필요한 패키지를 불러옵니다. 
library(lubridate)
library(httr)
library(urltools)
library(rvest)
library(tidyverse)
library(jsonlite)


# 테스트를 위해 오늘 날짜를 지정합니다. 
today <- Sys.Date() %>% as.character()

# 퍼센트 인코딩 함수가 담긴 R 파일을 불러옵니다. 
source(file = './code/encodings.R')


# --------------------------------------------------------------------------------

# 검색어와 조회시작일자, 조회종료일자를 입력하면 조건에 맞는 블로그의 수를 반환하는 
# 사용자 정의 함수를 만듭니다.
getBlogCnt <- function(searchWord, bgnDate, endDate) { 
  
  # HTTP 요청합니다.
  res <- GET(url = 'https://section.blog.naver.com/ajax/SearchList.nhn', 
             query = list(countPerPage = '7', 
                          currentPage = '1',
                          startDate = bgnDate, 
                          endDate = endDate, 
                          keyword = searchWord %>% pcntEncoding2Utf8() ), 
             add_headers(referer = 'https://section.blog.naver.com/BlogHome.nhn') )
  
  # 응답 결과를 확인합니다. 
  # print(x = res)
  
  # 응답 바디에 있는 ")]}',"을 제거하고 fromJSON() 함수에 할당합니다. 
  json <- res %>% 
    as.character() %>% 
    str_remove(pattern = "\\)\\]\\}\\',") %>% 
    fromJSON()
  
  # 블로그 수를 추출한 다음 숫자 벡터로 변환합니다. 
  totalCount <- json$result$totalCount %>% as.numeric()
  
  # 결과를 반환합니다. 
  return(totalCount)
  
}

# 오늘 날짜로 테스트합니다. 
getBlogCnt(searchWord = '암호화폐', 
           bgnDate = today, 
           endDate = today)


# --------------------------------------------------------------------------------

# 검색어와 조회시작일자, 조회종료일자, 페이지수를 입력하면 조건에 맞는 블로그 
# 데이터를 수집하여 데이터프레임으로 반환하는 사용자 정의 함수를 만듭니다. 
getBlogDf <- function(searchWord, bgnDate, endDate, page = 1) {
  
  # HTTP 요청합니다.
  res <- GET(url = 'https://section.blog.naver.com/ajax/SearchList.nhn', 
             query = list(countPerPage = '7', 
                          currentPage = page,
                          startDate = bgnDate, 
                          endDate = endDate, 
                          keyword = searchWord %>% pcntEncoding2Utf8() ), 
             add_headers(referer = 'https://section.blog.naver.com/BlogHome.nhn') )
  
  # 응답 결과를 확인합니다. 
  # print(x = res)
  
  # 응답 바디에 있는 ")]}',"을 제거하고 fromJSON() 함수에 할당합니다. 
  json <- res %>% 
    as.character() %>% 
    str_remove(pattern = "\\)\\]\\}\\',") %>% 
    fromJSON()
  
  # 데이터프레임을 출력합니다.
  df <- json$result$searchList
  
  # 필요한 컬럼만 남깁니다. 
  df <- df[, c('blogId', 'postUrl', 'noTagTitle', 'contents', 'nickName', 'blogName', 'addDate')]
  
  # 간단한 전처리를 실시합니다. 
  # contents 컬럼에 있는 태그와 불필요한 기호(&quot;)를 제거합니다. 
  df$contents <- df$contents %>% str_remove_all(pattern = '<.+?>|&quot;')
  
  # addDate 컬럼에 날짜 대신 숫자 벡터로 들어 있으므로 1000으로 나눈 후, 
  # POSIXct로 속성을 바꿔줍니다. 
  df$addDate <- as.POSIXct(x = df$addDate / 1000, origin = '1970-01-01')
  
  # 결과를 반환합니다. 
  return(df)
}

# 오늘 날짜로 테스트합니다. 
df <- getBlogDf(searchWord = '암호화폐', 
                bgnDate = today, 
                endDate = today, 
                page = 1)

# 결과를 출력합니다. 
print(x = df)



# --------------------------------------------------------------------------------

# 검색어와 조회시작일자, 조회종료일자를 지정하면 해당 조건의 모든 블로그 데이터를 
# 수집하는 반복문이 포함된 사용자 정의 함수를 만듭니다.
getAllBlogDf <- function(searchWord, bgnDate, endDate) {
  
  # 조건에 맞는 블로그 수를 가져옵니다. 
  blogCnt <- getBlogCnt(searchWord = searchWord, bgnDate = bgnDate, endDate = endDate)
  
  # 페이지 수를 계산합니다. 
  pages <- ceiling(x = blogCnt / 7)
  
  # 블로그 수와 페이지 수를 출력합니다. 
  cat('> 블로그 수는', blogCnt, '& 페이지 수는', pages, '입니다.\n')
  
  # 만약 블로그의 수가 0이면 아래 라인을 실행하지 않습니다. 
  if (blogCnt >= 1) {
    
    # 최종 결과 객체를 빈 데이터프레임으로 생성합니다. 
    result <- data.frame()
    
    # 반복문을 실행합니다. 
    for (page in 1:pages) {
      
      # 현재 진행상황을 출력합니다. 
      cat('>> 현재', page, '페이지 실행 중입니다.\n')
      
      # 해당 페이지의 블로그 데이터를 수집한 다음 df에 할당합니다. 
      df <- getBlogDf(searchWord = searchWord, 
                      bgnDate = bgnDate, 
                      endDate = endDate, 
                      page = page)
      
      # 최종 결과 객체에 추가합니다. 
      result <- rbind(result, df)
      
      # 1초간 멈춥니다. 
      Sys.sleep(time = 1)
      
    }
    
    # 최종 결과를 반환합니다. 
    return(result)
    
  } 
}

# 오늘 날짜로 테스트합니다. 
blogData <- getAllBlogDf(searchWord = '암호화폐', 
                         bgnDate = today, 
                         endDate = today)

# 결과를 출력합니다. 
print(x = blogData)


# --------------------------------------------------------------------------------

# 마지막으로 검색어를 설정하고, 조회기간에 해당하는 일별 날짜 벡터를 생성한 다음 
# 날짜를 바꿔가며 조건에 해당하는 모든 블로그를 한 번에 수집하는 반복문을 실행합니다. 

# 검색어를 설정합니다. 
keyword <- '암호화폐'

# 조회시작일과 조회종료일로부터 벡터를 생성합니다. 
dates <- seq(from = ymd('2021-01-01'), to = ymd('2021-10-03'), by = '1 day')

# dates 객체를 출력합니다. 
print(x = dates)


# 최종 결과 객체를 빈 데이터프레임으로 생성합니다. 
result <- data.frame()

# 반복문을 실행합니다. 
for (date in dates) {
  
  # 반복문 안에서 date가 날짜 벡터에서 숫자 벡터로 자동 변환되는 
  # 문제가 발생하므로 다시 날짜 벡터로 강제 변환합니다. 
  date <- date %>% as.Date(origin = '1970-01-01')
  
  # 현재 진행상황을 출력합니다. 
  date4print <- format(x = date, format = '%Y년 %m월 %d일에')
  cat('현재', date4print, '등록된 블로그를 수집하고 있습니다.\n')
  
  # 해당 일자에 등록된 모든 블로그를 수집합니다. 
  blogData <- getAllBlogDf(searchWord = keyword,
                           bgnDate = date,
                           endDate = date)
  
  # 최종 결과 객체에 추가합니다. 
  result <- rbind(result, blogData)
  
  # 개행을 추가합니다. 
  cat('\n')
  
  # 1초간 멈춥니다. 
  Sys.sleep(time = 1)
  
}

# 최종 결과 객체의 구조를 파악합니다. 
str(object = result)