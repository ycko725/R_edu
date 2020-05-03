---
title: "[R 초중급] 시각화부터 머신러닝까지 - NCS 2020"
date: 2020-05-02
author: 강사 
---

# NCS 2020 with R <img src="image/HRD.jpg" width="120" align="right" /><img src="image/RStudio.svg" width="120" align="right" />

## I. 강의 개요
- NCS 교재를 기반으로 강사가 참조한 다양한 소스를 통합하여 자료를 만들었습니다. 
- 교육과정은 기본적으로 4일 8시간 총 32시간으로 구성되어 있습니다. 
  + 직접 Scripting을 하는 시간을 원하는 교육과정 요청시, 시간은 최대 80시간 2주까지 늘어날 수 있습니다. 

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
- 먼저 [Git](https://git-scm.com/book/ko/v2/%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-Git-%EC%84%A4%EC%B9%98)을 각 OS에 맞게 설치하신 후 터미널에서 아래와 같이 입력하고 실행합니다. 

```terminal
$ git clone https://github.com/chloevan/R_edu.git
```

- 이 때, 파일 경로에 유의하시기를 바랍니다. 

## V. 이슈
소스 코드 실행 시, 에러가 발생이 되면 아래 메일로 문의 주세요.
[이메일 문의](mailto:j2hoon85@gmail.com)



