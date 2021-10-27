# Convert from IPYNB to RMD
FILE_PATH = "./in-r-gbm-vs-xgboost-vs-lightgbm.ipynb"
file_nb_rmd = rmarkdown:::convert_ipynb(FILE_PATH)
st_nb_rmd = xfun::file_string(file_nb_rmd)

# Save RMD
fileConn <- file(FILE_PATH)
writeLines(st_nb_rmd, fileConn)
close(fileConn)
