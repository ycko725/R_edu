library(shiny)

# 
shinyUI(pageWithSidebar(
  
  # Application
  titlePanel("faithful", windowTitle = "faithful"),
  
  # Sidebar
  sidebarPanel(
    sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
  ),
  
  # plot
  mainPanel(
    plotOutput("distPlot", height=250)
  )
))
