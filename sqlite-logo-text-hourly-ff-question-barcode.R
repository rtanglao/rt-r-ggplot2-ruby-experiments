#!/usr/bin/env Rscript
library(tidyverse)
library(DBI)
library(RSQLite)
library(rvest)
library(stopwords)
library(tokenizers)
library(ggimage)
library(lubridate)

set.seed(888)

getOSColour <- function(.x) {
  case_when(
    str_detect(.x, "mac-os|os-x|osx|macos") ~ "blue",
    str_detect(.x, "linux|ubuntu|redhat|debian") ~ "green",
    str_detect(.x, "windows-7|windows-8|windows-10") ~ "hotpink",
    TRUE ~ "purple"
  )
}

getLogo <- function(.x) {
  case_when(
    str_detect(.x, "mac-os|os-x|osx|macos") ~ "LOGOS/macos-logo.png",
    str_detect(.x, "linux|ubuntu|redhat|debian") ~ "LOGOS/linux-logo.png",
    str_detect(.x, "windows-7|windows-8|windows-10") ~ "LOGOS/windows-logo.png",
    TRUE ~ "LOGOS/purple-logo.png"
  )
}

getRandomQuestionText <- function(.x, .y) {
  # pick 5 random tokens
  tplusc <- paste(.x, html_text(read_html(.y)))
  print(tplusc)
  tplusc_tokens <-
    unlist(tokenize_words(tplusc, stopwords = stopwords::stopwords("en")))
  print(tplusc_tokens)
  token_length <- length(tplusc_tokens)
  num_tokens <- if (token_length >= 5) 5 else token_length
  
  index <- sort(sample(1:length(tplusc_tokens), num_tokens))
  print(index)
  
  tokenstring = paste(tplusc_tokens[index[1]],
                      tplusc_tokens[index[2]],
                      tplusc_tokens[index[3]],
                      tplusc_tokens[index[4]],
                      tplusc_tokens[index[5]])
  print(tokenstring)
  paste0("bold(\"", tokenstring, "\")")
}

initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <-
  sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
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
  cat("
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
    sprintf(
      "%4.4d-%2.2d-%2.2d-%4.4d-%2.2d-%2.2d-firefox-creator-answers-desktop-all-locales",
      year,
      month,
      day,
      year,
      month,
      day
    )
  db_filename <- sprintf("%s.db", base_name)
  date_str <- sprintf("%4.4d-%2.2d-%2.2d %2.2d", year, month, day, hour)
  
  ffquestionsdb <- dbConnect(RSQLite::SQLite(), db_filename)
  query_str <- sprintf(
    "select * from \"%s\" where (datetime(created) >= datetime(\"%s:00:00\") AND
    datetime(created) <= datetime(\"%s:59:59\"));",
    base_name,
    date_str,
    date_str
  )
  sqlitedf <- dbGetQuery(ffquestionsdb, query_str)
  reverse_df <- sqlitedf %>% map_df(rev)
  length = nrow(reverse_df)
  image_df <- reverse_df %>%
    mutate(x = minute(parse_date_time(created, "YmdhMSz"))) %>%
    mutate(icon = getLogo(tags))
  
  image_df$y <- seq.int(by = 5,
                        length = length,
                        from = 0)
  
  options(tibble.width = Inf)
  
  os_colours_vector <- map_chr(reverse_df$tags, getOSColour)
  question_text <- map2_chr(reverse_df$title,
                            reverse_df$content,
                            getRandomQuestionText)
  print(question_text)
  print(image_df)
  
  p <- ggplot(image_df, aes(x, y)) + geom_image(aes(image = icon)) + 
    theme_void() + xlim(0, 60) + ylim(0, 60)

  p <- p + annotate(
    "text",
    label = question_text,
    x = 20,
    y = image_df$y + 1.75,
    color = os_colours_vector,
    parse = TRUE,
    hjust = 0
  )
  png_filename <- sprintf("logo-text-hour-%2.2d-%s.png",
                          hour, base_name)
  ggsave(
    png_filename,
    p,
    width = 14.2222222222,
    height = 14.2222222222,
    dpi = 72,
    limitsize = FALSE
  ) # 14.2222222222 = 1024/72dpi
  warnings()
}

sink("log.txt")
main()
sink()
