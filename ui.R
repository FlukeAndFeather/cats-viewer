#
# CATS Viewer. For interactive visualization of whale movement behavior
# from CATS tags.
#

library(shiny)
library(plotly)

fillPage(
  fillRow(plotOutput("deploy_plot",
                     brush = "zoom_brush"),
          height = "15%"),
  fillRow(plotOutput("zoom_plot",
                     click = "dive_click"),
          height = "15%"),
  fillRow(plotlyOutput("dive_plot",
                       height = "100%"),
          plotOutput("lunge_plots"),
          flex = c(4, 3),
          height = "70%")
)
