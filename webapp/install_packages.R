# Packages required
packages <- c("readxl", "dplyr", "tidyr", "data.table")

# If not installed, install them
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())), repos = "http://cran.us.r-project.org")
}