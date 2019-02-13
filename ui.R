#
# CATS Viewer. For interactive visualization of whale movement behavior
# from CATS tags.
#

library(shiny)

fillPage(
  fillRow(plotOutput("deploy_plot",
                     brush = "zoom_brush"),
          height = "15%"),
  fillRow(plotOutput("zoom_plot"),
          height = "15%"),
  fillRow(fillCol(imageOutput("image3")),
          fillCol(imageOutput("image4"),
                  imageOutput("image5"),
                  imageOutput("image6"),
                  imageOutput("image7"),
                  flex = 1),
          flex = c(4, 3),
          height = "70%")
)
