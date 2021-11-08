# Load libraries, data ------------------------------------------------
library(ggplot2)
library(readr)

loan_data <- read.csv("data/train_ctrUa4K.csv")
loan_data$Credit_History <- as.character(loan_data$Credit_History)
server <- function(input, output) {
  # 서버와 연결
  output$plot <- renderPlot({
    # one categorical ~ one numerical barplot
    y_feature = input$y_var
    x_feature = input$x_var
    num_cols = loan_data %>% select_if(is.numeric) %>% colnames()
    char_cols = loan_data %>% select_if(is.character) %>% colnames()
    
    if (y_feature %in% num_cols & x_feature %in% char_cols) {
      ggplot(data = loan_data, aes_string(x = input$x_var, y = input$y_var, fill = "Loan_Status")) + 
        geom_bar(stat="identity", position = position_dodge()) +
        labs(x=input$x_var, y=input$y_var) + 
        labs(title = paste0("Graph Selected Variable - ", y_feature)) +
        theme_minimal() 
    } else if (y_feature %in% num_cols & x_feature %in% num_cols) {
      ggplot(data = loan_data, aes_string(x = input$x_var, y = input$y_var, colour = "Loan_Status")) + 
        geom_point(size = 2, alpha = 0.7) +
        labs(x=input$x_var, y=input$y_var) + 
        labs(title = paste0("Graph Selected Variable - ", x_feature, y_feature)) +
        theme_minimal() 
    } else {
      print("empty")
    }
      
  })
}
