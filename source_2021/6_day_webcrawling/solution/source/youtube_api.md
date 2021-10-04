---
title: "tuber 패키지와 유투브 API를 활용한 Youtube 댓글 수집"
date: 2021-09-30T10:00:00+09:00
output:
  html_document:
    keep_md: true
    toc: true
tags:
  - "R"
  - "tuber"
  - "GCP"
  - "유투브"
categories:
  - "R"
  - "tuber"
  - "GCP"
  - "유투브"
menu:
  r:
    name: tuber 패키지와 유투브 API를 활용한 Youtube 댓글 수집
---



## 공지
- 본 자료는 아래 책에서 일부 발췌 하였고, 해당 코드를 재응용하기 위해 노력하였습니다. 전체 원 소스 코드를 보시려면 책을 구매하시기를 바랍니다. 
- 실무 예제로 끝내는 R 데이터 분석: 데이터 분석가에게 꼭 필요한 5가지 실무 예제로 분석 프로세스 이해하기
  + 구입처: http://www.yes24.com/Product/Goods/103449758?OzSrank=1

## 개요

-   Youtube API에 등록 후, 댓글 수집 및 감성을 분석하는 과정을 담았습니다.

## 구글 API 프로젝트 생성하기

-   API 사용을 위해서는 구글 개발자 콘솔에 접속한다.

    -   URL: <https://console.developers.google.com/>

![](img/youtube_01.png)

-   아래와 같이 새로운 프로젝트 만들기를 클릭 한다.

![](img/youtube_02.png)

-   새로운 프로젝트 이름을 명명한다. 필자는 `youtube-data`라고 명명했다.

![](img/youtube_03.png)

-   아래 그림과 같이 프로젝트가 나타날 것이다. 그러면, 1단계는 완성이 된 것이다.

![](img/youtube_04.png)

## 구글 계정 연동 인증

-   구글 프로젝트와 외부(예를 들면, RStudio)에서 직접 연결할 수 있도록 인증절차를 수행하기 위해, 왼쪽 사이드바에 있는 "OAuth 동의 화면(`OAuth Consent Screen`)" 메뉴를 클릭한다.

![](img/youtube_05.png)

-   앱정보, Scopes, Test Users 탭에서 순차적으로 필수 정보를 입력한다.

    -   필자는 Scopes, Test Users의 추가정보는 입력하지 않았다.

![](img/youtube_06.png)

-   마지막으로 등록이 완성되면 아래와 같은 화면이 나타날 것이다.

![](img/youtube_07.png)

## YouTube Data API 사용 신청하기

-   사용 신청 위해 왼쪽 사이드메뉴에서 Library를 클릭 후, `Youtube`를 검색한다.

![](img/youtube_08.png)

-   아래 메뉴에서 `YouTube Data API v3`를 클릭한다.

![](img/youtube_09.png)

-   아래 화면에서 사용 버튼(`ENABLE`)을 클릭하면 YouTube 댓글 수집할 수 있는 API 사용 신청이 완성된다.

![](img/youtube_10.png)

## OAuth 권한 연동

-   YouTube 댓글 수집에 앞서서 OAuth 권한을 먼저 연동해야 한다.
-   먼저 사용자 인증 정보 만들기(`CREATE CREDENTIALS`)를 클릭 한다.

![](img/youtube_11.png)

-   그 후 Client ID에서 Application Type은 데스크탑 앱으로 선정 후, 적당한 이름을 추가한다.

    -   필자는 `유투브_API`라고 명명했다.

![](img/youtube_12.png)

-   아래와 같이 Client ID와 Secret이 나오면 적당한 곳에 복사를 미리 해 놓는다. ![](img/youtube_13.png)

-   `tuber` 패키지를 설치한다.

    -   패키지 소개: <https://www.rdocumentation.org/packages/tuber/versions/0.9.9>


```r
# install.packages("tuber")
library(tuber)
library(ggplot2)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

-   미리 복사한 APP ID와Secret 번호를 입력한다.

``` {.r}
app_id = "ID 입력"
app_secret = "Secret 입력"
```

-   yt_oauth() 함수를 실행 시킨다.


```r
app_id = "1079765158115-fdtgdsjqj2ejnql6jj2erg97ki87tv1t.apps.googleusercontent.com"
app_secret = "I2NYLrfTC553IAjExiLF3RK9"

yt_oauth(app_id = app_id, 
         app_secret = app_secret, 
         token = "")
```




``` {.r}
Use a local file ('.httr-oauth'), to cache OAuth access credentials between R sessions?

1: Yes
2: No

Selection: 1
Adding .httr-oauth to .gitignore
Waiting for authentication in browser...
Press Esc/Ctrl + C to abort
Authentication complete.
```

-   인증 절차는 아래 그림과 같이 순차적으로 클릭하면 된다.

![](img/youtube_14.png)

![](img/youtube_15.png)

![](img/youtube_16.png)

-   생성된 두개의 파일(`.gitignore`, `httr-oauth`)을 확인한다.


```r
system("ls -a")
```

## 데이터 수집

-   이제 데이터를 수집하도록 한다.

-   이 때, YouTube 채널의 통계 정보를 수집하려면 해당 채널 ID가 필요하다.

    -   channel은 `부동산 읽어주는 남자`, channel_id는 `UC2QeHNJFfuQWB4cy3M-745g`이다. (주소창 확인)

![](img/youtube_17.png)

-   먼저 채널 데이터를 만들어 본다.


```r
youtuber_meta = data.frame(channel = c("부동산 읽어주는 남자"), 
                           channel_id = "UC2QeHNJFfuQWB4cy3M-745g")
```

-   각 채널의 통계 정보를 확인하기 위해서는 tuber 패키지의 `get_channel_stats()` 함수를 이용하여 수집한다.


```r
ytber_id = get_channel_stats(channel_id = youtuber_meta$channel_id[1])
```

```
## Channel Title: 부동산 읽어주는 남자 
## No. of Views: 71579774 
## No. of Subscribers: 686000 
## No. of Videos: 503
```

```r
ytber_stats = data.frame(channel = youtuber_meta$channel[1], ytber_id$statistics)
ytber_stats
```

```
##                channel viewCount subscriberCount hiddenSubscriberCount
## 1 부동산 읽어주는 남자  71579774          686000                 FALSE
##   videoCount
## 1        503
```

### 함수 만들기

-   이제 데이터가 채널 ID가 추가될 때 마다 함수를 만들어본다.


```r
youtuber_meta_df <- function(yt_channel, yt_channel_id) {
  temp_df <- data.frame(channel = yt_channel, 
                        channel_id = yt_channel_id)
  
  yt_stats = data.frame()
  if (nrow(temp_df) > 1) {
    cat("---starting---\n")
    for (i in 1:nrow(temp_df)) {
      cat("---for loop--\n")
      stats_all = get_channel_stats(temp_df[["channel_id"]][i])
      statistics = stats_all[["statistics"]]
      yt_stat = data.frame(channel = temp_df[["channel"]][i], 
                           stats = statistics)
      yt_stats = rbind(yt_stats, yt_stat)
    }
  } else {
    stats_all = get_channel_stats(temp_df[["channel_id"]][1])
    statistics = stats_all[["statistics"]]
    yt_stat = data.frame(channel = temp_df[["channel"]][1], 
                           stats = statistics)
    yt_stats = rbind(yt_stats, yt_stat)
  }
  return(yt_stats)
}

yt_channel = c("부동산 읽어주는 남자", "국민은행", "신한은행")
yt_channel_id = c("UC2QeHNJFfuQWB4cy3M-745g", "UCHq8auIJ8ewo7iD2pqX22UA", "UC4E394G9WuS9y6SlBZslMsQ")


data <- youtuber_meta_df(yt_channel, yt_channel_id)
```

```
## ---starting---
## ---for loop--
## Channel Title: 부동산 읽어주는 남자 
## No. of Views: 71579774 
## No. of Subscribers: 686000 
## No. of Videos: 503 
## ---for loop--
## Channel Title: KB국민은행 
## No. of Views: 160674093 
## No. of Subscribers: 210000 
## No. of Videos: 1146 
## ---for loop--
## Channel Title: 신한은행 
## No. of Views: 87936626 
## No. of Subscribers: 306000 
## No. of Videos: 492
```

## 데이터 시각화

-   주어진 데이터를 가지고 간단하게 막대 그래프를 작성해 본다.


```r
library(ggplot2)

data$stats.viewCount = as.numeric(data$stats.viewCount)
data$stats.subscriberCount = as.numeric(data$stats.subscriberCount)
data$stats.videoCount= as.numeric(data$stats.videoCount)

ggplot(data, aes(x = channel, y = stats.viewCount, fill = channel)) + 
  geom_col() + 
  geom_text(aes(label = stats.viewCount, y = stats.viewCount), stat = "identity", vjust= -0.5) + 
  scale_fill_manual(values = c("#FFCC01", "#444547", "#3BACE1")) + 
  scale_y_continuous(breaks = NULL) + 
  theme_minimal() + 
  labs(title = "title을 작성하세요", 
       subtitle = "subtitle을 작성하세요", 
       x = "channel (수정해보세요)", 
       y = "viewCount (수정해보세요)", 
       caption = "Image Created By McBert ('2021.09.30)") + 
  theme(text=element_text(family="AppleGothic"))
```

![](youtube_api_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

## 영상 컨텐츠 데이터 수집

-   이번에는 각 채널에 접속하여 동영상 탭을 클릭한다.

-   그리고, 오른쪽에 있는 인기 순으로 재 정렬 한뒤, 첫번째로 나오는 영상을 클릭한다.

    -   필자는 `절대로 전세 살지 마라 1부(Jul 12, 2017)`가 영상이었다.

-   영상 클릭 시, 발생하는 ID가 콘텐츠 ID가 된다.

    -   `https://www.youtube.com/watch?v=x9mGWCcCJAE`에서, `x9mGWCcCJAE`가 영상 컨텐츠 ID이다.


```r
mstpprVideo = get_stats(video_id = 'x9mGWCcCJAE')
mstpprVideo
```

```
## $id
## [1] "x9mGWCcCJAE"
## 
## $viewCount
## [1] "2677911"
## 
## $likeCount
## [1] "21122"
## 
## $dislikeCount
## [1] "2921"
## 
## $favoriteCount
## [1] "0"
## 
## $commentCount
## [1] "1604"
```

- 이번에는 각 채널의 모든 영상을 가져오는 함수를 살펴본다. 
- 그리고 그 중 한 동영상 ID를 추출하여 데이터를 가져오도록 한다. 
  + 집계는 실시간으로 집계가 되는 것을 확인 할 수 있다. 

```r
video_lists = list_channel_videos(channel_id = yt_channel_id[1], max_results = 51)
get_stats(video_id = video_lists$contentDetails.videoId[1])
```

```
## $id
## [1] "LZbjFJarcus"
## 
## $viewCount
## [1] "45450"
## 
## $likeCount
## [1] "2090"
## 
## $dislikeCount
## [1] "63"
## 
## $favoriteCount
## [1] "0"
## 
## $commentCount
## [1] "295"
```

## 영상 댓글 수집하기
- 이번에는 영상 댓글을 가져오도록 한다. 
- 이 때에는 `get_all_comments()`를 사용하도록 한다. 


```r
cmt_df = get_all_comments(video_id = video_lists$contentDetails.videoId[1])
cmt_df %>% head()
```

```
##       videoId
## 1 LZbjFJarcus
## 2 LZbjFJarcus
## 3 LZbjFJarcus
## 4 LZbjFJarcus
## 5 LZbjFJarcus
## 6 LZbjFJarcus
##                                                                                                                                                                                                                                                                                                                                                                                   textDisplay
## 1                                                                                                                                                                                                                                                                            제발 부읽남이 우려하는 그 정책발표가 없기를... <br>이 영상이 그저 기우였기를... <br>모두들 편안한 밤 보내시기를~
## 2       근데 나는 평범한 30대로서 평범한 서울직장인으로서 평범한 수준의 월급쟁이로서 지금은 지옥이 아니야?ㅋㅋㅋㅋㅋㅋ 물론 단추를 이미 잘못 잠구어 왔지만 지금이 지옥이라면 저러한 부작용이 큰 정책으로 불지옥이 된다한들 글쌔다.. 이젠 극약처방이 필요하다고봄<br>단추를 다풀고 다시 잠굴 가능성은 이런 극단적인 정책을 시행할 가능성보다 현저하게 낮을테니까ㅋㅋ 다들 이미 알고 있잖아요..
## 3                                                                                                                                                                                                                                                                                                                                                           신규계약 월세도 5프로 상한될까요?
## 4                                                                                                                                                                                                                                                                                                                          빌라 재건축 지원이나 해주고 1종주거 2종주거 머 그따위거 해지해!!!!
## 5                                                                                                                                                                                                                                                                                                                                                                    원하지않지만 강제로 벗겨
## 6 궁금한 부분이 있습니다. 어느 누구라도 답변 부탁드립니다. 전월세 표준임대료를 적용하면 1. 집을 실거주자한테 팔거나, 2. 실거주를하러 들어온다. 라고 하셨잔아요? 그럼 결국 전월세물량은 줄어도 매매물량이 늘어나니까 매매에 있어서 주택이 공급되는 효과가 나타나는거 아닌가요?(전세가는 고정되어있으니 매매가에 영향X) 그럼 집값이 하향된다라고 해야 논리가 맞는거같습니다. 답변 부탁드립니다.
##                                                                                                                                                                                                                                                                                                                                                                                  textOriginal
## 1                                                                                                                                                                                                                                                                                제발 부읽남이 우려하는 그 정책발표가 없기를... \n이 영상이 그저 기우였기를... \n모두들 편안한 밤 보내시기를~
## 2         근데 나는 평범한 30대로서 평범한 서울직장인으로서 평범한 수준의 월급쟁이로서 지금은 지옥이 아니야?ㅋㅋㅋㅋㅋㅋ 물론 단추를 이미 잘못 잠구어 왔지만 지금이 지옥이라면 저러한 부작용이 큰 정책으로 불지옥이 된다한들 글쌔다.. 이젠 극약처방이 필요하다고봄\n단추를 다풀고 다시 잠굴 가능성은 이런 극단적인 정책을 시행할 가능성보다 현저하게 낮을테니까ㅋㅋ 다들 이미 알고 있잖아요..
## 3                                                                                                                                                                                                                                                                                                                                                           신규계약 월세도 5프로 상한될까요?
## 4                                                                                                                                                                                                                                                                                                                          빌라 재건축 지원이나 해주고 1종주거 2종주거 머 그따위거 해지해!!!!
## 5                                                                                                                                                                                                                                                                                                                                                                    원하지않지만 강제로 벗겨
## 6 궁금한 부분이 있습니다. 어느 누구라도 답변 부탁드립니다. 전월세 표준임대료를 적용하면 1. 집을 실거주자한테 팔거나, 2. 실거주를하러 들어온다. 라고 하셨잔아요? 그럼 결국 전월세물량은 줄어도 매매물량이 늘어나니까 매매에 있어서 주택이 공급되는 효과가 나타나는거 아닌가요?(전세가는 고정되어있으니 매매가에 영향X) 그럼 집값이 하향된다라고 해야 논리가 맞는거같습니다. 답변 부탁드립니다.
##   authorDisplayName
## 1              옥민
## 2           Faenyle
## 3             scp O
## 4              여니
## 5            이선화
## 6            김무스
##                                                                                authorProfileImageUrl
## 1     https://yt3.ggpht.com/ytc/AKedOLRCFCbKcOt_eLerThbize-Lfk6ZofraN8Vr8w=s48-c-k-c0x00ffffff-no-rj
## 2     https://yt3.ggpht.com/ytc/AKedOLTo-j2_cIT3aFDAw1C6DiTYSA4HCoomBRQ6UQ=s48-c-k-c0x00ffffff-no-rj
## 3     https://yt3.ggpht.com/ytc/AKedOLTT4Gkq1xeYzjdnPdCqOUjt_meGrjf5sJe6QQ=s48-c-k-c0x00ffffff-no-rj
## 4     https://yt3.ggpht.com/ytc/AKedOLQ7jrlH4iMU7LLQ_5W6qsNpkjWyDJsM2RaZwQ=s48-c-k-c0x00ffffff-no-rj
## 5 https://yt3.ggpht.com/ytc/AKedOLQyj4nrcYREzJ4u2YQV2jaQDtrzGaQIhapaON3ISg=s48-c-k-c0x00ffffff-no-rj
## 6     https://yt3.ggpht.com/ytc/AKedOLR8qXld-7fX8-Ai0OQiU7I-CjZ9VKrk2YL_cQ=s48-c-k-c0x00ffffff-no-rj
##                                          authorChannelUrl
## 1 http://www.youtube.com/channel/UCgL_hJAiu5FLcb7xbCJKd_w
## 2 http://www.youtube.com/channel/UCjZFTsrvO5Qf6QH_pxzIUTA
## 3 http://www.youtube.com/channel/UCtHSZ7OeycHxO29VgGU2c9A
## 4 http://www.youtube.com/channel/UCgJBnjBc5hQclqrp4iESsYg
## 5 http://www.youtube.com/channel/UCkA9MVhjccgq-6tEf-M0jsg
## 6 http://www.youtube.com/channel/UCJZ60Tpq9k5xvQIdKx_4Pog
##      authorChannelId.value canRate viewerRating likeCount          publishedAt
## 1 UCgL_hJAiu5FLcb7xbCJKd_w    TRUE         none         0 2021-09-30T15:27:25Z
## 2 UCjZFTsrvO5Qf6QH_pxzIUTA    TRUE         none         0 2021-09-30T15:24:59Z
## 3 UCtHSZ7OeycHxO29VgGU2c9A    TRUE         none         0 2021-09-30T15:24:46Z
## 4 UCgJBnjBc5hQclqrp4iESsYg    TRUE         none         0 2021-09-30T15:24:09Z
## 5 UCkA9MVhjccgq-6tEf-M0jsg    TRUE         none         0 2021-09-30T15:21:35Z
## 6 UCJZ60Tpq9k5xvQIdKx_4Pog    TRUE         none         0 2021-09-30T15:09:05Z
##              updatedAt                         id parentId moderationStatus
## 1 2021-09-30T15:27:25Z UgxZMm7HV-twdjopZm94AaABAg     <NA>               NA
## 2 2021-09-30T15:25:48Z UgywXPBreLsyD0xyucp4AaABAg     <NA>               NA
## 3 2021-09-30T15:24:46Z Ugy8ZatzFpxIzXl1NVl4AaABAg     <NA>               NA
## 4 2021-09-30T15:24:09Z UgyrTptb-LjHdPukSax4AaABAg     <NA>               NA
## 5 2021-09-30T15:21:35Z Ugw1yWFgJim17JSFkQF4AaABAg     <NA>               NA
## 6 2021-09-30T15:09:05Z Ugzmz1XAThvL2pXQtrV4AaABAg     <NA>               NA
```

## R 강의 소개
- 필자의 강의: 왕초보 데이터 분석 with R
  + 쿠폰 유효일은 2021년 10월 30일까지입니다. 
  + 링크: https://www.udemy.com/course/beginner_with_r/?couponCode=5BF397C9A1E46079627D
  + 현재 강의를 계속 찍고 있고, 가격은 한 Section이 끝날 때마다 조금씩 올릴 예정입니다. 
  
