library(shiny)
library(shinydashboard)
library(tidyverse)


dashboardPage(
  dashboardHeader(title = "Loan Applicant App"),
  
  dashboardSidebar(
    menuItem(
      "Loan Applicant Result",
      tabName = "Loan Satus Tab",
      icon = icon("snowflake")
    )
  ),
  dashboardBody(
    tabItem(
      tabName = "temp",
      box(valueBoxOutput("loan_status_prediction")),
      box(selectInput("v_sex", label = "Gender",
                      choices = c("Female", "Male"))),
      box(selectInput("v_married", label = "Married",
                      choices = c("No", "Yes"))),
      box(selectInput("v_credit", label = "Credit History",
                      choices = c("0", "1"))),
      box(sliderInput("v_applicant_income", label = "Applicant Income ($)",
                      min = 150, max = 81000, value = 3000))
    )
  )
)

