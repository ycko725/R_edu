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
    label   = "Y Variable", 
    choices = select_vals, 
    selected = "Speed"
  )
)

main_content <- mainPanel(
  plotOutput("plot")
)

second_panel <- tabPanel(
  "Visualization", 
  titlePanel("What"), 
  p("Use the selector input"), 
  sidebarLayout(
    sidebar_content, main_content
  )
)

# user interface
ui <- navbarPage(
  "Data", 
  intro_panel, 
  second_panel
)