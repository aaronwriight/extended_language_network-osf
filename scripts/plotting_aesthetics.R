# plotting_aesthetics

library(stringr)
library(tidyverse)

fontsize <- 8

cols_fill <- c("sentences" = "firebrick2",
              "nonwords" = "rosybrown1",
              "S-N" = "firebrick2",
              "intact speech" = "firebrick4",
              "degraded speech" = "rosybrown3",
              "I-D" = "firebrick4",
              "hard vWM" = "steelblue4",
              "easy vWM" = "lightskyblue2")

# # custom scale that wraps x-axis labels at 16 chars
scale_x_discrete_wrap <- function(name = waiver(), width = 16, ...) {
  ggplot2::scale_x_discrete(
    name   = name,   # axis title
    labels = function(x) stringr::str_wrap(x, width = width),
    ...
  )
}

my_theme_text <- theme(plot.title = element_text(hjust = 0.5, size = 20),
                      plot.subtitle = element_text(hjust = 0.5, size = 14),
                      axis.text.y = element_text(size = 18),
                      axis.title.y = element_text(size = 18),
                      axis.text.x = element_text(size = 18, vjust = 1, hjust = 1, color="grey20"),
                      axis.ticks = element_blank(),
                      axis.title.x = element_text(size = 18),
                      legend.text = element_text(size = 12),
                      legend.title = element_text(size = 14),
                      panel.background = element_rect(fill = "white", color = "black"),
                      panel.grid.major.y = element_line(color = "grey", linetype = "dashed", size = 0.7),
                      panel.grid.minor.y = element_line(color = "grey", linetype = "dashed"),
                      strip.background = element_rect(fill = "white", color = "black"),
                      strip.text = element_text(size = 18))

my_theme_text_smaller <- theme(plot.title = element_text(hjust = 0.5, size = fontsize*1.2),
                              plot.subtitle = element_text(hjust = 0.5, size = fontsize),
                              axis.text.y = element_text(size = fontsize),
                              axis.title.y = element_text(size = fontsize),
                              axis.text.x = element_text(size = fontsize, vjust = 1, hjust = 1, color="grey20"),
                              axis.ticks = element_blank(),
                              axis.title.x = element_text(size = fontsize),
                              legend.text = element_text(size = fontsize),
                              legend.title = element_text(size = fontsize),
                              panel.background = element_rect(fill = "white", color = "black"),
                              #panel.grid.major.y = element_line(color = "grey", linetype = "dashed", size = 0.7),
                              #panel.grid.minor.y = element_line(color = "grey", linetype = "dashed"),
                              strip.background = element_rect(fill = "white", color = "black"),
                              strip.text = element_text(size = fontsize))

my_theme_text_smaller_noborders <- theme(plot.title = element_text(hjust = 0.5, size = fontsize*1.2),
                              plot.subtitle = element_text(hjust = 0.5, size = fontsize),
                              axis.text.y = element_text(size = fontsize),
                              axis.title.y = element_text(size = fontsize),
                              axis.text.x = element_text(size = fontsize, vjust = 1, hjust = 1, color="grey20"),
                              axis.ticks = element_blank(),
                              axis.title.x = element_text(size = fontsize),
                              legend.text = element_text(size = fontsize),
                              legend.title = element_text(size = fontsize),
                              panel.background = element_blank(),
                              panel.grid.major.y = element_line(color = "grey", linetype = "dashed", size = 0.3),
                              #panel.grid.minor.y = element_line(color = "grey", linetype = "dashed"),
                              strip.background = element_blank(),
                              strip.text = element_text(size = fontsize))