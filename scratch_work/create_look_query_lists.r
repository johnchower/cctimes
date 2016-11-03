look_list <-
    list(
        list(
            look_name = 'content_completion'
            , look_id = 2618
        )
        , list(
            look_name = 'session_duration'
            , look_id = 1064
        )
    )

devtools::use_data(look_list, look_list, overwrite = T)

query_list <-
    list(
        list(
            query_name = 'treeid_nodecount'
            , query = 'SELECT id, node_count FROM trees;' 
        )
    )

devtools::use_data(query_list, query_list, overwrite = T)
