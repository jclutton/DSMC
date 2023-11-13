#' @title Clean, and merge
#' 
#' @name clean_merge
#' 
#' @description This script is being adapted from COMET to fit the BOLD project. 
#' 
#' @author Jon Clutton
#' 
#' @section Copyright:
#' Copyright @ University of Kansas 2023 
#' 
#' 
#' @section Saved Project-wide Dataframes \cr
#' 
#' 
#' 
#' @section Development notes:
#' 20231111: Began development

#### Prep Data Dictionary ####
date_fields <- data_dictionary %>% 
  filter(grepl("date",.$`Text Validation Type OR Show Slider Number`)) %>%
  pull(`Variable / Field Name`)

date_mdy <- data_dictionary %>%
  filter(.$`Text Validation Type OR Show Slider Number` == "date_mdy") %>%
  pull(`Variable / Field Name`)

datetime_seconds_mdy <- data_dictionary %>%
  filter(.$`Text Validation Type OR Show Slider Number` == "datetime_seconds_mdy") %>%
  pull(`Variable / Field Name`)

datetime_mdy <- data_dictionary %>%
  filter(.$`Text Validation Type OR Show Slider Number` == "datetime_mdy") %>%
  pull(`Variable / Field Name`)

#### Project wide, cleaned BOLD data frame ####
bold <- redcap %>%
  mutate(age = floor(lubridate::time_length(difftime(mdy(scrn_date), mdy(scrn_dob)), "years"))) %>%
  mutate(scrn_race___1 = 1*scrn_race___1) %>%
  mutate(scrn_race___2 = 2*scrn_race___2) %>%
  mutate(scrn_race___4 = 4*scrn_race___4) %>%
  mutate(scrn_race___8 = 8*scrn_race___8) %>%
  mutate(scrn_race___16 = 16*scrn_race___16) %>%
  mutate(scrn_race___32 = 32*scrn_race___32) %>%
  mutate(scrn_race___64 = 64*scrn_race___64) %>%
  mutate(scrn_race___256 = 256*scrn_race___256) %>%
  mutate(race_added = (scrn_race___1 + scrn_race___2 + scrn_race___4 + scrn_race___8 + scrn_race___16 + scrn_race___32 + scrn_race___64 + scrn_race___256)) %>%
  mutate(race = case_when(race_added == 0 ~ NA_character_,
                          race_added == 1 ~ "White",
                          race_added == 2 ~ "Black, African American, or African",
                          race_added == 4 ~ "Asian",
                          race_added == 8 ~ "American Indian or Alaska Native",
                          race_added == 16 ~ "Native Hawaiian or Other Pacific Islanders",
                          race_added == 32 ~ "None of these fully describe me",
                          race_added == 64 ~ "Prefer not to answer",
                          race_added == 256 ~ "Middle Eastern or North African",
                          is.na(race_added) ~ NA_character_,
                          TRUE ~ "Mixed Race")) %>%
  mutate(sex = case_when(scrn_sex == 1 ~ "Man",
                            scrn_sex == 2 ~ "Woman",
                            TRUE ~ NA_character_)) %>%
  mutate(ethnicity  = dplyr::recode(scrn_ethn,
                                    `2` = "Hispanic or Latino",
                                    `1` = "Not Hispanic or Latino",
                                    `-1`= "Refused",
                                    .default = "Other - need to update")) %>%
  mutate_at(vars(any_of(date_fields)), ~ymd(.)) 



