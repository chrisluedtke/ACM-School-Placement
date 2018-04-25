# Packages required
packages <- c("knitr")

# If not installed, install them
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# Load packages quietly (no printed warnings)
lapply(packages, require, character.only = TRUE, quietly = TRUE)

source(purl("Placement Algorithm v1.2.Rmd", output = tempfile(), quiet=TRUE), echo=FALSE)