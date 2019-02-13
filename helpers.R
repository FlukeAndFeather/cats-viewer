library(tidyverse)
library(RcppRoll)
library(lubridate)
library(patchwork)

# Load data
prh <- read_csv("data/bw170813-44/bw170813-44 10Hzprh.csv") %>%
  mutate(speed = RcppRoll::roll_mean(speed, n = 30, fill = NA),
         Gy = RcppRoll::roll_mean(Gy, n = 15, fill = NA),
         pitch = pitch * 180/pi,
         roll = roll * 180/pi)
lungetable <- read_csv("data/bw170813-44/bw170813-44LungeTable.csv")

# Dive threshold is half body length
body_len <- 22.59
dive_thr <- body_len / 2
surf_thr <- 5

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

plot_zoom <- function(box, dive_data) {
  if (is.null(box)) {
    return(NULL)
  } else {
    p <- plot_profile(box$xmin, box$xmax)
  }
  
  if (!is.null(dive_data)) {
    p <- p + annotate("rect",
                      xmin = first(dive_data$datetime),
                      xmax = last(dive_data$datetime),
                      ymin = min(dive_data$p),
                      ymax = max(dive_data$p),
                      alpha = 0.25)
  }
  
  p
}

plot_dive <- function(point) {
  if (is.null(point)) {
    return(list(NULL, NULL, NULL))
  }
  
  x_idx <- which.min(abs(as.numeric(prh$datetime - point$x)))
  if (prh$p[x_idx] < dive_thr) {
    return(list(NULL, NULL, NULL))
  } else {
    dive_begin <- prh %>%
      slice(1:x_idx) %>% 
      filter(p < surf_thr) %>%
      tail(1) %>% 
      `$`(datetime)
    dive_end <- prh %>%
      slice(x_idx:nrow(prh)) %>% 
      filter(p < surf_thr) %>%
      head(1) %>% 
      `$`(datetime)
    
    dive_data <- prh %>% 
      filter(between(datetime, dive_begin, dive_end))
    lunge_data <- lungetable %>% 
      filter(between(datetime, dive_begin, dive_end)) %>%
      left_join(dive_data, by = "datetime")
    
    list(dive_data = dive_data,
         lunge_data = lunge_data,
         plot = plot_ly(dive_data, 
                        x = ~x, y = ~y, z = ~-p,
                        source = "dive") %>% 
           add_paths() %>%
           add_trace(data = lunge_data,
                     mode = "markers"))
  }
}

plot_lunge <- function(lunge_time) {
  plot_start <- lunge_time - minutes(1)
  plot_end <- lunge_time + minutes(2)
  plot_data_prh <- prh %>%
    filter(between(datetime, plot_start, plot_end)) %>%
    mutate(secs_since = as.numeric(difftime(datetime, lunge_time, units = "secs")))
  find_nearest0 <- approxfun(plot_data_prh$secs_since - 0.05,
                             plot_data_prh$secs_since - 0.05,
                             method = "constant")
  find_nearest <- function(x) find_nearest0(x) + 0.05
  plot_data_lunge <- with(lungetable[1,], tibble(Lunge = 0,
                                                 Purge1 = purge1,
                                                 Purge2 = purge2, 
                                                 Purge3 = purge3)) %>%
    gather(event, secs_since, Lunge:Purge3) %>%
    mutate(secs_since = find_nearest(secs_since)) %>%
    left_join(plot_data_prh, by = "secs_since")
  
  plot_theme_last <- theme_classic() +
    theme(axis.ticks.x = element_blank())
  
  plot_theme <- plot_theme_last +
    theme(axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.line = element_line(size = 0.2))
  
  # depth ~ time
  label_data <- plot_data_lunge %>% 
    mutate(secs_since = secs_since + 2,
           p = min(plot_data_prh$p - 8))
  p1 <- ggplot(mapping = aes(secs_since, p)) +
    geom_line(data = plot_data_prh) +
    scale_y_reverse() +
    plot_theme +
    labs(y = "Depth (m)") 
  # speed ~ time
  p2 <- ggplot(mapping = aes(secs_since, speed)) +
    geom_line(data = plot_data_prh) +
    plot_theme +
    labs(y = "Speed (m/s)") 
  # pitch, roll ~ time
  # rescale roll limits (-120, 120) to pitch limits (-90, 90)
  pr_data <- plot_data_prh %>% 
    rename(Pitch = pitch, Roll = roll) %>%
    gather(orientation, value, Pitch:Roll)
  roll_axis <- sec_axis(~ . * 120 / 90,
                        name = expression("Roll " ( degree )),
                        breaks = seq(-120, 120, by = 60))
  p3 <- ggplot(mapping = aes(secs_since)) +
    geom_hline(yintercept = 0,
               size = 0.2) +
    # pitch on primary, roll on secondary
    geom_line(aes(y = value, color = orientation),
              pr_data) +
    scale_y_continuous(limits = c(-90, 90),
                       breaks = seq(-90, 90, by = 45),
                       sec.axis = roll_axis) +
    scale_color_manual(values = c("red", "blue")) +
    plot_theme +
    theme(axis.line.x = element_blank(),
          # Color-code y-axes
          axis.text.y.left = element_text(color = "red"),
          axis.line.y.left = element_line(color = "red"),
          axis.title.y.left = element_text(color = "red"),
          axis.text.y.right = element_text(color = "blue"),
          axis.line.y.right = element_line(color = "blue"),
          axis.title.y.right = element_text(color = "blue"),
          legend.position = "none") +
    labs(y = expression("Pitch (" ( degree ))) 
  # gyro_y ~ time
  p4 <- ggplot(mapping = aes(secs_since, Gy)) +
    geom_hline(yintercept = 0,
               size = 0.2) +
    geom_line(data = plot_data_prh) +
    scale_x_continuous(breaks = seq(-60, 240, by = 60)) +
    plot_theme_last +
    theme(axis.line.x = element_blank()) +
    labs(x = "Seconds since lunge",
         y = "Gyro-Y (rad/s)")
  
  p1 + p2 + p3 + p4 + plot_layout(ncol = 1, heights = c(1, 1, 2, 2))
}


