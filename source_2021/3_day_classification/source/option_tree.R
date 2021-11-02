# ---- 의사결정나무의 용어 ---- 
# 뿌리(Root Node): Tree 구조가 시작되는 노드(모든 데이터로 구성됨)
# 끝마디 잎 (Terminal Node): Tree 구조의 끝에 위치하는 노드, Terminal 노드 이후, 더 이상 분기는 없음
# 부모 노드(Parent Node) / 자식 노드(Child Node): 분기 되기 전 마디를 부모노드, 분기 된 후 노드들을 자식노드라고 함
# 중간마디(Internal Node): Tree 구조의 중간에 위치하는 마디
# 가지(Branch): 뿌리에서 끝마디까지 연결된 하나의 연결형태를 의미
# 깊이(Depth): 가지를 이루는 Node의 단계수를 의미

# ---- 분기기준(Splitting Criterion) ----
# 분기기준이란 부모노드에서 자식노드로 분기될 때, 어떠한 독립변수를 이용하여 어떻게 범주를 구분하여 설정하는 것이 종속변수 분포를 잘 구분할 수 있는지를 결정하는 기준
# 이 때, 종속변수 분포를 구별하는 정도를 순수도, 비순수도라는 지표를 산정

# ---- 분리기준에 사용하는 지표 ----
# 카이제곱 통계량의 p값: 분석대상 자료의 검정통계량 x2의 유의확률 p값이 가장 작은 독립변수와 이에 따른 최적 분리로 Child Node 구성
# 지니지수(Gini Index): 데이터의 비순수도를 나타내는 지니지수를 측정하여 이를 감소시켜 주는 독립변수와 이에 따른 최적분리로 Child Node로 구성됨
# 엔트로피 지수(Entropy Index): 비순수도를 나타내는 지표로서 이를 감소시켜주는 독립변수와 이에 따른 최적분리로 Child 노드를 구성함
# ANOVA Table의 F 통계량 p값: ANOVA Table의 F 통계량에 대한 유의확률 p값이 가장 작은 독립변수와 이에 따른 최적 분리로 Child 노드를 구성
# 분산의 감소량(Variance Reduction): 종속변수의 실측치와 모형에 의한 추정치와의 오차를 최소화하는 기준과 같이, 분산을 최소화하는 독립변수와 이에 따른 최적분리로 Child Node 구성


# tree 구조
library(rpart)
library(rpart.plot)

# 모델 개발 
train <- sample(1:150, 100) # 임의 학습데이터 추출
tree <- rpart(Species ~ Sepal.Length + Sepal.Width + Petal.Length + 
                  Petal.Width, data=iris, subset =train, method = "class")
rpart.plot(tree)

# 학습된 내용 확인
summary(tree)

# 가지치기(Prunning) 수행하기
printcp(tree)

# cp: 기준이 되는 복잡도
pruned_tree = prune(tree, cp = 0.1) # cp = 0.1로 가지치기
rpart.plot(pruned_tree)

# 학습된 의사결정나무모델으로 Test셋 예측하기
predict(pruned_tree, iris[-train, ], type = "class")
