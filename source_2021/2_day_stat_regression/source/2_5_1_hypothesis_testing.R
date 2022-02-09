#--------------------------------#
#### 1. Z-통계량 구하기 ####
#--------------------------------#

mean_15 = 120
mean_20 = 125
sd_20   = 15
N       = 30
z_value = (125 - 120) / (15 / sqrt(N))

#--------------------------------#
#### 2. Z-분포 구하기 ####
#--------------------------------#
# 유의수준 0.05에서 양측검정을 실시한다. 
qt(0.025, df = N-1) # why 0.025? 양측검정이기 때문
# [1] -2.04523
par(mar=c(0,1,1,1))

x <- seq(-3, 3, by=0.001)
y <- dt(x, df=N)
plot(x, y, type="l", axes=F, ylim=c(-0.02, 0.38), main="", xlab="t", ylab="")
abline(h=0)
alpha <- 0.05
ul <- round(qt(1-(alpha/2), df=N), 2)
ll <- -ul
polygon(c(-3, x[x<ll], ll), c(0, y[x<ll], 0), col=2)
polygon(c(ul, x[x>ul], 3), c(0, y[x>ul], 0), col=2)

# arrows(z_value, 0.05, z_value, 0, length=0.1, col = "red")
# text(z_value, 0.07, paste("t=", round(z_value, 3)))

text(ll, -0.02, expression(-t[0.025]==-2.05))
text(ul, -0.02, expression(t[0.025]==2.05))

#--------------------------------#
#### 3. Z-value 통계량의 위치 파악하기 ####
#--------------------------------#
x <- seq(-3, 3, by=0.001)
y <- dt(x, df=N-1)
plot(x, y, type="l", axes=F, ylim=c(-0.02, 0.38), main="", xlab="t", ylab="")
abline(h=0)
alpha <- 0.05
ul <- round(qt(1-(alpha/2), df=N), 2)
ll <- -ul
polygon(c(-3, x[x<ll], ll), c(0, y[x<ll], 0), col=2)
polygon(c(ul, x[x>ul], 3), c(0, y[x>ul], 0), col=2)

arrows(z_value, 0.05, z_value, 0, length=0.1, col = "red")
text(z_value, 0.07, paste("t=", round(z_value, 3)))

text(ll, -0.02, expression(-t[0.025]==-2.05))
text(ul, -0.02, expression(t[0.025]==2.05))

#--------------------------------#
#### 4. 유의확률 구하기 ####
#--------------------------------#
par(mar=c(0,1,1,1))

x <- seq(-3, 3, by=0.001)
y <- dt(x, df=N-1)
plot(x, y, type="l", axes=F, ylim=c(-0.02, 0.38), main="", xlab="t", ylab="")
abline(h=0)
alpha <- 0.05
ul <- round(qt(1-(alpha/2), df=N-1), 2)
ll <- -ul
polygon(c(-3, x[x<ll], ll), c(0, y[x<ll], 0), col=2)
polygon(c(ul, x[x>ul], 3), c(0, y[x>ul], 0), col=2)
text(ll, -0.02, expression(-t[0.025]==-2.05))
text(ul, -0.02, expression(t[0.025]==2.05))

p.value <- 1 - pt(z_value, df=N-1)
polygon(c(z_value, x[x>z_value], 3), c(0, y[x>z_value], 0), density=20, angle=45)
text(z_value-0.3, 0.04, paste("t=", round(z_value, 3)))
text(2.3, 0.1, paste("P(T>t)=",round(p.value, 3)))

# 유의확률 해석
# 양쪽 검증 실 시, 유의 확률은 0.5
# 그러나 통상 절반의 값만 나오기 때문에 a * 2를 하거나 유의확률을 절반으로 나눠서 구함

# 최종 분석 해석
# 질문: Q. 2020년 만 7세 여자 어린이의 평균 키는 2015년과 다른가요?
# 결론: 2020년 만 7세 여자 어린이의 평균 키는 유의수준 0.05 수준에서 2015년 평균 키와 다르지 않다는 귀무가설을 기각할 수 없다. 즉, 2020년 만 7세 여자 어린이의 평균 키는 2015년과 동일한 120cm로 봐야 한다. 

