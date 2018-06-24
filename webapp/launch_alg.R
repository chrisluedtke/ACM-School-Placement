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

## Commented out for Demo
# source(purl("Commutes.Rmd", output = tempfile(), quiet=TRUE), echo=FALSE)

# #source(purl("test.Rmd", output = tempfile()), echo=FALSE)
# source(purl("Placement Algorithm v1.2.Rmd", output = tempfile(), quiet=TRUE), echo=FALSE)

## Added for Demo
#output_path <- 'media/documents/outputs/' 
#write.table(dataset, file = paste0(output_path, "Output_Placements.csv"), sep=",", row.names=FALSE, na = "")