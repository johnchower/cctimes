#' Pull data from Looker and Postgres
#' 
#' @param looks Looks pointing to Looker data neccessary for this project.
#' @param queries Queries to get Postgres data
#' @return A list of data frames, each the result of a single look or query.
#' @importFrom magrittr %>%
#' @import glootility
#' @export

pull_data <- function(looks = cctimes::look_list 
                      , queries = cctimes::query_list
                      , con = postgres_connection$con){
  x <- glootility::run_look_list(look_list = looks)
  y <- glootility::run_query_list(query_list = queries, connection = con)

  x[['content_completion']] <- x[['content_completion']] %>%
    dplyr::rename(
        state = content_progress_facts.state
        , tree_id = tree_dimensions.id
        , user_id = user_dimensions.id
        , date = content_progress_facts.timestamp_date
        , id = content_progress_facts.id
    ) %>%
    dplyr::mutate(state = ifelse(
        state == 'Started'
        , 0
        , ifelse(
            state == 'In Progress'
            , 1
            , ifelse(
                state == 'Complete'
                , 2
                , NA
    )))) 

    return(c(x,y))

}

#' Create week list given a start and end date.
#'
#' @param start_date The earliest date allowed in the output.
#' @param end_date The latest date allowed in the output.
#' @param week_begins The day of the week that all output dates must fall on.
#' Given as an integer (1 = Sunday , 2 = Monday , etc...).
#' @return A data table (week_beginning) of dates that correspond to the first
#' date in each week.

create_week_list <- function(start_date = as.Date('2016-01-01')
                             , end_date = Sys.Date()
                             , week_begins = 2){
  week_0 <- seq.Date(from = start_date, to = start_date + 7, by = 1)
  day_1 <- which(lubridate::wday(week_0) == week_begins)
}
