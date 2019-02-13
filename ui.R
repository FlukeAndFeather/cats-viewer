#
# CATS Viewer. For interactive visualization of whale movement behavior
# from CATS tags.
#

library(shiny)

fillPage(
  fillRow(imageOutput("image1", height = "100px"),
          height = "15%"),
  fillRow(imageOutput("image2", height = "100px"),
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
