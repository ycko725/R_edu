# Chapter 1. INSTALL RSCONNECT
# install.packages('rsconnect')
library(rsconnect)

# Chapter 2. AUTHORIZE ACCOUNT
rsconnect::setAccountInfo(name='jihoonjung85',
                          token='4DF7877205F365C47323E241C575EDAC',
                          secret='29VQ6p7llDuDj5tgMX6owWDo0kO3yiGO/Y/hRVTi')

# Chapter 3. Deploy App
library(shiny)
runApp()

# Chapter 4. Update App
library(rsconnect)
deployApp()
