# rt-r-ggplot2-ruby-experiments
experimental code using ruby and r with ggplot2

## 05november2020 sample ggimage code

from the ggimage vignette, https://cran.r-project.org/web/packages/ggimage/ggimage.pdf

```R
library("ggplot2")
library("ggimage")
set.seed(2017-02-21)
d <- data.frame(x = rnorm(10),y = rnorm(10),
image = sample(c("https://www.r-project.org/logo/Rlogo.png",
"https://jeroenooms.github.io/images/frink.png"),size=10, replace = TRUE))
ggplot(d, aes(x, y)) + geom_image(aes(image=image))
```
## 02november2020 creating a SQLite database using cvss-to-squlite

```bash
csvs-to-sqlite 2020-10-20-2020-10-20-firefox-creator-answers-desktop-all-locales.csv \
-dt created -df "%Y-%m-%d %H:%M:%S %Z" \
-dt updated -df "%Y-%m-%d %H:%M:%S %Z" \
2020-10-20-2020-10-20-firefox-creator-answers-desktop-all-locales.db
```
## 01November2020 installing python 3.9 on ubuntu server 18.0.4 bionic beaver
* I need python to create sqlite from CSV files that will R scripts will generate graphics, there probably is a a ruby way to createk sqlite that I am unaware of :-)
```bash
sudo apt update
sudo apt list --upgradeable
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.9
sudo apt install virtualenv # probably don't need virtualenv
sudo apt-get install python3-pip
sudo apt install python3-venv
mkdir ~/PYTHON3.9; cd ~/PYTHON3.9
sudo apt-get install python3.9-dev python3.9-venv
python3.9 -m venv awesome_venv
source awesome_venv/bin/activate
python -v
```
