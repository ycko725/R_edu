---
title: "[R 초중급] 시각화부터 머신러닝까지 - NCS 2020"
date: 2020-05-02
author: 강사 
---

# NCS 2020 with R <img src="image/HRD.jpg" width="120" align="right" /><img src="image/RStudio.svg" width="120" align="right" />

## 필수 프로그램 설치
- R을 처음 접하시는 분들은 R & RStudio을 각각 설치하여 주시기를 바랍니다. 
  + 윈도우 사용자 [Download R 4.0.0 for Windows](https://cran.r-project.org/bin/windows/base/)
  + Mac 사용자 [R for Mac OS X](https://cran.r-project.org/bin/macosx/)
    * `R-4.0.0.pkg`를 클릭 하셔서 다운로드 받으시기를 바랍니다. 
  + Linux 사용자는 OS마다 다릅니다. 따라서, 어떤 OS를 선택하실지 폴더 선택 후 해당 명령어를 터미널에서 입력하셔서 설치하시기를 바랍니다. [Linux 설치](https://cran.r-project.org/bin/linux/)

- 이제 RStudio을 설치합니다. 
  + [Download RStudio 설치 페이지](https://rstudio.com/products/rstudio/download/) 에 들어가시면 본인의 OS에 맞는 설치 파일을 제공하고 있습니다. (Windows, MacOS, Linux 모두 확인 가능합니다.)

- 프로젝트 관리 프로그램 중 하나인 `Git`을 사용합니다. 
  + 먼저 [Git](https://git-scm.com/book/ko/v2/%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-Git-%EC%84%A4%EC%B9%98)을 각 OS에 맞게 설치하시기를 바랍니다. 

- 본 과정에는 `Java` 기반의 머신러닝 패키지인 `h2o` 패키지 실습 예제가 있습니다. 따라서 본인의 OS에 맞는 Java를 설치하시기를 바랍니다.
  + 윈도우 사용자 참고자료: [JAVA - 자바 JDK 설치 및 개발환경 구축 windows10, 환경변수 설정](java.md)
  + MacOS 사용자 참고자료: [Install JDK 12.0.1](https://hongku.tistory.com/367)

## I. 강의 개요
- NCS 교재를 기반으로 강사가 참조한 다양한 소스를 통합하여 자료를 만들었습니다. 
- 교육과정은 기본적으로 4일 8시간 총 32시간으로 구성되어 있습니다. 
  + 직접 Scripting을 하는 시간을 원하는 교육과정 요청시, 시간은 최대 80시간 2주까지 늘어날 수 있습니다.
- 본 강의에서는 알고리즘, 통계 이론 등에 대해 간단하게 맛을 보는 강의입니다. 
  + 수업 요청 시, 추가적으로 공부할 수 있는 다양한 추천 교재 등을 알려드립니다. 
- 본 강의 시작과 함께, [시각화 대시보드](https://shiny.rstudio.com/) 프로젝트 시작을 권유합니다. 
  + 대시보드 Tutorial은 [Shiny 프로젝트 Review & 더 알아볼 것](https://chloevan.github.io/r/shiny/project_final/)을 활용합니다. 
- 하루 8시간 강의 시, 4시간은 강사의 설명과 스크립트 실행을 진행하고, 나머지 4시간은 학생들이 직접 코딩하는 시간을 드립니다. 
  + 4시간 직접 코딩하면서 궁금한 분들은 개별적으로 질의하시면 답변 드립니다. 

## II. 강의 목차
강의 개요는 아래와 같습니다. 

### 1일차: 데이터 전처리와 시각화
- R & RStudio 설치 및 CRAN 생태계 설명
- 데이터 전처리: dplyr 활용
- 데이터 시각화: ggplot2 패키지 & 그외 동적 시각화 패키지

### 2일차: 기초통계 및 회귀분석 ML모형
- 통계분석: 기술통계분석, 교차분석, 집단간 차이분석, 회귀분석 및 보고서 작성 요령
- 회귀모형개발: 선형회귀, 다중회귀, caret 패키지 활용

### 3일차: 분류모형 및 h2o 패키지 소개
- 이상치 및 결측치 처리
- 이항 및 다항분류
- caret 패키지 & h2o 패키지 활용 모형 개발

### 4일차: 모형성능 향상 및 딥러닝 예제
- 통계적 preProcessing 절차 소개
- Parameter Tuning 절차 및 Sample 소개
- 딥러닝 소개 및 keras and tensorflow 2.0 Sample 튜토리얼

## III. R 언어 Version

- 소스 코드는 아래와 같은 환경에서 작성되었습니다. 

```r
> sessionInfo()
R version 4.0.0 (2020-04-24)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS Catalina 10.15.3
```

## IV. 폴더 구조
- data: 내장데이터와 함께 사용된 Sample 데이터 저장소
- source: R 작성 코드 
- docs: 차수별 PDF 자료

## V. 다운로드 방법

```terminal
$ git clone https://github.com/chloevan/R_edu.git
```

- 이 때, 파일 경로에 유의하시기를 바랍니다. 

## VI. 소스코드 실행 Tip
- 기존 3.6.x 버전 사용자 중, R 4.0.0 버전으로 업그레이드 하셨다면, 특히 `caret` 패키지 내 모형 `train`시 패키지 설치 안내 문구 메시지 팝업이 확인 될 것입니다.  
  + 예)
```r
> plsFit <- train(Class ~ .,
+                 data = training,
+                 method = "pls", 
+                 trControl = control,
+                 metric = "ROC")
1 package is needed for this model and is not installed. (pls). Would you like to try to install it now?
1: yes
2: no
Selection: plsFit
Enter an item from the menu, or 0 to exit
Selection: 
```

그러면, `Selection:` 에서 `1`을 입력후 `Enter`를 클릭하셔서 설치하시기를 바랍니다. 

## VII. 이슈
- 소스 코드 실행 시, 에러가 발생이 되면 아래 메일로 문의 주세요.
[이메일 문의](mailto:j2hoon85@gmail.com)

## VIII. 요청사항
- 위 자료가 마음에 드셨다면, 우측 상단에 :star: `Star`를 꼭 눌러주세요! 

