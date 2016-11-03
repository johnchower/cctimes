#' Delete single-page content.
#'
#' @param tn A data frame: (tree_id, node_count).  
#' @param cc A data frame  of content completion/conversion times.
#' @return A data table of content completion/conversion times, minus all
#' trees with a single page only.
#' @import data.table
#' @export

delete_single_pagers <- function(tn = treeid_nodecount
                                 , cc = content_completion){
  tn <- data.table::as.data.table(tn)
  data.table::setkey(tn, id)

  cc <- data.table::as.data.table(cc)
  data.table::setkey(cc, tree_id)

  tn[
    cc
    , .(tree_id, user_id, date, state, node_count)
  ][
    node_count > 1
    , .(tree_id, user_id, date, state, node_count)
  ]
}

#' Identify events when content changes state.
#' 
#' @param ccc A data frame of content completion times. The result of calling
#' cctimes::delete_single_pagers.
#' @return A data table: (user_id, tree_id, date, state, statediff).
#' @importFrom magrittr %>%
#' @export

calculate_state_changes <- function(ccc = content_completion_clean){
  ccc %>%
    dplyr::group_by(user_id, tree_id) %>%
    dplyr::arrange(state, date) %>%
    dplyr::mutate(statediff = c(3, diff(state))) %>%
    {dplyr::ungroup(.)} %>%
    dplyr::filter(statediff > 0) %>%
    dplyr::arrange(user_id, tree_id, date) %>%
    {data.table::as.data.table(.)}
    
#   state_changes <- as.data.table(ccc)
#   state_changes[
#     order(state, date)
#     , .SD[
#         , .(
#             date
#             , state
#             , statediff = c(3, diff(state))
#           )
#     ]
#     , by = c('user_id', 'tree_id')
#   ]
}

#' Calculate content progress times. 
#'
#' @param sc A data table: (user_id, tree_id, date, state, statediff).
#' The result of calling cctimes::calculate_state_changes.
#' @return A data table: (user_id, tree_id, start_date, conversion_date,
#' completion_date, start_to_conversion, conversion_to_completion).
#' @importFrom magrittr %>%
#' @export

calculate_cp_times <- function(sc = state_changes){
  sc %>%
      dplyr::group_by(user_id, tree_id) %>%
      dplyr::summarise(
          start_date = date[statediff == 3]
          , jumps = any(statediff == 2)
          , conversion_date = 
              ifelse(
                  !jumps
                  , date[statediff == 1 & state ==1]
                  , date[statediff == 2 & state ==2]
              )
          , completion_date = 
              ifelse(
                  sum(statediff == 1 & state == 2) == 0
                  , NA
                  , date[statediff == 1 & state == 2]
              )
      ) %>%
      dplyr::mutate(conversion_date = 
                 ifelse(
                     is.na(conversion_date) & !is.na(completion_date)
                     , completion_date
                     , conversion_date
      )) %>%
      dplyr::mutate(completion_date = as.Date(completion_date
                                       , origin = '1970-01-01')
             , conversion_date = as.Date(conversion_date
                                         , origin = '1970-01-01'))  %>%
      dplyr::select(user_id, tree_id, start_date, conversion_date, completion_date) %>%
      dplyr::mutate(start_to_conversion = conversion_date - start_date
             , conversion_to_completion = completion_date - conversion_date) %>%
      {data.table::as.data.table(.)}
}

#' Calculate 'made it' score.
#'
#' @param cpt A data table - the result of calling cctimes::calculate_cp_times
#' @return A data table (user_id, tree_id, date_type,
#' content_progress_date, made_it) that tells us if the appropriate type of
#' content progress was achieved within 30 days.
#' @importFrom magrittr %>%
#' @export

calculate_made_it_score <- function(cpt = cp_times){
  cpt %>%
    dplyr::mutate(converted_30 = start_to_conversion <= 30 & !is.na(start_to_conversion)
           , completed_30 = conversion_to_completion <= 30 & !is.na(conversion_to_completion)) %>%
    dplyr::select(user_id, tree_id, start_date, conversion_date, converted_30, completed_30) %>%
    reshape2::melt(id.vars = c('user_id', 'tree_id', 'converted_30', 'completed_30')
                   , value.name = 'content_progress_date'
                   , variable.name = 'date_type') %>%
    dplyr::mutate(made_it = ifelse(
        date_type == 'start_date'
        , converted_30
        , completed_30
    )) %>%
    dplyr::select(-converted_30, -completed_30) %>%
    dplyr::filter(!is.na(content_progress_date)) %>%
    {data.table::as.data.table(.)}
}
