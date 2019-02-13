library(tidyverse)
library(RcppRoll)
library(lubridate)

# Load data
prh <- read_csv("data/bw170813-44/bw170813-44 10Hzprh.csv") %>%
  mutate(speed = RcppRoll::roll_mean(speed, n = 30, fill = NA),
         Gy = RcppRoll::roll_mean(Gy, n = 15, fill = NA),
         pitch = pitch * 180/pi,
         roll = roll * 180/pi)
lungetable <- read_csv("data/bw170813-44/bw170813-44LungeTable.csv")

plot_profile <- function(begin, end) {
  # Maximum 10,000 points
  data <- prh %>%
    filter(between(datetime, begin, end)) %>%
    slice(seq(1, nrow(prh), length.out = 10e3))
  
  date_rng <- max(data$datetime) - min(data$datetime)
  offset <- 0.05
  date_breaks <- seq(min(data$datetime) + offset * date_rng,
                     max(data$datetime) - offset * date_rng,
                     length.out = 5)
  
  ggplot(data, aes(datetime, p)) +
    geom_line() +
    scale_x_datetime(breaks = date_breaks) +
    scale_y_reverse() +
    theme_classic() +
    theme(axis.title = element_blank())
}

plot_deployment <- function() {
  plot_profile(min(prh$datetime), max(prh$datetime))
}

plot_zoom <- function(box) {
  if (is.null(box)) {
    NULL
  } else {
    plot_profile(box$xmin, box$xmax)
  }
}
