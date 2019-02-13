library(shiny)
library(zeallot)
source("helpers.R")

shinyServer(function(input, output) {
  values <- reactiveValues()
  
  output$deploy_plot <- renderPlot({ plot_deployment() }, 
                                   height = 120)
  output$zoom_plot <- renderPlot({ plot_zoom(input$zoom_brush, values$dive_data) }, 
                                 height = 120)
  output$dive_plot <- renderPlotly({ 
    if (!is.null(input$dive_click)) {
      values$dive_click <- input$dive_click
    }
    c(dive_data = NULL, lunge_data = NULL, plot = NULL) %<-% plot_dive(values$dive_click)
    values$dive_data <- dive_data
    values$lunge_data <- lunge_data
    plot
  })
  output$lunge_plots <- renderPlot({ 
    which_lunge <- event_data("plotly_click", source = "dive")
    if (!is.null(which_lunge) && which_lunge$curveNumber == 1) {
      lunge_time <- values$lunge_data$datetime[which_lunge$pointNumber + 1]
      plot_lunge(lunge_time)
    }
  })
})
