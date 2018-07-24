#' Compares all ACM, Team Leader, and Manager names from acm_df and school_df to ensure all
#' mentioned roommates and prior relationships match a valid ACM survey respondant name.
#' Exports "Invalid Roommate and Prior Relationship Names.csv"
clean_RMs_PrRels <- function(acm_df, school_df){
  RM_cols <- names(acm_df %>% select(.,matches("Roommate.Name")))
  PrRel_cols <- names(acm_df %>% select(.,matches("Prior.Rship.Name")))
  
  # return list of names mentioned as roommates or prior relationships that did not match to ACM, Team Leader, or Manager names
  RMs_PrRels_df <- acm_df[,names(acm_df) %in% c(RM_cols, PrRel_cols)]
  Uniq_RMs_PrRels <- unname(unlist(RMs_PrRels_df))
  Uniq_RMs_PrRels <- Uniq_RMs_PrRels[!is.na(Uniq_RMs_PrRels) & Uniq_RMs_PrRels != ""]
  # this line ensures we capture names when there are two comma-separated names in the same cell
  Uniq_RMs_PrRels <- strsplit((paste(c(Uniq_RMs_PrRels),sep="",collapse=", ")), ", ")[[1]]
  Uniq_RMs_PrRels <- unique(Uniq_RMs_PrRels)
  RMs_PrRels_no_match <- Uniq_RMs_PrRels[!(unlist(Uniq_RMs_PrRels ) %in% c(acm_df$Full.Name, school_df$`Team Leader`, school_df$Manager))]

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
  
  acm_df[, PrRel_cols][acm_df[, PrRel_cols] == ""] <- NA
  acm_df[, "Prior.Rship.Names"] <- apply(acm_df[, PrRel_cols], 1, function(x) toString(na.omit(x)))
  
  # Drop RM_cols and PrRel_cols
  acm_df <- acm_df[ , !(names(acm_df) %in% c(RM_cols, PrRel_cols))]
  acm_df <- merge(acm_df, RMs_df[ , c("acm_id", "Roommate.Names")], by="acm_id", all.x=TRUE)
  
  return(acm_df)
}

clean_inputs <- function(acm_df, school_df){
  acm_df <- acm_df[(acm_df$Full.Name != "") & !is.na(acm_df$Full.Name),]
  acm_df$acm_id <- 1:nrow(acm_df)
  
  school_df <- school_df[(school_df$School != "") & !is.na(school_df$School),]
  school_df$sch_id <- 1:nrow(school_df)
  
  slots = sum(school_df$`Team Size`)
  n_acms = nrow(acm_df)
  if(slots != n_acms){
    stop(paste("Error: you are filling", slots, "with", n_acms, "acms. Adjust Team Sizes to make these numbers equal."))
  }
  
  # Combine various column groups into single columns
  for(key_col in c("Race.Ethnicity", "Language.Ability", "Tutoring.Exp.Grades", "Tutoring.Pref.Grades", "Tutoring.Pref.Subject")){
    cols <- names(acm_df %>% select(.,matches(key_col)))
    if(length(cols) > 0){
      acm_df[, cols][acm_df[, cols] == ""] <- NA
      acm_df[key_col] <- apply(acm_df[, cols], 1, function(x) toString(na.omit(x)))
    } else {
      acm_df[key_col] <- NA
    }
  }
  
  acm_df$Age <- as.integer(as.Date("2018-08-15") - as.Date(as.character(acm_df$Birth.Date), format="%m/%d/%Y"))
  acm_df$Age <- acm_df$Age/365.25

  acm_df <- clean_RMs_PrRels(acm_df, school_df)
  
  return(list(acm_df, school_df))
}
