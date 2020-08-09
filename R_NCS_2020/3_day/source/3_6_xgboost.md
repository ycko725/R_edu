---
title: "Kaggle with R"
date: 2020-08-08T21:00:00+09:00
output: 
  html_document: 
    keep_md: true
    toc: true
tags:
  - "Kaggle"
  - "R"
  - "pins"
categories:
  - "Kaggle"
  - "R"
menu: 
  r:
    name: Kaggle with R
---




## XGBoost 개요
- 논문 제목 - [XGBoost: A Scalable Tree Boosting System](https://arxiv.org/abs/1603.02754)
- 논문 게재일: Wed, 9 Mar 2016 01:11:51 UTC (592 KB)
- 논문 저자: Tianqi Chen, Carlos Guestrin
- 논문 소개
> Tree boosting is a highly effective and widely used machine learning method. In this paper, we describe a scalable end-to-end tree boosting system called XGBoost, which is used widely by data scientists to achieve state-of-the-art results on many machine learning challenges. We propose a novel sparsity-aware algorithm for sparse data and weighted quantile sketch for approximate tree learning. More importantly, we provide insights on cache access patterns, data compression and sharding to build a scalable tree boosting system. By combining these insights, XGBoost scales beyond billions of examples using far fewer resources than existing systems.
- 효과적인 머신러닝 방법
  + 확장가능한 머신러닝 모형
  + A novel sparsity-aware algorithm 
  + Cache access patterns, Data compression and Sharding
    * 위 조합을 통해 기존 시스템보다 훨씬 더 적은 리소스를 투입해도 좋은 성과를 낼 수 있도록 구현함. 


## 논문 주요 내용 요약
- `XGboost`는 `GBM`에서 나온 출발한 알고리즘
- 논문에 있는 주요 내용을 요약한다. 

### (1) 과적합 규제
- 표준 GBM의 경우 과적합 규제 기능이 없으나 XGBoost는 자체에 과적합 규제 기능으로 과적합에 좀 더 강한 내구성 가짐. 
  + The additional regularization term helps to smooth the final learnt weights to avoid over-fitting. Intuitively, the regularized objective will tend to select a model employing simple and predictive functions.

### (2) shrinkage and Column Subsampling
- 두 기법 모두 과적합 방지용으로 사용됨
  + shrinkage: reduces the influence of
each individual tree and leaves space for future trees to improve the model.
  + Column Subsampling: 랜덤포레스트에 있는 기법, 변수가 많을 때, 변수의 개수를 지정하면 랜덤하게 변수가 투입됨
    * 병렬처리에 적합함

## 실습 코드

### (1) Kaggle API with R
- 먼저 [Kaggle]에 회원 가입을 한다. 
- 회원 가입 진행 후, Kaggle에서 kaggle.json 파일을 다운로드 받는다. 

![](https://chloevan.github.io/img/kaggle/kaggle_with_colab/kaggle_01_api.png)

- 그리고 아래와 같이 `kaggle.json`을 `RStudio`에 등록한다. 


```r
# install.packages("pins")
library(pins)
board_register_kaggle(token = "../../../../../Desktop/kaggle.json")
```
- [pins](http://pins.rstudio.com/)는 일종의 `cache`를 이용한 자원 관리 패키지이다. 
  + 원어: Pin remote resources into a local cache to work offline, improve speed and avoid recomputing; discover and share resources in local folders, 'GitHub', 'Kaggle' or 'RStudio Connect'. Resources can be anything from 'CSV', 'JSON', or image files to arbitrary R objects.
  
- 이 패키지를 이용하면 보다 쉽게 `kaggle` 데이터를 불러올 수 있다. 

### (2) 데이터 불러오기 
- 이제 `titanic` 데이터를 불러오자
  + 처음 `kaggle` 대회에 참여하는 사람들은 우선 `Join Competiton` 버튼을 클릭한다. 
    * 참고: [Google Colab with Kaggle - Beginner](https://chloevan.github.io/settings/kaggle_with_colab_beginner/)
- 소스코드로 확인해본다. 

```r
pin_find("titanic", board="kaggle")
```

```
## # A tibble: 21 x 4
##    name                               description                    type  board
##    <chr>                              <chr>                          <chr> <chr>
##  1 abhinavralhan/titanic              titanic                        files kagg…
##  2 azeembootwala/titanic              Titanic                        files kagg…
##  3 broaniki/titanic                   titanic                        files kagg…
##  4 c/titanic                          Titanic: Machine Learning fro… files kagg…
##  5 carlmcbrideellis/titanic-all-zero… Titanic all zeros csv file     files kagg…
##  6 cities/titanic123                  Titanic Dataset Analysis       files kagg…
##  7 davorbudimir/titanic               Titanic                        files kagg…
##  8 dushyantkhinchi/titanic-survival   Titanic survival               files kagg…
##  9 fossouodonald/titaniccsv           Titanic csv                    files kagg…
## 10 harunshimanto/titanic-solution-a-… Titanic Solution: A Beginner'… files kagg…
## # … with 11 more rows
```

- 캐글에서 검색된 `titanic`과 관련된 내용이 이렇게 있다. 
  + 여기에서 `competition`과 관련된 것은 `c/name_of_competition`이기 때문에 `c/titanic`을 입력하도록 한다. 
  + (`pins` 패키지를 활용해서 함수를 만들어 볼까 잠깐 생각)
- 이번에는 `pin_get()` 함수를 활용하여 데이터를 불러온다. 

```r
pin_get("c/titanic")
```

```
## [1] "/Users/evan/Library/Caches/pins/kaggle/titanic/gender_submission.csv"
## [2] "/Users/evan/Library/Caches/pins/kaggle/titanic/test.csv"             
## [3] "/Users/evan/Library/Caches/pins/kaggle/titanic/train.csv"
```
- 출력된 경로에 이미 데이터가 다운받아진 것이다. 
- 이제 데이터를 불러온다. 
  + 이 때, `pin_get`을 값을 임의의 변수 `dataset`으로 할당한 후 하나씩 불러오도록 한다. 
  

```r
dataset <- pin_get("c/titanic")
train <- read.csv(dataset[3])
test <- read.csv(dataset[2])

dim(train); dim(test)
```

```
## [1] 891  12
```

```
## [1] 418  11
```

- 데이터가 정상적으로 불러와진 것을 확인할 수 있다. 
- 간단한 시각화, 데이터 가공 후, 모형 생성 및 제출까지 진행하도록 해본다.  

### (3) 데이터 전처리 (중복값 & 결측치)
- 데이터를 불러온 뒤에는 항상 중복값 및 결측치를 확인한다. 
- 먼저 중복값을 확인하자. 
  + sample code

```r
temp <- data.frame(a = c(1, 1, 2, 3), 
                   b = c("a", "a", "b", "c"))

sum(duplicated(temp))
```

```
## [1] 1
```
- 이와 같은 방식으로 계산할 수 있다. 
- 중복값을 제거할 때는 `dplyr` 패키지 내에 있는 `distinct()` 사용한다. 


```r
dplyr::distinct(temp)
```

```
##   a b
## 1 1 a
## 2 2 b
## 3 3 c
```

- 이제 본 데이터에 적용한다. 


```r
train <- dplyr::distinct(train); dim(train)
```

```
## [1] 891  12
```

```r
test <- dplyr::distinct(test); dim(test)
```

```
## [1] 418  11
```
- 이번에는 결측치의 개수를 확인해본다. 

```r
colSums(is.na(train))
```

```
## PassengerId    Survived      Pclass        Name         Sex         Age 
##           0           0           0           0           0         177 
##       SibSp       Parch      Ticket        Fare       Cabin    Embarked 
##           0           0           0           0           0           0
```

