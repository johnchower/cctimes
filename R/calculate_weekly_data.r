#' Calculate weekly progress rates.
#' 
#' @param mis A data table: the result of calling calculate_made_it_score
#' @param week_sequence A data table: (week_beginning) consisting of dates
#' spaced one week apart. The result of calling glootility::create_week_sequence.
#' tree_id, date_type, made_it)
#' @return A data table (week_beginning, date_type, pct_made_it) that indicates
#' the percentage of program starts that were converted to 'in progress' and
#' the percentage of 'in progress' that were finished within 30 days.

calculate_weekly_progress_rates <- function(mis = made_it_scores
                                            , week_sequence){
  
}
