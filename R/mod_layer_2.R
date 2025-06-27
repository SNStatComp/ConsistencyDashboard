#' layer_2 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_layer_2_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    mod_render_table_ui(ns(ID_RENDER_TABLE_LAYER_2))
  )
}

#' layer_2 Server Functions
#'
#' @noRd
mod_layer_2_server <- function(id, parent_session, rv) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    shiny::req(rv$click_1)


    # nolint start
    data <- shiny::reactive({
      con <- get_db_connection()
      on.exit(DBI::dbDisconnect(con))

      get_table(con, DB_LAYER_2_TABLE) |>
        dplyr::filter(variable == rv$click_1$column &&
          group_type == rv$selected_group_type &&
          group_id == rv$click_1$row$group_id) |>
        dplyr::filter(period == rv$selected_period &&
          group_type == rv$selected_group_type) |>
        dplyr::arrange(stat1, stat2) |>
        dplyr::select(-dplyr::any_of(COLUMNS_TO_DESELECT)) |>
        dplyr::collect()
    })
    # nolint end

    on_click <- function(click_info) {
      rv$click_2 <- click_info
    }

    coldef <- list(max_score = COLOR_COLDEF)
    default_coldef <- LOCALES_COLDEF

    mod_render_table_server(
      id = ID_RENDER_TABLE_LAYER_2,
      parent_ns = ns,
      data = data,
      on_click = on_click,
      default_coldef = default_coldef,
      coldef = coldef
    )
  })
}
