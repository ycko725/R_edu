# apply function
# apply(X, MARGIN, FUN)
# - x: 배열, 배열
# - MARGIN: 1 또는 2
# - MARGIN = 1: rows; MARGIN = 2: columns
# - MARGIN = c(1, 2): rows and columns 
# FUN: 기본적인 기본적인 mean, median, sum, min, max, 사용자 정의 함수

mat_01 = matrix(c(1:4), nrow = 2, ncol = 4)
mat_01

apply_mat01 = apply(mat_01, 2, sum)
apply_mat01

# lapply(X, FUN)
# - X: A vector or an object
# - FUN: Function Applied to Each Element of X

movies = c("스파이더맨", "배트맨", "아이언맨")
movies_lower = lapply(movies, nchar)
movies_lower

# iterate over a list
a = list(A = c(8, 7, 5, 10), 
         B = data.frame(x = 1:5, y = c(5, 1, 0, 2, 3)))

a
lapply(a, sum)

# lapply multiple arguments
a = list(
  A = c(56, 20, 60, 30), 
  B = c(80, 10, 40, 20, 78, 44)
)

# quantile
lapply(a, quantile, probs = c(0.25, 0.5, 0.75))

# sapply(X, FUN) 
# - X: A vector or an object
# - FUN: Function Applied to Each Element of X

movies = c("스파이더맨", "배트맨", "아이언맨")
movies_lower = sapply(movies, nchar)
movies_lower

# iterate over a list
a = list(A = c(8, 7, 5, 10), 
         B = data.frame(x = 1:5, y = c(5, 1, 0, 2, 3)))

a
sapply(a, sum)

# lapply multiple arguments
a = list(
  A = c(56, 20, 60, 30), 
  B = c(80, 10, 40, 20, 78, 44)
)

# quantile
sapply(a, quantile, probs = c(0.25, 0.5, 0.75))

# tapply()
# -X: An object, usually a vector
# -INDEX: A list containing factor
# -FUN: Function applied to each element of x

data(mpg)
str(mpg)

tapply(mpg$hwy, mpg$class, median)
