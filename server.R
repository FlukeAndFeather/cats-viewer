library(shiny)

shinyServer(function(input, output) {
  output$image1 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image2 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image3 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image4 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image5 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image6 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
  output$image7 <- renderImage(list(src = "img/placeholder.png"), deleteFile = FALSE)
})