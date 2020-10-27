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

## Default setting when no arguments passed
if (length(args) < 4) {
  args <- c("--help")
} else {
  hour = as.integer(args[4])
  if (hour < 0 || hour > 23) {
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
  filename <-
    paste0(
      args[1], "-",
      args[2], "-",
      args[3], "-",
      args[1], "-",
      args[2], "-",
      args[3],
      "-firefox-creator-answers-desktop-all-locales.csv"
    )
  csv <- read_csv(filename)
  # see https://stackoverflow.com/questions/39975317/how-to-reverse-the-order-of-a-dataframe-in-r
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
  png_filename <-   paste0("hour-", args[4], "-", args[1], "-", args[2], "-", 
                           args[3], "-ff-desktop-hourly.png")
  ggsave(png_filename, p, width = 26.666666667, height = 26.666666667, 
         dpi = 72, limitsize = FALSE) # 26.6666667 = 1920/72dpi
  warnings()

}

sink("log.txt")

main()

sink()
