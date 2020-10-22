library(tidyverse)
colours_array <- colours()

getOSColour <- function(.x) { 
  os_colour <- "purple"
  macos_str <- "mac-os|os-x|osx|macos"
  windows_str <- "windows-7|windows-8|windows-10"
  linux_str <- "linux|ubuntu|redhat|debian"
  if(str_detect(.x, macos_str)) os_colour <- "blue"
  if(str_detect(.x, linux_str)) os_colour <- "green"
  if(str_detect(.x, windows_str)) os_colour <- "hotpink"
  return(os_colour)
}
getQuestionColour <- function(.x) {
  question_colour <- abs(
    digest::digest2int(.x)) %% 657 # 657 colors in r
  return(c(colours_array[question_colour + 1]))
}
csv <- read.csv("https://raw.githubusercontent.com/rtanglao/rt-kits-api3/main/2020/2020-10-20-2020-10-20-firefox-creator-answers-desktop-all-locales.csv")

# see https://stackoverflow.com/questions/39975317/how-to-reverse-the-order-of-a-dataframe-in-r
reverse_csv <- csv %>% map_df(rev)
length <- nrow(reverse_csv)
xintercept <- seq.int(by = 10, length = length * 2, from = 0)
size <- rep(c(4,2), length = length * 2)
reverse_csv_with_title_plus_content <- reverse_csv %>% 
  mutate(tplusc = paste(title, content))
os_colours_vector <- map_chr(reverse_csv$tags, getOSColour)
question_colour_vector <- map_chr(reverse_csv_with_title_plus_content$tplusc, 
                            getQuestionColour)
colours_vector <- c(rbind(os_colours_vector, question_colour_vector))
p <- ggplot() + theme_void()
p <- p + geom_vline(col = colours_vector, 
                    xintercept = xintercept, size = size)
