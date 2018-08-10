### TODO's (Ctrl + F 'TODO' to see what is being developed)
# * [Survey] Prior Relationships should be entered one at a time in separate fields so they export as separate columns and we avoid comma-separation issues (and make small script changes to reflect this)
# * [Algorithm] ACM subject preference (doable by setting targets in school data input)
# * [Algorithm] Option to set definition of diversity (to equally distribute across schools or to reflect the school demographics)
# * [Algorithm] Grade level preference - Pat and Adriana
# * [Algorithm] IJ team creation (implemented in CHI FY17, but currently disabled and likely obsolete since updates)
# * [Algorithm] Remove features we have decided not to be meaningful (balanced tutoring experience, balanced math ability)
# * [Algorithm] Connect to RAD dashboard (or targetX to get PCWs and remove from analysis)
# * [Algorithm] Error-check that manual.placement column contains valid schools

#  Encode Variables & Clean Up Input Dataframes
#' Before being able to calculate a score, we need to encode all of our variables numerically.
#' For categorical ## variables, we create a dummy variable for all except one of the
#' categories (this is because the last category can be inferred).
#' This function takes the input acm_df and encodes the variables in a way that makes them
#' mathematically tractable.
encode_acm_df <- function(df){
  acm_enc <- select(acm_df, acm_id, Math.Confidence)

  # Ed Attainment
  acm_enc$Ed_HS <- as.numeric(grepl("high school", tolower(df$Educational.Attainment)))
  acm_enc$Ed_SomeCol <- as.numeric(grepl("some college|associate", tolower(df$Educational.Attainment)))
  acm_enc$Ed_Col <- as.numeric(grepl("bachelor|master|gradute", tolower(df$Educational.Attainment)))
  
  # Tutoring Experience
  acm_enc$HasTutored <- as.numeric(grepl("Yes", df$Tutoring.Experience))

  # Language Ability
  acm_enc$SpanishAble <- as.numeric(grepl("Spanish", df$Language.Ability))
  acm_enc$Lang_Other <- ifelse(grepl("Spanish", df$Language.Ability) == F & grepl("Yes", df$Language.Other.English), 1, 0)
  
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
                                   Age,
                                   Race.Ethnicity,
                                   # IJ.Placement,
                                   Prior.Rship.Names,
                                   Roommate.Names), by=c("acm_id" = "acm_id")) %>%
               replace_na(list(Lang_Other = 0, Age = 0))
  
  return(acm_enc)
}

#' This function calculates some import counts which we use when trying to 
#' figure out the expected number of ACMs per team per metric.
#' This function is used internally by the school_config function.
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

  # Produce ratio of ACMs who have completed at least an associates, and those who haven't
  distros$education <- data.frame(level = c("HS", "SomeCol"), 
                                  ratio = c(nrow(acm_enc[acm_enc$Ed_HS == 1,]) / N, nrow(acm_enc[acm_enc$Ed_SomeCol == 1,]) / N))
  
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

#' Calculates the expected number of ACMs per team for each of the markers.
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

  school_df$HSGrad_tgt <- education[education$level=='HS', 'ratio'] * as.numeric(school_df$size)
  school_df$SomeCol_tgt <- education[education$level=='SomeCol', 'ratio'] * as.numeric(school_df$size)
  school_df$TutExp <- as.numeric(school_df$size) * ifelse(length(tut_exp[tut_exp$HasTutored == 1,]$ratio)==0, 0, tut_exp[tut_exp$HasTutored == 1,]$ratio)
  school_df$SpanishNeed[is.na(school_df$SpanishNeed)] <- 0
  school_df$OtherLang_tgt <- lang[lang$ability %in% 'other',]$ratio * as.numeric(school_df$size)
  school_df$Math_tgt <- ifelse(school_df$span=="Elementary", as.numeric(school_df$size)*.5*math, ifelse(school_df$span=="Middle", .75*as.numeric(school_df$size)*math, as.numeric(school_df$size)*math))
  school_df$Male_tgt <- as.numeric(school_df$size)*gender
  
  return(school_df)
}

#' Calculates each ACM's eligibility to serve at each school based on factors
#' between each ACM and each school (HS eligibility, TL and IM prior 
#' relationship / roommate conflicts, manual placements)
elig_plcmnts_schwise <- function(team_placements_df, school_df, consider_HS_elig){
  perm <- merge(team_placements_df, school_df, all.x=TRUE) %>%
     mutate(HS_conf = 0, 
            pre_TL_conf = 0, 
            pre_IM_conf = 0, 
            acm_id_sch_id = paste(acm_id, sch_id, sep="_"))
  
  # High School service Eligibility
  if(consider_HS_elig == TRUE){
    perm$HS_conf[(((perm$Ed_SomeCol != 1) & (perm$Ed_Col != 1) & (perm$Age < 21)) | (perm$Math.Confidence != 1)) & (perm$GradeLevel == "High")] <- 1
  }
  
  # TL and IM Previous Relationship conflict (TLs, IMs check)
  perm$pre_TL_conf <- as.numeric(mapply(grepl, pattern=perm$`Team Leader`, paste(perm$Prior.Rship.Names, perm$Roommate.Names)))
  perm$pre_IM_conf <- as.numeric(mapply(grepl, pattern=perm$`Manager`, paste(perm$Prior.Rship.Names, perm$Roommate.Names)))

  # Sum conflictts
  perm$sch_conf_sum <- rowSums(perm[,c("HS_conf", "pre_TL_conf", "pre_IM_conf")], na.rm=TRUE)

  # Set school conflicts to 0 for the school equal to the manual placement, and 1 for all others
  perm$sch_conf_sum[!is.na(perm$Manual.Placement) & (perm$School == perm$Manual.Placement)] <- 0
  perm$sch_conf_sum[!is.na(perm$Manual.Placement) & (perm$School != perm$Manual.Placement)] <- 1
  
  # Remove placement column because placement will change with each iteration
  perm <- perm[, !(names(perm) %in% c("placement"))]
  
  return(perm)
}

#' Calculate each ACM's eligibility to serve with all other ACMs based on 
#' roommates and prior relationships
elig_plcmnts_acmwise <- function(team_placements_df, prevent_roommates){
  acm1_df <- team_placements_df[,c("acm_id", "Full.Name", "Roommate.Names", "Prior.Rship.Names")]
  acm2_df <- team_placements_df[,c("acm_id", "Full.Name")]
  names(acm2_df) <- c("acm2_id", "acm2_Full.Name")
  acm_compat <- merge(acm1_df, acm2_df, all.x=TRUE)
  
  if (prevent_roommates == TRUE){
    acm_compat$rm_conf <- as.numeric(mapply(grepl, pattern=acm_compat$acm2_Full.Name, acm_compat$Roommate.Names))
  } else {acm_compat$rm_conf <- 0}
  
  acm_compat$priorrel_conf <- as.numeric(mapply(grepl, pattern=acm_compat$acm2_Full.Name, acm_compat$Prior.Rship.Names))
  acm_compat$acm_conf <- rowSums(acm_compat[,c("rm_conf", "priorrel_conf")])
  acm_compat <- acm_compat[acm_compat$acm_id != acm_compat$acm2_id, ]
  
  # ensure that if ACM1 has conflict with ACM34, ACM34 also has conflict with ACM1
  cols <- names(acm_compat)
  acm_compat$larger_id <- pmax(acm_compat$acm_id, acm_compat$acm2_id)
  acm_compat$smaller_id <- pmin(acm_compat$acm_id, acm_compat$acm2_id)
  acm_compat$key <- paste(acm_compat$smaller_id, acm_compat$larger_id, sep="_")
  
  acm_compat <- acm_compat %>%
    group_by(key) %>% 
    mutate(key_sum=sum(acm_conf)) %>%
    ungroup()
  
  acm_compat$acm_conf[acm_compat$key_sum > 0] <- 1
  
  return(acm_compat[,cols])
}

#' Make random (other than manual placement) initial school placements
#' Add dummy id's if more school slots are available than survey respondants
initial_placement <- function(acm_enc, school_targets){
  # return dataframe of manual placements (cols: acm_id, sch_id)
  manual_plc_slots <- merge(acm_enc[!is.na(acm_enc$Manual.Placement),c('acm_id', 'Manual.Placement')],
                            school_targets[, c('sch_id','School')], by.x='Manual.Placement', by.y='School') %>%
                        .[, c('acm_id','sch_id')]
  
  # count number of manual placements by team
  filled_slot_counts <- manual_plc_slots %>%
                          group_by(sch_id) %>%
                          summarise(filled = n())
  
  team_size_targets <- select(school_targets, c(sch_id,size)) %>%
                        left_join(., filled_slot_counts, by=("sch_id")) %>%
                        replace_na(list(filled = 0)) %>%
                        mutate(non_manual_size = as.numeric(size) - as.numeric(filled))
  
  # create a list that repeats each school 'id' for the number of each team's available slots
  team_slots_avail = list()
  for (x in team_size_targets$sch_id[team_size_targets$non_manual_size>0]){
    team_slots_x = list(rep(x, subset(team_size_targets$non_manual_size, team_size_targets$sch_id == x)))
    team_slots_avail <- c(team_slots_avail, team_slots_x)
  }
  
  # Adds dummy id's if more slots are available than survey respondants
  team_placements_df <- data.frame(acm_id=1:sum(school_targets$size))
  # Assign manually placed ACMs to the corresponding sch_id
  team_placements_df <- merge(team_placements_df, manual_plc_slots, by="acm_id", all.x = T)
  # Randomly place everyone else
  team_placements_df$sch_id[is.na(team_placements_df$sch_id)] <- sample(unlist(team_slots_avail), replace=F)
  team_placements_df <- team_placements_df %>% rename(placement = sch_id)

  # Merge team_placements_df with acm_df on the 'id' column
  team_placements_df <- left_join(team_placements_df, acm_enc, by = "acm_id") %>%
                        replace_na(replace = list(Math.Confidence = 0, Ed_HS = 0, Ed_SomeCol = 0, Ed_Col = 0,
                                                  HasTutored = 0, SpanishAble = 0, Lang_Other = 0, Male = 0, 
                                                  Other.Gender = 0, Age = 0))

  return(team_placements_df)
}

append_elig_col <- function(team_placements_df, elig_plc_schwise_df, elig_plc_acmwise_df){
  team_placements_df$acm_id_sch_id <- paste(team_placements_df$acm_id, team_placements_df$placement, sep="_")
  
  # Identify current invalid placments based on school factors
  team_placements_df <- merge(team_placements_df, elig_plc_schwise_df[, c("acm_id_sch_id", "HS_conf", "pre_TL_conf", "pre_IM_conf", "sch_conf_sum")], by="acm_id_sch_id", all.x=TRUE)

  # Identify current invalid placments based on ACM factors, merge placement to acmwise_df, sum conflict column by group(acm_id, placement), then merge that sum back to team_placements_df
  elig_plc_acmwise_df <- merge(elig_plc_acmwise_df, team_placements_df[,c("acm_id", "placement")], by="acm_id")
  elig_plc_acmwise_df$acm_id_sch_id <- paste(elig_plc_acmwise_df$acm_id, elig_plc_acmwise_df$placement, sep="_")
  elig_plc_acmwise_df$acm2_id_sch_id <- paste(elig_plc_acmwise_df$acm2_id, elig_plc_acmwise_df$placement, sep="_")
  elig_plc_acmwise_df <- elig_plc_acmwise_df %>%
    filter(acm2_id_sch_id %in% acm_id_sch_id) %>%
    group_by(acm_id_sch_id) %>%
    summarise(acm_conf_sum = sum(acm_conf))
  
  team_placements_df <- merge(team_placements_df, elig_plc_acmwise_df[,c("acm_id_sch_id", "acm_conf_sum")], by = "acm_id_sch_id", all.x = TRUE)
  
  team_placements_df$elig <- as.numeric((rowSums(team_placements_df[,c("sch_conf_sum", "acm_conf_sum")], na.rm=TRUE)) == 0)
  
  # Manual Placement is already correct. All ACMs with manual placement are marked eligible.
  team_placements_df$elig[!is.na(team_placements_df$Manual.Placement)] <- 1
  
  # keep "sch_conf_sum", "acm_conf_sum", "elig" cols from this func
  return(team_placements_df)
}

span_targets_diffs <- function(team_placements_df, school_df){
  df <- team_placements_df %>%
    group_by(placement) %>%
    summarise(n_span_placed=sum(SpanishAble)) %>%
    left_join(., school_df[c("sch_id", "N Spanish Speakers Reqd")], by=c("placement" = "sch_id")) %>%
    replace(is.na(.), 0) %>%
    mutate(diffs = n_span_placed - `N Spanish Speakers Reqd`)
  
  return(df)
}

#' TODO: refactor redundant code in Spanish speaker placement pieces
initial_valid_placement <- function(team_placements_df, school_df, elig_plc_schwise_df, elig_plc_acmwise_df){
  if(sum(school_df$`N Spanish Speakers Reqd`, na.rm=T) > sum(team_placements_df$SpanishAble, na.rm=T)){
    stop(paste("You have", sum(school_df$`N Spanish Speakers Reqd`), "Spanish Speaker slots, but only", sum(team_placements_df$SpanishAble), "Spanish speakers."))
  }
  original_cols <- names(team_placements_df)
  
  # Check if Spanish targets met
  span_target_diffs_df <- span_targets_diffs(team_placements_df, school_df)
  span_targets_met <- (sum(span_target_diffs_df$diffs < 0, na.rm=T) == 0)
  span_surplus_sch_ids <- span_target_diffs_df$placement[span_target_diffs_df$diffs > 0]
  span_deficit_sch_ids <- span_target_diffs_df$placement[span_target_diffs_df$diffs < 0]
  
  team_placements_df <- append_elig_col(team_placements_df, elig_plc_schwise_df, elig_plc_acmwise_df)
  if((score_factors$Spanish_factor > 0) & (span_targets_met == FALSE)){
    # assign 'elig' to 0 for any Spanish speaking ACMs at schools with surplus of Spanish speakers
    team_placements_df$elig[(team_placements_df$SpanishAble==1) 
                            & (team_placements_df$placement %in% span_surplus_sch_ids) 
                            & is.na(team_placements_df$Manual.Placement)] <- 0
  }
  n_inelig <- nrow(team_placements_df[team_placements_df$elig == 0,])

  i <- 0
  attempts <- 150
  attmptd_swaps <- c()
  while (n_inelig > 0){
    i <- i + 1
    if (i > attempts){
      stop(paste('Could not find valid starting placements in', attempts, 'attempts.', n_inelig, 'invalid placements remain.', "Usually re-running will fix this. It's possible that no corps placement exists that meets all firm constraints you set (Spanish speaker targets, prevented roommates, HS eligibility, etc.)."))
    }
    # if (i == (attempts-1)){browser()}
    # Choose one invalid ACM to swap. Inelig_acm_ids duplicated to avoid a length 1 input to sample() (see notes in make_swap())
    inelig_acm_ids <- team_placements_df$acm_id[team_placements_df$elig == 0]
    swap1 <- sample(c(inelig_acm_ids,inelig_acm_ids), 1)
    attmptd_swaps <- c(attmptd_swaps, swap1)
    # reset columns
    team_placements_df <- team_placements_df[, original_cols]
    # make swap
    if((score_factors$Spanish_factor > 0) & (span_targets_met == FALSE)){
      if(length(unique(tail(attmptd_swaps,5))) == 1){
        # If attempts at valid placements get stuck (5 consecutive swap1s), ignore spanish conflicts
        df <- elig_plc_schwise_df
      } else {
        # update elig_plc_schwise_df to make all Spanish speakers only eligible to serve at schools with a Spanish speaker deficit
        df <- elig_plc_schwise_df
        df$sch_conf_sum[(df$SpanishAble==1) & !(df$sch_id %in% span_deficit_sch_ids) & (is.na(df$Manual.Placement) | (df$School != df$Manual.Placement))] <- 1
      }
      team_placements_df <- make_swap(team_placements_df, swap1, df, elig_plc_acmwise_df)
    } else {
      team_placements_df <- make_swap(team_placements_df, swap1, elig_plc_schwise_df, elig_plc_acmwise_df)
    }
    # Check if Spanish targets met
    span_target_diffs_df <- span_targets_diffs(team_placements_df, school_df)
    span_targets_met <- (sum(span_target_diffs_df$diffs < 0, na.rm = T) == 0)
    span_surplus_sch_ids <- span_target_diffs_df$placement[span_target_diffs_df$diffs > 0]
    span_deficit_sch_ids <- span_target_diffs_df$placement[span_target_diffs_df$diffs < 0]
    
    # recalc "elig" column
    team_placements_df <- append_elig_col(team_placements_df, elig_plc_schwise_df, elig_plc_acmwise_df)
    # adjust for span targets
    if((score_factors$Spanish_factor > 0) & (span_targets_met == FALSE)){
      # assign 'elig' to 0 for any Spanish speaking ACMs at schools with surplus of Spanish speakers
      team_placements_df$elig[(team_placements_df$SpanishAble==1) & (team_placements_df$placement %in% span_surplus_sch_ids) & is.na(team_placements_df$Manual.Placement)] <- 0
    }
    n_inelig <- nrow(team_placements_df[team_placements_df$elig == 0,])
  }
  # reset columns
  return(team_placements_df[, original_cols])
}

make_swap <- function(plcmts_df, swap1, elig_plc_schwise_df, elig_plc_acmwise_df){
  plcmts_df_cols <- names(plcmts_df)
  plcmts_df$acm_id_sch_id <- paste(plcmts_df$acm_id, plcmts_df$placement, sep="_")
  
  schools_to_swap <- c(0, 0)
  schools_to_swap[1] <- plcmts_df$placement[plcmts_df$acm_id==swap1]
  school1_ids <- plcmts_df$acm_id[plcmts_df$placement == schools_to_swap[1]]
  
  # Find schools at which ACM1 is eligible to serve based on school factors
  school2_set_schwise <- elig_plc_schwise_df$sch_id[(elig_plc_schwise_df$acm_id == swap1)
                                                    &(elig_plc_schwise_df$sch_conf_sum==0)
                                                    &(elig_plc_schwise_df$sch_id != schools_to_swap[1])]

  # Within that set of schools, find schools at which ACM1 is eligible to serve based on the other ACMs at those schools
  elig_plc_acmwise_df <- merge(elig_plc_acmwise_df, plcmts_df[,c("acm_id", "placement")], by="acm_id")
  
  school2_set <- elig_plc_acmwise_df %>%
    filter(acm2_id == swap1 & placement %in% school2_set_schwise) %>%
    group_by(placement) %>%
    summarise(acm_conf_sum=sum(acm_conf)) %>%
    filter(acm_conf_sum == 0) %>%
    select(placement) %>% .[["placement"]]
  
  if(length(school2_set)>0){
    # school2_set is combined with itself to ensure we aren't passing a length 1 argument to sample()
    schools_to_swap[2] <- sample(c(school2_set, school2_set), 1)
  } else {return(plcmts_df[, plcmts_df_cols])}

  school2_ids = plcmts_df$acm_id[plcmts_df$placement == schools_to_swap[2]]
  # Find ACMs who are eligible to serve at school1 
  swap2_set_schwise <- elig_plc_schwise_df$acm_id[(elig_plc_schwise_df$sch_id == schools_to_swap[1])
                                                  &(elig_plc_schwise_df$sch_conf_sum==0)
                                                  &(elig_plc_schwise_df$acm_id %in% school2_ids)]
  
  # Among those ACMs, find ACMs who are eligible to serve with the ACMs at school1
  swap2_set <- elig_plc_acmwise_df %>%
    filter(acm_id %in% swap2_set_schwise & acm2_id %in% school1_ids) %>%
    group_by(acm_id) %>%
    summarise(acm_conf_sum=sum(acm_conf)) %>%
    filter(acm_conf_sum == 0) %>%
    select(acm_id) %>% .[["acm_id"]]
  
  if(length(swap2_set)>0){
    swap2 <- sample(c(swap2_set, swap2_set), 1)
  } else {return(plcmts_df[, plcmts_df_cols])}

  # Sort by acm_id and reset the index
  plcmts_df <- plcmts_df[order(plcmts_df$acm_id), ]
  rownames(plcmts_df) <- 1:nrow(plcmts_df)
  
  # make the swap
  plcmts_df$placement <- replace(plcmts_df$placement, c(swap1, swap2), plcmts_df$placement[c(swap2, swap1)])
  
  # return with original columns
  return(plcmts_df[, plcmts_df_cols])
}

calculate_score <- function(team_placements_df, school_targets, score_factors, gender_target=gender_g) {
  # Merge  with school_df to pull in school characteristics
  team_placements_df <- merge(team_placements_df, school_targets, by.x = "placement", by.y = "sch_id", all.x = TRUE)
  
  # Store each score in a list
  scores = list()
  
  # COMMUTE SCORE:
  if(score_factors$commute_factor > 0){
    team_placements_df$id_dest <- paste(team_placements_df$Full.Name, team_placements_df$School, sep = "_")
    scores$commute_score <- dt_commutes[id_dest %in% team_placements_df$id_dest, mean((Time.Mins^2), na.rm = TRUE)] * 3.5 * score_factors$commute_factor
    #scores$commute_score <- dt_commutes[id_dest %in% team_placements_df$id_dest, sum((Time.Mins), na.rm = TRUE)] * commute_factor
  } else { scores$commute_score <- 0 }
  
  # AGE SCORE: This score is the difference between the [overall age variance across the corps] and [overall average of each team's average age variance]
  if(score_factors$age_factor > 0){
    age_var <-team_placements_df %>%
      filter(!is.na(Age)) %>%
      group_by(placement) %>%
      summarize(age_var = var(Age)) %>%
      ungroup() %>%
      summarize(avg_age_var = mean(age_var))
    scores$age_score <- abs(age_var$avg_age_var - var(team_placements_df$Age)) /100 * score_factors$age_factor
  } else {scores$age_score <- 0}

  # ETHNICITY SCORE: This score is the overall average of each team's average % representation of members' ethnicities. 
  # For example, 0.44 means that for the average team, the average teammate experiences that his/her personal ethnicity is represented in 44% of the team.
  if(score_factors$ethnicity_factor > 0){
    ethnicity_eths <- 
      team_placements_df[!is.na(team_placements_df$Race.Ethnicity),] %>%
      group_by(placement, 
               Race.Ethnicity) %>%
      summarize(n_eths = n()) %>%
      group_by(placement) %>%
      mutate(lgst_eth_rep = max(n_eths/sum(n_eths))) %>%
      distinct(lgst_eth_rep)
    
    scores$ethnicity_score <- sum((ethnicity_eths$lgst_eth_rep*100)^1.5) * score_factors$ethnicity_factor
  } else {scores$ethnicity_score <- 0}

  # IJ CONFLICT SCORE
  if(score_factors$preserve_ij_factor > 0){
    ij_conflict_score <- team_placements_df %>%
      group_by(placement) %>%
      count(School.Placement) %>%
      filter(n>1)
    scores$ij_conflict_score <- sum(ij_conflict_score$n) * 100 * score_factors$preserve_ij_factor
  } else {scores$ij_conflict_score <- 0}
  
  # Scoring
  placed <- team_placements_df %>%
                group_by(placement) %>%
                summarise(HS_Grads = sum(Ed_HS),
                          SomeCol = sum(Ed_SomeCol),
                          Tutoring = sum(HasTutored),
                          Spanish = sum(SpanishAble),
                          #OtherLang = sum(Lang_Other),
                          MathAble = sum(Math.Confidence),
                          Males = sum(Male)) %>%
                left_join(., school_targets, by=c("placement" = "sch_id"))
  
  # Educational Attainment Score
  if(score_factors$Edscore_factor > 0) {
    scores$Edscore <- mean((abs(placed$HSGrad_tgt - placed$HS_Grads) + abs(placed$SomeCol_tgt - placed$SomeCol))^2.2) * 200 * score_factors$Edscore_factor
  } else {scores$Edscore <- 0}
  
  if(score_factors$Tutoring_factor > 0){
    scores$Tutoring <- sum((placed$TutExp - placed$Tutoring)^2) * score_factors$Tutoring_factor} 
  else{scores$Tutoring <- 0}
  
  if(score_factors$Spanish_factor > 0){
    placed$SpanDiff <- placed$SpanishNeed - placed$Spanish
    scores$Spanish <- sum(placed$SpanDiff[placed$SpanDiff>0])^1.2 * 1000 * score_factors$Spanish_factor
  } else {scores$Spanish <- 0}
  
  if(score_factors$Math_factor > 0) {
    scores$Math <- sum((placed$Math_tgt - placed$MathAble)^2) * score_factors$Math_factor}
  else {scores$Math <- 0}
  
  # Gender Score
  if(score_factors$gender_factor > 0){
    scores$Gender_score <- (sum(ifelse(placed$Males < 1, 1e10, 0)) + mean((placed$Male_tgt - placed$Males)^2) * 250) * score_factors$gender_factor
  } else {scores$Gender_score <- 0}
  
  scores$aggr_score <- sum(unlist(scores))

  return(scores)
}

#' Temperature Function
current_temperature <- function(iter, s_curve_amplitude, s_curve_center, s_curve_width) {
  s_curve_amplitude * s_curve(iter, s_curve_center, s_curve_width)
}

s_curve <- function(x, center, width) {
  1 / (1 + exp((x - center) / width))
}

#' Annealing and Swap Function
# TODO: If Spanish speaker randomly chosen for placement, only consider swaps with other Spanish speakers, unless the chosen ACM is already at a school with a surplus of Spanish speakers, in which case they may be placed anywhere
run_intermediate_annealing_process <- function(starting_placements, school_df, best_placements=starting_placements, number_of_iterations, center_scale, width_scale) {
  
  team_placements_df <- starting_placements
  
  # Sort by acm_id so that each row index will equal acm_id
  team_placements_df <- team_placements_df[order(team_placements_df$acm_id), ]
  rownames(team_placements_df) <- 1:nrow(team_placements_df)
  
  placement_score <- calculate_score(starting_placements, school_df, score_factors)$aggr_score
  best_score <- 1000000000000

  trace <- data.frame(iter=c(1:(number_of_iterations+2)),
                      commute_score = 0,
                      age_score = 0,
                      ethnicity_score= 0,
                      ij_conflict_score = 0,
                      Edscore = 0,
                      Tutoring= 0,
                      Spanish = 0,
                      Math = 0,
                      Gender_score = 0,
                      score=0)

  trace[1, 2:11] <- calculate_score(starting_placements, school_df, score_factors)

  for(i in 1:number_of_iterations) {
    iter = 1 + i
    temp = current_temperature(iter, 3000, number_of_iterations * center_scale, number_of_iterations * width_scale)

    # Create a copy of team_placements_df
    cand_plcmts_df <- team_placements_df

    # Randomly select ACM to swap
    swap1 <- sample(cand_plcmts_df$acm_id[is.na(cand_plcmts_df$Manual.Placement)], 1)
    # TODO: If score_factors$Spanish_factor==1 & cand_plcmts_df$SpanishAble==1, limit swaps to other spanish speakers, (but if isn't spanish speaker, don't allow swaps with Spanish speakers)

    cand_plcmts_df <- make_swap(cand_plcmts_df, swap1, elig_plc_schwise_df, elig_plc_acmwise_df)

    candidate_score <- calculate_score(cand_plcmts_df, school_df, score_factors)

    if (temp > 0) {
      ratio <- exp((placement_score - candidate_score$aggr_score) / temp)
    } else {
      ratio <- as.numeric(candidate_score$aggr_score < placement_score)
    }

    # Used for bug testing
    if (is.na(ratio)){
      stop(paste("Something went wrong in score calculation: ", paste(candidate_score, collapse="\n")))
      return(list(placement_score=as.data.frame(placement_score),
                  candidate_score=as.data.frame(candidate_score),
                  best_placements=best_placements,
                  trace=trace))
    }

    if (runif(1) < ratio) {
      team_placements_df <- cand_plcmts_df
      placement_score <- candidate_score$aggr_score
      trace[i+1, 2:11] <- candidate_score

      if (placement_score < best_score) {
        best_placements <- team_placements_df
        best_score_diff <- candidate_score
        best_score <- best_score_diff$aggr_score
      }
    }
  }

  # Add best scores to the last row of trace
  trace[(number_of_iterations+2), 2:11] <- calculate_score(best_placements, school_df, score_factors)

  best_placements <- best_placements[order(best_placements$placement),c("acm_id", "placement")]

  return(list(best_placements=best_placements,
              best_score=best_score,
              #diff_scores=best_score_diff,
              trace=trace))
}