#!/usr/bin/env Rscript
library(tidyverse)
library(tibbletime)
library(lubridate)
library(DBI)
library(RSQLite)

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
  base_name <- 
   sprintf("%4.4d-%2.2d-%2.2d-%4.4d-%2.2d-%2.2d-firefox-creator-answers-desktop-all-locales",
    year, month, day, year, month, day)
  db_filename <- sprintf("%s.db", base_name)
  date_str <- sprintf(
    "%4.4d-%2.2d-%2.2d %2.2d",year, month, day, hour)

  ffquestionsdb <- dbConnect(RSQLite::SQLite(), db_filename)  
  query_str <- sprintf(
    "select * from \"%s\" where (datetime(created) >= datetime(\"%s:00:00\") AND
    datetime(created) <= datetime(\"%s:59:59\"));",
    base_name, date_str, date_str
  )
  sqlitedf <- dbGetQuery(ffquestionsdb, query_str)
  reverse_df <- sqlitedf %>% map_df(rev)
  length = nrow(reverse_df)
  options(tibble.width = Inf)
  print(reverse_df)
  xintercept <- seq.int(by = 10,
                        length = length * 2,
                        from = 0)
  size <- rep(c(4, 2), length = length * 2)
  os_colours_vector <- map_chr(reverse_df$tags, getOSColour)
  question_colours_vector <- map2_chr(reverse_df$title,
                                      reverse_df$content,
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
    "hour-%2.2d-%s.png",
    hour, base_name)
  ggsave(png_filename, p, width = 3.555555556, height = 3.555555556, 
         dpi = 72, limitsize = FALSE) # 3.555555556 = 256/72dpi
  warnings()
}

sink("log.txt")
main()
sink()
