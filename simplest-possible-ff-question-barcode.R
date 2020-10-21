library(tidyverse)
csv <- read.csv("https://raw.githubusercontent.com/rtanglao/rt-kits-api3/main/2020/2020-10-20-2020-10-20-firefox-creator-answers-desktop-all-locales.csv")
xintercept <- -10.0

# see https://stackoverflow.com/questions/39975317/how-to-reverse-the-order-of-a-dataframe-in-r
reverse_csv <- csv %>% map_df(rev)

p <- ggplot() + theme_void()
macos_str <- "mac-os|os-x|osx|macos"
windows_str <- "windows-7|windows-8|windows-10"
linux_str <- "linux|ubuntu|redhat|debian"
colours_array <- colours()

for (row in 1:nrow(reverse_csv)) {
  tags <- reverse_csv[row, "tags"]
  title_plus_content  <- paste(
    reverse_csv[row, "title"],
    reverse_csv[row, "content"])

  print(paste("Title:", title_plus_content, 
                " tags:", tags))
  xintercept <- xintercept + 10.0
  # set os_colour_of_bar to pink if windows, blue if macOS, green if linux, purple if unknown OS
  os_colour_bar <- "purple"
  if(str_detect(tags, macos_str)) os_colour_bar <- "blue"
  if(str_detect(tags, linux_str)) os_colour_bar <- "green"
  if(str_detect(tags, windows_str)) os_colour_bar <- "hotpink"
    
  p <- p + geom_vline(col=os_colour_bar, xintercept=xintercept, size=4)
  xintercept <- xintercept + 10.0
  colour_of_bar <- abs(digest::digest2int(title_plus_content)) %% 657 # 657 colors in r
  p <- p + geom_vline(col=colours_array[colour_of_bar + 1], 
                     xintercept = xintercept, size = 2)
}
