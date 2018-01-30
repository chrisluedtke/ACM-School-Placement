library(readxl)
library(dplyr)
library(tidyr)
library(data.table)

import_data <- function(path, consider_commutes='No'){
  acm_df <- read.csv(file = paste(path, "Input 1 - ACM Data.csv", sep = ""), check.names=FALSE, stringsAsFactors = FALSE)
  acm_df$acm_id <- 1:nrow(acm_df)
  
  if(consider_commutes == "Yes"){
    acm_commutes <- read.csv(file = paste(path, "ACM Commutes.csv", sep = ""), check.names=FALSE)
    acm_commutes$Commute.Time <- as.numeric(as.character(acm_commutes$Commute.Time))
    acm_commutes$id_dest <- paste(acm_commutes$Full.Name, acm_commutes$School, sep = "_")
    dt_commutes <- data.table(acm_commutes)
  }

  if(used_surveygizmo == "Yes"){
    acm_df <- rename_headers(acm_df)
  }
     
  # school_df <- read_excel(path = paste(path, "Input 2 - School Data.xlsx", sep = ""))
  # school_df <- school_df[!is.na(school_df$School),]
  # school_df <- school_df[order(school_df$School),]
  # school_df$sch_id <- 1:nrow(school_df)

  # Create One Race.Ethnicity Column
  ethn_cols = c("Race.Ethnicity.African.American.Black",
                "Race.Ethnicity.American.Indian.Alaskan.Native",
                "Race.Ethnicity.Asian",
                "Race.Ethnicity.Hispanic.Latino",
                "Race.Ethnicity.Middle.Eastern",
                "Race.Ethnicity.Native.Hawaiian.Pacific.Islander",
                "Race.Ethnicity.White.Caucasian",
                "Race.Ethnicity.Other")

  # acm_df[, ethn_cols][acm_df[, ethn_cols] == ""] <- NA
  # 
  # acm_df$Race.Ethnicity <- apply(acm_df[, ethn_cols], 1, function(x) toString(na.omit(x)))
  # 
  # acm_df <- clean_roommates(acm_df)
  # acm_df <- clean_pre_rel(acm_df)
  # acm_df <- acm_df[acm_df$Full.Name!="",]
  acm_df
}

rename_headers <- function(acm_df){
  vars_df <- read_excel(path = paste(root_dir, "Survey Items to Variable Names.xls", sep = ""))
  
  # Rename Headers
  for (x in names(acm_df)){
    if(x %in% vars_df$Survey.Item){
      names(acm_df)[names(acm_df) == x] <- as.character(vars_df$Variable.Name[vars_df$Survey.Item == x])
    }
  }
  acm_df
}

validate_imputs <- function(acm_df){
  # Add validation code for all inputs
}

clean_roommates <- function(acm_df){
  cols <- c("Roommate.Names1",
            "Roommate.Names2",
            "Roommate.Names3",
            "Roommate.Names4",
            "Roommate.Names5")
  
  roommates_df <- acm_df[,names(acm_df) %in% c("Full.Name", "Roommates", cols)]
  
  roommates_df <- roommates_df[roommates_df$Roommates == 'Yes' | roommates_df$Full.Name %in% unlist(roommates_df[, cols], use.names = FALSE), ]
  
  acm_df$Roommate.Names <- NA
  
  for (x in roommates_df$Full.Name){
    # Select any rows containing ACM name
    other_roommates <- subset(roommates_df, apply(roommates_df, 1, function(y){any(y == x)}))
    
    cols <- c("Full.Name", cols)
    
    # Select unique roommate names
    roommates_list <- unique(unlist(other_roommates[, cols], use.names = FALSE))
    roommates_list <- sort(roommates_list[!is.na(roommates_list) & (roommates_list != "")])
    
    acm_df$Roommate.Names[acm_df$Full.Name == x] <- paste(roommates_list, collapse=", ")
  }
  
  acm_df
}

clean_pre_rel <- function(acm_df){
  pre_rel_cols <- c("Prior.Rship.Name1",
                    "Prior.Rship.Name2",
                    "Prior.Rship.Name3",
                    "Prior.Rship.Name4",
                    "Prior.Rship.Name5")
  
  acm_df[, pre_rel_cols] <- NA
  
  #acm_df$Prior.Rship.Name[acm_df$Prior.Rship.Name == ""] <- NA
  
  for (x in acm_df$Prior.Rship.Name[!is.na(acm_df$Prior.Rship.Name)]){
    elems <- unlist(strsplit(x , ", "))
    acm_df$Prior.Rship.Name1[acm_df$Prior.Rship.Name==x] <- elems[1]
    if(length(elems) > 1) acm_df$Prior.Rship.Name2[acm_df$Prior.Rship.Name==x] <- elems[2]
    if(length(elems) > 2) acm_df$Prior.Rship.Name3[acm_df$Prior.Rship.Name==x] <- elems[3]
    if(length(elems) > 3) acm_df$Prior.Rship.Name4[acm_df$Prior.Rship.Name==x] <- elems[4]
    if(length(elems) > 4) acm_df$Prior.Rship.Name5[acm_df$Prior.Rship.Name==x] <- elems[5]
  }
  
  # pre_rel_df <- acm_df[!is.na(acm_df$Prior.Rship.Name) | acm_df$Full.Name %in% unlist(acm_df[, pre_rel_cols], use.names = FALSE), ]
  
  # for (x in pre_rel_df$Full.Name){
  #   # Select any rows containing ACM name
  #   other_pre_rels <- subset(pre_rel_df, apply(pre_rel_df, 1, function(y){any(y == x)}))
  #   
  #   pre_rel_cols <- c("Full.Name", pre_rel_cols)
  #   
  #   # Select unique roommate names
  #   pre_rels_list <- unique(unlist(other_pre_rels[, pre_rel_cols], use.names = FALSE))
  #   pre_rels_list <- sort(pre_rels_list[!is.na(pre_rels_list) & (pre_rels_list != "")])
  #   
  #   acm_df$Prior.Rship.Name[acm_df$Full.Name == x] <- paste(pre_rels_list, collapse=", ")
  # }
  
  return(acm_df)
}

#  Encode Variables & Clean Up Input Dataframes

#Before being able to calculate a score, we'll need to encode all of our variables numerically.  For categorical ## variables, we can create a dummy variable for all except one of the categories (this is because the last category can be inferred).

# This function takes the input acm_df and encodes the variables in a way that makes the mathematically tractable.

encode_acm_df <- function(df){
  
  acm_enc <- select(acm_df, acm_id, Math.Confidence)
  
  # Ed Attainment
  acm_enc$Ed_HS <- as.numeric(grepl("High School/GED", df$Educational.Attainment))
  acm_enc$Ed_SomeCol <- grepl("Some College", df$Educational.Attainment) + grepl("Associate's Degree", df$Educational.Attainment)
  acm_enc$Ed_Col <- grepl("Bachelor's Degree", df$Educational.Attainment) + grepl("Master's Degree", df$Educational.Attainment)
  
  # Tutoring Experience
  acm_enc$HasTutored <- as.numeric(grepl("Yes", df$Tutoring.Experience))
  
  # Language Ability
  acm_enc$SpanishAble <- as.numeric(grepl("Spanish", df$Language.Ability.Spanish))
  acm_enc$Lang_Other <- ifelse(grepl("Spanish", df$Language.Ability.Spanish) == F & grepl("Yes", df$Language.Other.English), 1, 0)
  
  # Gender
  acm_enc$Male <- as.numeric(grepl("Male", df$Gender))
  acm_enc$Other.Gender <- as.numeric(!grepl("Male", df$Gender)&!grepl("Female", df$Gender))
  
  # Math Confidence
  acm_enc$Math.Confidence <- as.numeric(grepl(paste(c("Algebra I", "Algebra II", "Trigonometry", "Calculus or higher"), collapse = "|"), acm_enc$Math.Confidence))
  
  # Add in other features
  acm_enc <- acm_enc %>%
    left_join(., select(df,
                        acm_id,
                        Full.Name,
                        Gender, 
                        Manual.Placement, 
                        Birth.Date,
                        Race.Ethnicity,
                        #IJ.Placement,
                        Prior.Rship.Name,
                        Prior.Rship.Name1,
                        Prior.Rship.Name2,
                        Prior.Rship.Name3,
                        Roommate.Names), by=c("acm_id" = "acm_id")) %>%
    mutate(days_old = as.integer(Sys.Date() - as.Date(as.character(df$Birth.Date), format="%m/%d/%Y"))) %>%
    replace_na(list(Lang_Other = 0, days_old = 0))
  
  # Validation of import will hopefully mean we don't need these lines
  acm_enc$Manual.Placement[acm_enc$Manual.Placement == ""] <- NA
  acm_enc$IJ.Placement[acm_enc$IJ.Placement == ""] <- NA
  
  return(acm_enc)
}

# This function calculates some import counts which I'm going to use a lot when trying to figure out the expected number of ACMs per team per metric.  This function will just be used internally by the school_config function.

corps_demographic_targets <- function(school_df, acm_enc){
  # Calculate some totals used later in the function
  N <- nrow(acm_enc)
  S <- nrow(school_df)
  
  # Counts of schools by level
  school_counts <- group_by(school_df, GradeLevel) %>% summarise(count=n())
  
  # Approximation of densly spanish speaking schools
  # dense_hispanic <- nrow(school_df[school_df$`% Hispanic` > 10, ])
  
  # We'll store our results in a list so we can return multiple tables
  distros <- list()
  
  # Produce ratio of folks who have completed at least an associates, and those who haven't
  # HS ratio is ( Number HS-educated ACMs / (N - n_HS_slots) ), since High Schools will have 0 HS-only educated ACMs
  n_HS_slots <- sum(school_df$`Team Size`[school_df$GradeLevel == "High"])
  distros$education <- data.frame(level = c("HS", "SomeCol"), ratio = c(nrow(acm_enc[acm_enc$Ed_HS == 1,]) / (N - n_HS_slots), nrow(acm_enc[acm_enc$Ed_SomeCol == 1,]) / N))
  
  # Identify rates of Tutoring Experience
  distros$tut_exp <- group_by(acm_enc, HasTutored) %>% 
    summarise(count=n()) %>% 
    mutate(ratio = count/N)
  
  # Spanish and other spoken language distribution
  distros$lang <- data.frame(ability = c("spanish","other"), ratio = c(nrow(acm_enc[acm_enc$SpanishAble == 1, ]) / N, nrow(acm_enc[acm_enc$Lang_Other == 1, ]) / N))
  
  # Math Ability
  distros$math <- nrow(acm_enc[acm_enc$Math.Confidence == 1,]) / N
  
  # Gender
  distros$gender <- nrow(acm_enc[(acm_enc$Male == 1) | (acm_enc$Other.Gender == 1), ]) / N
  
  distros
}

# Directly calculates the expected number of ACMs per team for each of the markers.
# My methodology is to aim for a uniform distribution when it makes sense.

school_config <- function(school_df, acm_enc){
  # Precalculate some helpful counts
  corps_demos <- corps_demographic_targets(school_df, acm_enc)
  # Unravel list into some variables.  Mostly so that the code is a little cleaner later.
  education <- corps_demos$education
  lang <- corps_demos$lang
  tut_exp <- corps_demos$tut_exp
  math <- corps_demos$math
  gender <- corps_demos$gender
  
  school_df <- school_df %>%
    rename(size = `Team Size`,
           span = `GradeLevel`,
           SpanishNeed = `N Spanish Speakers Reqd`)
  
  school_df$HSGrad_tgt <- ifelse(school_df$span=="High", 0, education[education$level %in% 'HS',]$ratio * as.numeric(school_df$size))
  school_df$SomeCol_tgt <- education[education$level %in% 'SomeCol',]$ratio * as.numeric(school_df$size)
  school_df$TutExp = as.numeric(school_df$size) * tut_exp[tut_exp$HasTutored == 1,]$ratio
  #schoo-_df$SpanishNeed = pmax(spanishNeed(`% Hispanic`), 1),# This sets a minimum of 1 spanish speaker per team.  This might make sense in LA, but not other placeschoo-_df$s.
  school_df$OtherLang_tgt <- lang[lang$ability %in% 'other',]$ratio * as.numeric(school_df$size)
  school_df$Math_tgt <- ifelse(school_df$span=="Elementary", as.numeric(school_df$size)*.5*math, ifelse(school_df$span=="Middle", .75*as.numeric(school_df$size)*math, as.numeric(school_df$size)*math))
  school_df$Male_tgt <- as.numeric(school_df$size)*gender
  
  return(school_df)
}