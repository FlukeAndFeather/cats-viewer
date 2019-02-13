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

plot_deployment <- function() {
  date_rng <- max(prh$datetime) - min(prh$datetime)
  offset <- 0.05
  date_breaks <- seq(min(prh$datetime) + offset * date_rng,
                     max(prh$datetime) - offset * date_rng,
                     length.out = 5)
  # Maximum 10,000 points
  prh %>%
    slice(seq(1, nrow(prh), length.out = 10e3)) %>%
    ggplot(aes(datetime, p)) +
    geom_line() +
    scale_x_datetime(breaks = date_breaks) +
    scale_y_reverse() +
    theme_classic() +
    theme(axis.title = element_blank())
}
