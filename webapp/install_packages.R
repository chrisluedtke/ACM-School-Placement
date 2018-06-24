# Packages required
packages <- c("readxl", "dplyr", "tidyr", "data.table", "XML", "RCurl")

# If not installed, install them
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())), repos = "http://cran.us.r-project.org")
}