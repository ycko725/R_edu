library(shiny)
library(shinythemes)
library(readr)
library(ggplot2)
library(stringr)
library(dplyr)
library(DT)
library(tools)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application Title
  titlePanel("Movie browser, 1970 - 2014", windowTitle = "Movies"),
  
  # Application title
  # headerPanel("It's Alive!"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot", height=250)
  )
))
