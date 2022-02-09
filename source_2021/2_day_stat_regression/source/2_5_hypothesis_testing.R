#--------------------------------#
#### 1. Z-통계량 구하기 ####
#--------------------------------#

mean_15 = 120
mean_20 = 125
sd_20   = 15
N       = 30
z_value = (125 - 120) / (15 / sqrt(N))

# https://www.geogebra.org/classic#probability

#--------------------------------#
#### 2. Z-분포 구하기 ####
#--------------------------------#
# 유의수준 0.05에서 양측검정을 실시한다. 
qt(0.025, df = 30) # why 0.025? 양측검정이기 때문
# [1] -2.042272

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
