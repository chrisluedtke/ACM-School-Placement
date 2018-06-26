start.time <- Sys.time()
# Load packages with no printed warnings or errors
#suppressWarnings(suppressMessages(library("knitr")))
suppressWarnings(suppressMessages(library("data.table")))
suppressWarnings(suppressMessages(library("dplyr")))
suppressWarnings(suppressMessages(library("readxl")))
suppressWarnings(suppressMessages(library("tidyr")))
suppressWarnings(suppressMessages(library("XML")))
suppressWarnings(suppressMessages(library("RCurl")))

# Load Parameters
dataset <- read.csv('media/documents/params.csv', stringsAsFactors=FALSE)
dataset$acm_input_path <- 'media/documents/ACM_Placement_Survey_Data.csv'
dataset$sch_input_path <- 'media/documents/ACM_Placement_School_Data.xlsx'
dataset$prevent_roommates <- as.logical(dataset$prevent_roommates)
dataset$consider_HS_elig <- as.logical(dataset$consider_HS_elig)
dataset$used_surveygizmo <- as.logical(dataset$used_surveygizmo)
dataset$calc_commutes <- as.logical(dataset$calc_commutes)

output_path <- 'media/documents/outputs/'

score_factors <- list(
  commute_factor=dataset$commute_factor,
  Edscore_factor=dataset$Edscore_factor,
  Math_factor=0, # remove altogether?
  age_factor=0,
  ethnicity_factor=dataset$ethnicity_factor,
  Tutoring_factor=0,
  Spanish_factor=0, # remove when firm placements done
  gender_factor=dataset$gender_factor,
  preserve_ij_factor=0
)

api_key_file <- 'gdm_api_key.txt'
api_key <- readChar(api_key_file, file.info(api_key_file)$size)

# Load Functions
source("cleaning.R", echo=FALSE)
source("commutes.R", echo=FALSE)
source("placement_algorithm.R", echo=FALSE)

# Load and Clean Inputs
acm_df <- read.csv(dataset$acm_input_path, check.names=FALSE, stringsAsFactors=FALSE)
school_df <- read_excel(dataset$sch_input_path)
result <- clean_inputs(acm_df, school_df)
acm_df <- result[[1]]
school_df <- result[[2]]

if(dataset$calc_commutes == TRUE){
  result <- shape_inputs(acm_df, school_df)
  acm_df_clean <- result[[1]]
  school_df_clean <- result[[2]]
  # TODO: acm_df[1,] is only calculating commutes for a single ACM, remember to remove for production
  acm_commutes <- commute_procedure(acm_df_clean[2,], school_df_clean, api = api_key)
  write.table(acm_commutes, file = paste0(output_path, 'Output_Commute_Reference.csv'), sep=",", row.names=FALSE, na = "")
}

if(score_factors$commute_factor > 0){
  acm_commutes <- read.csv(paste0(output_path, 'Output_Commute_Reference.csv'), check.names=FALSE)
  acm_commutes$Commute.Time <- as.numeric(as.character(acm_commutes$Commute.Time))
  acm_commutes$id_dest <- paste(acm_commutes$Full.Name, acm_commutes$School, sep = "_")
} else {
  acm_commutes <- data.frame(acm_id	= NA,
                             Full.Name	= NA,
                             Home.Address	= NA,
                             School.Address	= NA,
                             School	= NA,
                             Commute.Time	= NA,
                             Mode	= NA,
                             Stutus	= NA,
                             Commute.Rank = NA,
                             id_dest = NA)
}

dt_commutes <- data.table(acm_commutes)

run_algorithm(acm_df, school_df)

end.time <- Sys.time()
time.taken <- end.time - start.time