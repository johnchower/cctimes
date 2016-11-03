rm(list = ls())
library(dplyr)
library(data.table)
glootility::connect_to_lookr()
glootility::connect_to_postgres()

# .data_list <- cctimes::pull_data()
 
data_list <- .data_list 

x <- data_list %>%
  names %>%
  lapply(FUN = function(name){
    data <- data_list[[name]]
    assign(name, data, envir = globalenv())
  })
rm(x) 

content_completion_clean <- cctimes::delete_single_pagers()
state_changes <- cctimes::calculate_state_changes()
cp_times <- cctimes::calculate_cp_times() 
made_it_scores <- cctimes::calculate_made_it_score()
