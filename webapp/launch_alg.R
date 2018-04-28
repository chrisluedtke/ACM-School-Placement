# Packages required
packages <- c("knitr")

# If not installed, install them
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# Load packages quietly (no printed warnings)
lapply(packages, require, character.only = TRUE, quietly = TRUE)

dataset <- read.csv('media/documents/params.csv', stringsAsFactors=FALSE)
dataset$calc_commutes <- as.logical(dataset$calc_commutes)

if(dataset$calc_commutes == TRUE){
  source(purl("Commutes_for_PowerBI.Rmd", output = tempfile(), quiet=TRUE), echo=FALSE)
}

#source(purl("test.Rmd", output = tempfile()), echo=FALSE)
source(purl("Placement Algorithm v1.2.Rmd", output = tempfile(), quiet=TRUE), echo=FALSE)