#' @title DSMC Report
#' 
#' @name 03_run_report
#' 
#' @description This script will run the dsmc report for BOLD. 
#' 
#' @section Development notes:
#' 20231110: Adapting from COMET. JC
#' 

#### Save Image ####
save.image(file.path(output_data_dir,'clean_data.Rdata'))
########Render Reports ###############
rmarkdown::render(input = file.path(data_dir,"dsmc_report","dsmc_report_open.Rmd"), output_file = file.path(output_data_dir,"dsmc_report_open.docx")) 
rmarkdown::render(input = file.path(data_dir,'dsmc_report','dsmc_report_closed.Rmd'), output_file = file.path(output_data_dir,'dsmc_report_closed.docx'))




