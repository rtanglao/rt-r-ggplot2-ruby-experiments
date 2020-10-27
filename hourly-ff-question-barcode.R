#!/usr/bin/env Rscript
library(tidyverse)
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
stop()
main <- function() {
  csv <-read.csv(
      "https://raw.githubusercontent.com/rtanglao/rt-kits-api3/main/2020/2020-10-20-2020-10-20-firefox-creator-answers-desktop-all-locales.csv"
  )
  # see https://stackoverflow.com/questions/39975317/how-to-reverse-the-order-of-a-dataframe-in-r
  reverse_csv <- csv %>% map_df(rev)
  length <- nrow(reverse_csv)
  xintercept <- seq.int(by = 10,
                        length = length * 2,
                        from = 0)
  size <- rep(c(4, 2), length = length * 2)
  os_colours_vector <- map_chr(reverse_csv$tags, getOSColour)
  question_colours_vector <- map2_chr(reverse_csv$title,
                                      reverse_csv$content,
                                      ~ {
                                        colours_array[(abs(digest::digest2int(paste(.x, .y))) %% 657) + 1]
                                      })
  colours_vector <-
    c(rbind(os_colours_vector, question_colours_vector))
  p <- ggplot() + theme_void()
  p <- p + geom_vline(col = colours_vector,
                      xintercept = xintercept,
                      size = size)
}

sink("log.txt")

main()

sink()
