#!/usr/bin/env Rscript
library(tidyverse)
library(tibbletime)
library(lubridate)

colours_array <- colours()

getOSColour <- function(.x) { 
  case_when(
    str_detect(.x, "mac-os|os-x|osx|macos") ~ "blue",
    str_detect(.x, "linux|ubuntu|redhat|debian") ~ "green",
    str_detect(.x, "windows-7|windows-8|windows-10") ~ "hotpink",
    TRUE ~ "purple")
}

initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
script.basename <- dirname(script.name)

args <- commandArgs(TRUE)
year = as.integer(args[1])
month = as.integer(args[2])
day = as.integer(args[3])
hour = as.integer(args[4])

## Default setting when no arguments passed
if (length(args) < 4) {
  args <- c("--help")
} else {
  if (hour < 0 || hour > 23 || 
      year < 2010 || 
      month < 0 || month > 12) {
    args <- c("--help")
  }
}
                  
if ("--help" %in% args) {
  cat(
    "
    Arguments:
    year
    month
    day
    hour (0-23)
    --help              - print this text
    Example:")
    cat(paste("Rscript", script.name, "2020 10 20 23\n\n"))
  q(save = "no")
}
print(script.name)

main <- function() {
  filename <- sprintf(
  "%4.4d-%2.2d-%2.2d-%4.4d-%2.2d-%2.2d-firefox-creator-answers-desktop-all-locales.csv",
  year, month, day, year, month, day)

  csv <- read_csv(filename)
  # data frame needs to be in ascending order instead of descending
  reverse_csv <- csv %>% map_df(rev)
  csv_time <- reverse_csv %>%
    mutate(created_time = parse_date_time(created, orders = "ymdHMSz"))
  csv_tt <- as_tbl_time(csv_time, index = created_time)
  time_filter_str <- paste0(args[1], "-", args[2], "-", args[3], " ", args[4])
  hourly_csv <- csv_tt %>%
    filter_time(time_filter_str ~ time_filter_str)

  length <- nrow(hourly_csv)
  options(tibble.width = Inf)
  print(hourly_csv)
  xintercept <- seq.int(by = 10,
                        length = length * 2,
                        from = 0)
  size <- rep(c(4, 2), length = length * 2)
  os_colours_vector <- map_chr(hourly_csv$tags, getOSColour)
  question_colours_vector <- map2_chr(hourly_csv$title,
                                      hourly_csv$content,
                                      ~ {
                                        colours_array[(abs(digest::digest2int(paste(.x, .y))) %% 657) + 1]
                                      })
  colours_vector <-
    c(rbind(os_colours_vector, question_colours_vector))
  p <- ggplot() + theme_void()
  p <- p + geom_vline(col = colours_vector,
                      xintercept = xintercept,
                      size = size)
  png_filename <- sprintf(
    "hour-%2.2d-%4.4d-%2.2d-%2.2d-firefox-desktop-all-locales.png",
    hour, year, month, day, year, month, day)
  ggsave(png_filename, p, width = 3.555555556, height = 3.555555556, 
         dpi = 72, limitsize = FALSE) # 3.555555556 = 256/72dpi
  warnings()

}

sink("log.txt")
main()
sink()
