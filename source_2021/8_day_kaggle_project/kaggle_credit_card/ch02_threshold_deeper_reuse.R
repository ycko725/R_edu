# ---- 참고문헌 ----
# Illustrated Guide to ROC and AUC: https://www.r-bloggers.com/2015/06/illustrated-guide-to-roc-and-auc/#google_vignette

# ---- 패키지 ----
library(randomForest)
library(caret)
library(gridExtra)
library(grid)
library(ggplot2)
library(corrplot)
library(pROC)
library(formattable)
library(dplyr)
library(readr)

# ---- 데이터 불러오기 ----

# ---- Utils Function ----
calculate_roc <- function(verset, cost_of_fp, cost_of_fn, n=100) {
  
  tp <- function(verset, threshold) {sum(verset$predicted >= threshold & verset$Class == 1)}
  fp <- function(verset, threshold) {sum(verset$predicted >= threshold & verset$Class == 0)}
  tn <- function(verset, threshold) {sum(verset$predicted <  threshold & verset$Class == 0)}
  fn <- function(verset, threshold) {sum(verset$predicted <  threshold & verset$Class == 1)}
  tpr <- function(verset, threshold) {sum(verset$predicted >= threshold & verset$Class == 1) / sum(verset$Class == 1)}
  fpr <- function(verset, threshold) {sum(verset$predicted >= threshold & verset$Class == 0) / sum(verset$Class == 0)}
  cost <- function(verset, threshold, cost_of_fp, cost_of_fn) { sum(verset$predicted >= threshold & verset$Class == 0) * cost_of_fp + 
      sum(verset$predicted < threshold & verset$Class == 1) * cost_of_fn}
  threshold_round <- function(value, threshold){return (as.integer(!(value < threshold)))}

  auc_ <- function(verset, threshold) { auc(verset$Class, threshold_round(verset$predicted,threshold))}
  
  roc <- data.frame(threshold = seq(0,1,length.out=n), tpr=NA, fpr=NA)
  roc$tp <- sapply(roc$threshold, function(th) tp(verset, th))
  roc$fp <- sapply(roc$threshold, function(th) fp(verset, th))
  roc$tn <- sapply(roc$threshold, function(th) tn(verset, th))
  roc$fn <- sapply(roc$threshold, function(th) fn(verset, th))
  roc$tpr <- sapply(roc$threshold, function(th) tpr(verset, th))
  roc$fpr <- sapply(roc$threshold, function(th) fpr(verset, th))
  roc$cost <- sapply(roc$threshold, function(th) cost(verset, th, cost_of_fp, cost_of_fn))
  roc$auc <-  sapply(roc$threshold, function(th) auc_(verset, th))
  return(roc)
}

# roc plot
plot_roc <- function(roc, threshold, cost_of_fp, cost_of_fn) {
  library(gridExtra)
  norm_vec <- function(v) (v - min(v))/diff(range(v))
  idx_threshold = which.min(abs(roc$threshold-threshold))
  
  col_ramp <- colorRampPalette(c("green","orange","red","black"))(100)
  col_by_cost <- col_ramp[ceiling(norm_vec(roc$cost)*99)+1]
  p_roc <- ggplot(roc, aes(fpr,tpr)) + 
    geom_line(color=rgb(0,0,1,alpha=0.3)) +
    geom_point(color=col_by_cost, size=2, alpha=0.5) +
    labs(title = sprintf("ROC")) + xlab("FPR") + ylab("TPR") +
    geom_hline(yintercept=roc[idx_threshold,"tpr"], alpha=0.5, linetype="dashed") +
    geom_vline(xintercept=roc[idx_threshold,"fpr"], alpha=0.5, linetype="dashed")
  
  p_auc <- ggplot(roc, aes(threshold, auc)) +
    geom_line(color=rgb(0,0,1,alpha=0.3)) +
    geom_point(color=col_by_cost, size=2, alpha=0.5) +
    labs(title = sprintf("AUC")) +
    geom_vline(xintercept=threshold, alpha=0.5, linetype="dashed")
  
  p_cost <- ggplot(roc, aes(threshold, cost)) +
    geom_line(color=rgb(0,0,1,alpha=0.3)) +
    geom_point(color=col_by_cost, size=2, alpha=0.5) +
    labs(title = sprintf("cost function")) +
    geom_vline(xintercept=threshold, alpha=0.5, linetype="dashed")
  
  sub_title <- sprintf("threshold at %.2f - cost of FP = %d, cost of FN = %d", threshold, cost_of_fp, cost_of_fn)
  
  grid.arrange(p_roc, p_auc, p_cost, ncol=2,sub=textGrob(sub_title, gp=gpar(cex=1), just="bottom"))
}

# plot confusion matrix
plot_confusion_matrix <- function(verset, sSubtitle) {
  tst <- data.frame(round(verset$predicted,0), verset$Class)
  opts <-  c("Predicted", "True")
  names(tst) <- opts
  cf <- plyr::count(tst)
  cf[opts][cf[opts]==0] <- "Not Fraud"
  cf[opts][cf[opts]==1] <- "Fraud"
  
  ggplot(data =  cf, mapping = aes(x = True, y = Predicted)) +
    labs(title = "Confusion matrix", subtitle = sSubtitle) +
    geom_tile(aes(fill = freq), colour = "grey") +
    geom_text(aes(label = sprintf("%1.0f", freq)), vjust = 1) +
    scale_fill_gradient(low = "lightblue", high = "blue") +
    theme_bw() + theme(legend.position = "none")
}

raw.data = read_csv("data/creditcard.csv")

set.seed(2021)
idx = createDataPartition(raw.data$Class, p = 0.2, list = F)
raw.data = raw.data[idx, ]
table(raw.data$Class)

# ---- 상관관계 그래프 ----
# - 상관관계가 약한 이유는 사전에 이미 PCA로 적합이 이뤄졌기 때문임.
# - 이 때, 중요한 것은 Target 변수와 상관관계가 높은 것에 유의해서 본다. 
glimpse(raw.data)
correalation_df = cor(raw.data, method = "pearson")
corrplot(correalation_df, number.cex = .9, method = "circle", 
         type = "full", tl.cex = 0.8, tl.col = "black")

# ---- 데이터 분리 
set.seed(314)
nrows <- nrow(raw.data)
index = sample(1:nrow(raw.data), 0.7 * nrows)
trainset = raw.data[index, ]
testset = raw.data[-index, ]

table(trainset$Class)
table(testset$Class)


# ---- 모델링 ----
n = names(trainset) # column names
glimpse(trainset)
rf_form = as.formula(paste("Class ~", paste(n[!n %in% "Class"], collapse = " + ")))
rf_form

train_rf = randomForest(rf_form, trainset, ntree = 100, importance = T)

# ---- Feature Importance
# 연속 변수 시, MSE & Node Purity
# 명목 변수 시, mean descrease in accuracy & mean decrease in Gini index
# Node Purity가 높다는 뜻은 분류가 가장 잘 되는 뜻

variance_imp = data.frame(train_rf$importance)
ggplot(variance_imp, 
       aes(x = reorder(rownames(variance_imp), IncNodePurity)
           , y = IncNodePurity)) + 
  geom_bar(stat = "identity", fill = "lightblue") + 
  coord_flip() + 
  theme_minimal()

# ---- 예측 ----
testset$predicted = predict(train_rf, testset)
plot_confusion_matrix(testset, "Random Forest with 100 trees")

# ---- roc_auc 그래프 ----
roc = calculate_roc(testset, 1, 10, n = 100)
roc

plot_roc(roc, threshold = 0.2, 1, 10)
