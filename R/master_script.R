#' @title The parent script of the DSMC project
#' 
#' @name master_script
#' 
#' @description 
#' This script is responsible for running the DSMC report. 
#' This project is being adapted to a package, which will be available at \url{https://github.com/jclutton/dsmreport}
#' Written by Jon Clutton
#' Copyright at University of Kansas 2023
#' 
#' @section Instructions: 
#' This code will require some editing on the user's part. 
#' \enumerate{
#'   \item Be sure to review the instructions at \url{https://github.com/jclutton/DSMC}
#'   \item Edit the information in this script. Any info that needs to be edited has EDIT in the comments.
#' }
#' 

#### EDIT - Edit These to match your needs ####
redcap_uri <- ''
token <- ''

#### EDIT - Unique identifier name - Edit this for each project####
unique_identifier <- 'record_id'

#Do NOT edit anything about the api_info vector
api_info <- c('redcap_uri', 'token', 'unique_identifier', 'date_of_last_report')

#### EDIT - Directories ####
# Please edit the root path and the drive_dir to match your need
if(Sys.info()['sysname']=="Windows"){ 
  root <- file.path('C:')
} else {
  error("This drive has not been set up yet.")
}

#EDIT - This should be the path to where you saved the DSMC project i.e. C:/Users/user/Documents
drive_dir <- file.path(root,'Users','jclutton','Documents')


#### Drives - Do NOT EDIT THESE #####
project_dir <- file.path(drive_dir,'DSMC')
  script_dir <- file.path(project_dir,'R')
  data_dir <- file.path(project_dir,'data')
    raw_data_dir <- file.path(data_dir,'raw')
    output_data_dir <- file.path(data_dir,'output')
    codebook_dir <- file.path(data_dir,'codebooks')
    dsmc_dir <- file.path(data_dir,'dsmc_report')
      ppt_destination <- file.path(dsmc_dir,'tables_as_ppt')
      
drives <- c('root','drive_dir','script_dir','data_dir','raw_data_dir','output_data_dir',
            'dsmc_dir','ppt_destination', 'codebook_dir')


    
#Do NOT EDIT
#### Libraries ####
#Project wide packages
packages <- c('tidyverse','openxlsx','rio','flextable',
              'gtsummary','officedown','officer',
              'REDCapR','janitor','knitr')

#DO NOT EDIT
#Check what has been installed
my_packages <- as.data.frame(installed.packages()[ , c(1, 3:4)]) 

packages_to_install <- packages[which(!packages %in% my_packages$Package)]

#DO NOT EDIT
#Install missing packages
if(length(packages_to_install)>0){
  for(i in 1:length(packages_to_install)){
    install.packages(packages_to_install[i])
  }
}

#DO NOTE EDIT
#Load Packages
lapply(packages, require, character.only = TRUE)

#### EDIT - When was the date of the last DSM Meeting? ####
#If this is the first report, change this to NA
#If this is a repeat dsm meeting, change the date in quotes to match the date of the last meeting
date_of_last_report <- ymd('20231001')

#DO NOT EDIT
#### Save All Necessary Info for Markdown ####
save(packages, file = file.path(dsmc_dir,'packages.Rdata'))
save(list = drives, file = file.path(dsmc_dir,'drives.Rdata'))
save(list = api_info, file = file.path(dsmc_dir,'api_info.Rdata'))


#### Knit Markdown documents ####
rmarkdown::render(input = file.path(data_dir,"dsmc_report","dsmc_report_open.Rmd"), output_file = file.path(output_data_dir,"dsmc_report_open.docx")) 
rmarkdown::render(input = file.path(data_dir,'dsmc_report','dsmc_report_closed.Rmd'), output_file = file.path(output_data_dir,'dsmc_report_closed.docx'))
