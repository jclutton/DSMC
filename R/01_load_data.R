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

#### Get last DSMC Date ####
dsmc_date_file <- file.path(data_dir,'codebooks','dsmc_dates.csv')
if(!file.exists(dsmc_date_file)){
  dsmc_dates <- data.frame()
  last_date <- NA_Date_
} else {
  dsmc_dates <- import(dsmc_date_file)
  last_date <- last(dsmc_dates$Date)
}

#' 20231121: Writted by BH, edited by JC. 
# get_last_date function
get_last_date <- function(last_dates){
  cat(sprintf("The date we have for the last DSMC meeting is: %s\n\n", format(last_date, "%B %d, %Y")))
  choice <- utils::menu(title = "Is this still correct?", choices = c("No", "Yes"))
  if(choice == 1){
    switch = 0
    while(switch == 0){
      last_date <- readline(prompt = "Please enter the date (mm/dd/yyyy) of the last DSMC meeting: ")
      last_date <- 
        last_sync <- tryCatch(
          as.Date(last_date, tryFormats = c("%m/%d/%Y",
                                            "%m/%d/%y",
                                            "%m-%d-%Y",
                                            "%m-%d-%y",
                                            "%m%d%Y")),
          error = function(e) 
          {e
            cat("There was an error reading your date. Please be sure it is formatted correctly.")
            switch <- 0
          }
        )
      
      if(lubridate::is.Date(last_date) & !is.na(last_date)) {
        switch <- 1
        
      }
    }
  }
  return(last_date)
}

# Save last date into a file
last_date <- get_last_date(last_date)

# update dsmc dates
dsmc_dates <- add_row(dsmc_dates, Date = last_date)

#export dsmc_date_file
export(dsmc_dates, file = dsmc_date_file)






