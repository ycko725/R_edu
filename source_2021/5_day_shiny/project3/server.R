library(shiny)
library(shinydashboard)
library(tidymodels)
library(tidyverse)

load("model/loan_model.RData")

function(input, output) {
  
  output$loan_status_prediction <- renderValueBox({

    prediction <- predict(
      final_boosted_model,
      tibble("Gender" = input$v_sex,
             "Married" = input$v_married,
             "Credit_History" = input$v_credit,
             "Applicant_Income" = input$v_applicant_income)
      )
    
    prediction_prob <- predict(
      final_boosted_model,
      tibble("Gender" = input$v_sex,
             "Married" = input$v_married,
             "Credit_History" = input$v_credit,
             "Applicant_Income" = input$v_applicant_income),
      type = "prob"
    ) %>% 
      gather() %>% 
      arrange(desc(value)) %>% 
      dplyr::slice(1) %>% 
      select(value)
    
    prediction_color <- if_else(prediction$.pred_class == "N", "red", "blue")
    
    valueBox(
      value = paste0(round(100*prediction_prob$value, 0), "%"),
      subtitle = paste0("Result: ", prediction$.pred_class),
      color = prediction_color,
      icon = icon("snowflake")
    )
    
    })
  
  
}
