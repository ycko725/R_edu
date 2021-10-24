library(remotes)
install_github("junhewk/RcppMeCab", force = TRUE)

library(RcppMeCab)

# 테스트
text = "안녕하세요!"
pos(sentence = text)
# $`�ȳ\xe7\xc7ϼ��\xe4!`
# [1] "�/SY"           "ȳ/SL"            "\xe7\xc7\xcf/SH" "���\xe4/SY"  
# [5] "!/SF" 
text2 = enc2utf8(text)

pos(sentence = text2)
# $`안녕하세요!`
# [1] "안녕/NNG"   "하/XSV"     "세요/EP+EF" "!/SF"