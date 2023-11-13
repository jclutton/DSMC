#' @title Load Data
#' 
#' @name load_data
#' 
#' @include master_script
#' 
#' @description 
#' This script loads data for the BOLD DSMC project. 
#' 
#' @section Development:
#' 20231110: Began development JC
 


message("Began 01_load_data.R")
#### Import REDCap data ####
#Need to figure out workflow
redcap_file <- list.files(path = raw_data_dir,
                         pattern = "DATA",
                         full.names = T)

redcap <- import(redcap_file)


#### Import Data Dictionary ####
data_dict_file <- list.files(path = raw_data_dir,
                             pattern = "dictionary",
                             full.names = T)
data_dictionary <- import(data_dict_file)

#### Convert Data Dictionary into Join Table ####
look_up_table <- data_dictionary %>%
  filter(`Field Type` %in% c("radio","dropdown")) %>%
  rename(field = `Variable / Field Name`, choices = contains("Choices")) %>%
  select(field, choices) %>%
  separate(choices, into = as.character(1:25), sep = "[|]")  %>%
  pivot_longer(cols = -field) %>%
  filter(!is.na(value)) %>%
  separate(value, into = c("id_num","id_name"), sep = "[,]")  %>%
  select(field, id_num, id_name)  %>%
  mutate(id_num = as.numeric(trimws(id_num)))

#### Load semester codebook ####
semester_file <- file.path(data_dir,'codebooks','bi-annual_periods.xlsx')
semesters <- import(semester_file)
