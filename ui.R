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
  fillRow(fillCol(plotlyOutput("dive_plot",
                               height = "100%")),
          fillCol(imageOutput("image4"),
                  imageOutput("image5"),
                  imageOutput("image6"),
                  imageOutput("image7"),
                  flex = 1),
          flex = c(4, 3),
          height = "70%")
)
