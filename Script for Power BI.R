rm(list=ls(all=TRUE))
# Initialize
dataset <- data.frame(FP = 1)

# Data Source Parameters
dataset$FP[1] <-"C:/Users/CLuedtke/ACM-School-Placement/data/CHI/"
dataset$used_surveygizmo[1] <- "No"

# Algorithm Settings
dataset$number_iterations[1] <- 100
dataset$ij[1] <- "Do nothing with IJ Teams."

# Set Firm Constraints
dataset$prevent_roommates[1] <-"Yes"
dataset$consider_HS_elig[1] <- "No"

# Set Soft  Constraints
dataset$consider_commutes[1] <- "Yes"
dataset$commute_factor = 1

dataset$ethnicity_factor = 0
dataset$gender_factor = 0
dataset$age_factor = 0

dataset$Edscore_factor = 0
dataset$Tutoring_factor = 0
dataset$Spanish_factor = 0
dataset$Math_factor = 0
dataset$preserve_ij_factor = 0


#####
library(knitr)

path_elements <- strsplit(toString(dataset$FP[1]), "/")[[1]]
alg_path_elements <- path_elements[-c(length(path_elements)-1, length(path_elements))]
alg_path <- paste(alg_path_elements, collapse="/")

source(purl(paste0(alg_path, "/Placement Algorithm v1.2.Rmd"), output = tempfile()))
