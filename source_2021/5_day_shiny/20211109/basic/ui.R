# data
library(readr)
loan_data <- read_csv("data/train_ctrUa4K.csv") 

# Page 1 - Introduction
intro_panel <- tabPanel(
  "Introduction", 
  titlePanel("Loan Data"), 
  p("page 1"), 
  p(a(href = "https://datahack.analyticsvidhya.com/contest/practice-problem-loan-prediction-iii/#ProblemStatement", "Data Source"))
)

# Page 2 - Visualization
select_vals = colnames(loan_data)
select_vals = select_vals[!select_vals %in% c("Loan_ID")]

sidebar_content = sidebarPanel(
  selectInput(
    "y_var", 
    label   = "Y-Variable", 
    choices = select_vals, 
    selected = "Gender"
  ), 
  selectInput(
    "x_var", 
    label   = "X-Variable", 
    choices = select_vals, 
    selected = "Gender"
  )
)

main_content <- mainPanel(
  # server와 연결
  plotOutput("plot")
)

second_panel <- tabPanel(
  "데이터 시각화", 
  titlePanel("Title"), 
  p("시각화를 위한 변수 선택"), 
  sidebarLayout(
    sidebar_content, main_content
  )
)

# user interface
ui <- navbarPage(
  "App", 
  intro_panel, 
  second_panel
)