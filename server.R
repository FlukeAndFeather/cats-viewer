library(shiny)
source("helpers.R")

shinyServer(function(input, output) {
  output$deploy_plot <- renderPlot({ plot_deployment() }, height = 120)
  output$zoom_plot <- renderPlot({ plot_zoom(input$zoom_brush) }, height = 120)
  output$image2 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image3 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image4 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image5 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image6 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image7 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
})
