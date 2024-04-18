#' @title The parent script of the BOLD project
#' 
#' @name master_script
#' 
#' @description 
#' This script is responsible for running the BOLD DSMC report. 
#' Written by Jon Clutton
#' Copyright @ University of Kansas 2023
#' 
#' @section Development:
#' 20231110: Began development. JC

#### Libraries ####
#Project wide packages
packages <- c('tidyverse','openxlsx','rio','flextable',
              'gtsummary','officedown','officer')

#Check what has been installed
my_packages <- as.data.frame(installed.packages()[ , c(1, 3:4)]) 

packages_to_install <- packages[which(!packages %in% my_packages$Package)]

#Install missing packages
if(length(packages_to_install)>0){
  for(i in 1:length(packages_to_install)){
    install.packages(packages_to_install[i])
  }
}

#Load Packages
lapply(packages, require, character.only = TRUE)

#### Directories ####
if(Sys.info()['user']=="vidon"){ #Eric's computer
  root <- #setup this drive for your project
} else if(Sys.info()['sysname']=="Windows"){ #Jon's computer
  root <- #Setup this drive for your project
} else {
  error("This drive has not been set up yet.")
}

drive_dir <- #Setup this drive for your project

project_dir <- file.path(drive_dir,'DSMC')
  script_dir <- file.path(project_dir,'R')
  data_dir <- file.path(project_dir,'data')
    raw_data_dir <- file.path(data_dir,'raw')
    output_data_dir <- file.path(data_dir,'output')


script_order <- c('01_load_data.R',
                  '02_clean_merge.R',
                  '03_run_report.R')

for(i in 1:length(script_order)){
  
  source(file.path(script_dir,script_order[i]))
}
