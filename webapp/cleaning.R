rename_headers <- function(acm_df){
  vars_df <- read_excel("Survey Items to Variable Names.xlsx")
  
  # TODO FY20: This line resolves an error from SurveyGizmo. The SurveyGizmo export contains duplicate column names: 'Other - Write In (Required):Other language' and 'Other - Write In:What is your race/ethnicity (choose all that apply)'
  acm_df <- acm_df[, !duplicated(colnames(acm_df), fromLast = TRUE)]

  names(acm_df) <- trimws(names(acm_df))
  vars_df$Survey.Item <- trimws(vars_df$Survey.Item)

  for (x in names(acm_df)){
    if(x %in% vars_df$Survey.Item){
      names(acm_df)[names(acm_df) == x] <- as.character(vars_df$Clean.Variable.Name[vars_df$Survey.Item == x])
    }
  }
  return(acm_df)
}

#' Compares all ACM, Team Leader, and Manager names from acm_df and school_df to ensure all
#' mentioned roommates and prior relationships match a valid ACM survey respondant name.
#' Exports "Invalid Roommate and Prior Relationship Names.csv"
#' TODO: Prior Relationships should be separate columns, update script to merge these columns
#'       as "Prior.Rship.Names"
clean_RMs_PrRels <- function(acm_df, school_df){
  RM_cols <- names(acm_df %>% select(.,matches("Roommate.Name")))
  PrRel_cols <- names(acm_df %>% select(.,matches("Prior.Rship")))
  
  # return list of names mentioned as roommates or prior relationships that did not match to ACM, Team Leader, or Manager names
  RMs_PrRels_df <- acm_df[,names(acm_df) %in% c(RM_cols, PrRel_cols)]
  Uniq_RMs_PrRels_df <- unname(unlist(RMs_PrRels_df))
  Uniq_RMs_PrRels_df <- Uniq_RMs_PrRels_df[!is.na(Uniq_RMs_PrRels_df) & Uniq_RMs_PrRels_df != ""]
  # this line ensures we capture names when there are two comma-separated names in the same cell
  Uniq_RMs_PrRels_df <- strsplit((paste(c(Uniq_RMs_PrRels_df),sep="",collapse=", ")), ", ")[[1]]
  Uniq_RMs_PrRels_df <- unique(Uniq_RMs_PrRels_df)
  RMs_PrRels_no_match <- Uniq_RMs_PrRels_df[!(unlist(Uniq_RMs_PrRels_df ) %in% c(acm_df$Full.Name, school_df$`Team Leader`, school_df$Manager))]
  # write.table(RMs_PrRels_no_match, file = paste0(output_path, "Invalid Roommate and Prior Relationship Names.csv"), sep=",", row.names=FALSE, col.names=FALSE)
  
  if (length(RMs_PrRels_no_match) > 0){
    stop(paste("The following names were mentioned in an ACM survey response as a roommate or prior relationship, but they did not match to another ACM respondent or Team Leader/Manager in your School Data spreadsheet. In your ACM survey results, fix the spelling of these names or remove them:\n", paste(RMs_PrRels_no_match, collapse="\n")))
  }
  
  # create consistent roommate sets for each roommate
  RMs_df <- acm_df[,names(acm_df) %in% c("acm_id", "Full.Name", "Roommates", RM_cols)]
  RMs_df <- RMs_df[RMs_df$Roommates == 'Yes' | RMs_df$Full.Name %in% unlist(RMs_df[, RM_cols], use.names = FALSE), ]
  
  RMs_df$Roommate.Names <- NA
  cols <- c("Full.Name", RM_cols)
  
  for (x in RMs_df$Full.Name){
    # Select any rows containing ACM name, and merge together all info in roommates columns
    other_roommates <- subset(RMs_df, apply(RMs_df, 1, function(y){any(y == x)}))
    
    # Select unique roommate names
    roommates_list <- unique(unlist(other_roommates[, cols], use.names = FALSE))
    roommates_list <- sort(roommates_list[!is.na(roommates_list) & (roommates_list != "")])
    roommates_list <- paste(roommates_list, collapse=", ")
    
    RMs_df$Roommate.Names[RMs_df$Full.Name == x] <- roommates_list
  }
  
  acm_df <- acm_df[ , !(names(acm_df) %in% RM_cols)]
  acm_df <- merge(acm_df, RMs_df[ , c("acm_id", "Roommate.Names")], by="acm_id", all.x=TRUE)
  
  return(acm_df)
}

clean_inputs <- function(acm_df, school_df){
  if(dataset$used_surveygizmo == TRUE){
    acm_df <- rename_headers(acm_df)
  }
  
  acm_df <- acm_df[acm_df$Full.Name!="",]
  acm_df <- acm_df[!is.na(acm_df$Full.Name),]
  acm_df$acm_id <- 1:nrow(acm_df)
  
  school_df <- school_df[!is.na(school_df$School),]
  school_df <- school_df[order(school_df$School),]
  school_df$sch_id <- 1:nrow(school_df)
  
  # Combine ethnicity columns into one
  ethn_cols <- names(acm_df %>% select(.,matches("Race.Ethnicity.")))
  acm_df[, ethn_cols][acm_df[, ethn_cols] == ""] <- NA
  acm_df$Race.Ethnicity <- apply(acm_df[, ethn_cols], 1, function(x) toString(na.omit(x)))
  
  # Create one Tutoring Experience Grades Column
  tut_exp_cols = c("Tutoring.Experience.ES",                      
                   "Tutoring.Experience.MS",
                   "Tutoring.Experience.HS")
  acm_df[, tut_exp_cols][acm_df[, tut_exp_cols] == ""] <- NA
  acm_df$Tutoring.Experience.Grades <- apply(acm_df[, tut_exp_cols], 1, function(x) toString(na.omit(x)))
  
  # Create one Grade Level Preference Column
  grd_lvl_pref_cols = c("Grade.Lvl.Pref.ES",
                        "Grade.Lvl.Pref.MS",
                        "Grade.Lvl.Pref.HS")
  acm_df[, grd_lvl_pref_cols][acm_df[, grd_lvl_pref_cols] == ""] <- NA
  acm_df$Grade.Lvl.Pref <- apply(acm_df[, grd_lvl_pref_cols ], 1, function(x) toString(na.omit(x)))
  
  # Create one language column
  language_cols = c("Language.Ability.Arabic"                       ,
                    "Language.Ability.CapeVerdeanCreole",
                    "Language.Ability.Chinese.Cantonese",
                    "Language.Ability.Chinese.Mandarin" ,
                    "Language.Ability.HaitianCreole"    ,
                    "Language.Ability.French"           ,
                    "Language.Ability.Nepali"           ,
                    "Language.Ability.Polish"           ,
                    "Language.Ability.Spanish"          ,
                    "Language.Ability.Swahili"          ,
                    "Language.Ability.Urdu"             ,
                    "Language.Ability.Vietnamese"       ,
                    "Language.Ability.Other")
  
  acm_df[, language_cols][acm_df[, language_cols] == ""] <- NA
  acm_df$Language <- apply(acm_df[, language_cols ], 1, function(x) toString(na.omit(x)))
  
  acm_df$Days.Old <- as.integer(Sys.Date() - as.Date(as.character(acm_df$Birth.Date), format="%m/%d/%Y"))
  acm_df$Age <- acm_df$Days.Old/365.25
  
  if(!("Manual.Placement" %in% colnames(acm_df))){
    acm_df$Manual.Placement <- NA
  }
  if(!("Prior.Rship.Name" %in% colnames(acm_df))){
    acm_df$Prior.Rship.Name <- NA
  }

  acm_df <- clean_RMs_PrRels(acm_df, school_df)
  
  return(list(acm_df, school_df))
}
