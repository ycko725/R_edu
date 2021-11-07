# PCA(Principal Component Analysis) 분석
# - 차원축소(Dimensionality Reduction)와 변수추출(Feature Extraction)기법으로 널리 쓰임. 
# - 이론 참고자료: https://ratsgo.github.io/machine%20learning/2017/04/24/PCA/
# - 본 장에서는 주로 코드 설명 위주로 작성함. 
# 변수 간의 공분산/상관을 조사하는 스펙트럼 분해(Spectral Decomposition)
# 개체 간의 공분산/상관을 조사하는 특이값 분해(Singular Value Decomposition)
# 주로 쓰이는 함수는 마찬가지로 크게 두가지임
# - princomp(): Spectral Decomposition
# - prcomp(): Singular Value Decomposition
# - R 문서에 따르면 prcomp()의 정확도가 매우 약간 좋다고 함. 
# - 그러나 여기에서는 PCA() 함수를 주로 사용하도록 함. 

# install.packages("factoextra")
library(factoextra)
library(FactoMineR)
library(tidyverse)
?prcomp
# prcomp(x, scale = FALSE)
# - x: numeric matrix or data frame
# - scale: 데이터 스케일링 여부

# ---- 데이터 수집 ---- 
?decathlon2
data("decathlon2")
glimpse(decathlon2)

# 마지막 3개의 데이터는 수치 데이터와 거리가 멀다. 
new_data = decathlon2[1:23, 1:10]
glimpse(new_data)

# Data Standardization
# -- Scaling: 각 수치형의 범위가 다 다름
# 예): g vs kg, m vs km 동일하게 사용가능한가? 
# 각각의 데이터의 수치를 그대로 비교가 가능한가? 
# 식 (x1 - mean(x)) / sd(x))
# --> x1은 임의의 한개의 데이터
# --> mean(x)은 전체 데이터의 평균
# --> sd은 전체데이터의 표준편차

# ---- PCA 모형 적합 ----
# PCA(X, scale.unit = TRUE, ncp = 5, graph = TRUE)
# - X: 데이터 프레임, 행과 열은 모두 수치형 데이터로 구성이 되어야 함
# - scale.unit = TRUE, TRUE값을 지정하면 스케일링을 함
# - ncp: 최종 결괏값의 차원의 개수를 지정할 수 있다. 
# - graph: A logical value. 

iris_pca_m = PCA(iris[, -5], graph = FALSE) # TRUE
iris_pca_m

# PCA의 수학적 이해
# get_eigenvalue(res.pca): eigenvalues(고유값)/Variance(분산)
# -- 분산이 가장 큰 방향(또는)이 데이터에서 가장 많은 정도를 담고 있는 방향이다. 
# -- 데이터의 분산이 클수록 데이터를 의미있게 분석할 수 있다. 

eig_val = get_eigenvalue(iris_pca_m)
eig_val

# 해석
# - eigenvalue 모든 합을 구하면 
# 2.91849782 + 0.91403047 + 0.14675688 + 0.02071484 / [1] 4
# variance.percent : 2.91849782 / 4
# 만약에 eigenvalue > 1, 각 PC는 표준화된 데이터의 원래 변수 중 하나에서 설명하는 것보다 더 많은 분산을 차지한다는 것을 나타냄. 이는 일반적으로 PC가 유지되는 컷오프 포인트로 사용됩니다. 이는 데이터가 표준화되었을 때만 유효함. 
# PCA (Kaiser 1961)

# 모형적합 시각화
fviz_eig(iris_pca_m, addlabels = TRUE, ylim = c(0, 80))
# 약 2 dimension이면 충분히 많은 정보를 담고 있다고 생각할 수 있음. 

var <- get_pca_var(iris_pca_m)

# 산점도 생성을 위한 변수 좌표
var$contrib 

# 요인 맵의 변수에 대한 표현 품질을 나타냅니다. 이 값은 var.cos2 = var.coord * var.coord 의 제곱 좌표로 계산됩니다.
var$cos2 

# 주성분에 대한 변수의 기여(백분율)가 포함됩니다. 주어진 주성분에 대한 변수(var)의 기여도는 (백분율) : (var.cos2 * 100) / (성분의 총 cos2)입니다.
var$coord

# ---- 상관관계 시각화 ---- 
library(corrplot)
corrplot(var$cos2, is.corr = FALSE)

# Total cos2 of variables on Dim.1 and Dim.2 
fviz_cos2(iris_pca_m, choice = 'var', axes = 1:2)

fviz_pca_var(iris_pca_m, col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), 
             repel = TRUE # Avoid text overlapping
)

# Contributions of variables to PC1 (주성분)
fviz_contrib(iris_pca_m, choice = "var", axes = 1, top = 10)

# Contributions of variables to PC2 (주성분)
fviz_contrib(iris_pca_m, choice = "var", axes = 2, top = 10)
