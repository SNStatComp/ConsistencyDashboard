#' layer_4 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_layer_4_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    mod_render_table_ui(ns(ID_RENDER_TABLE_LAYER_4))
  )
}

#' layer_4 Server Functions
#'
#' @noRd
mod_layer_4_server <- function(id, parent_session, rv) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # nolint start
    data <- shiny::reactive({
      con <- get_db_connection()
      on.exit(DBI::dbDisconnect(con))

      get_table(con, DB_LAYER_4_TABLE) |>
        dplyr::filter(
          unit_type == rv$click_3$row$unit_type &&
            unit_id == rv$click_3$row$unit_id &&
          period == rv$selected_period
        ) |>
        dplyr::arrange(variable) |>
        dplyr::select(-dplyr::any_of(COLUMNS_TO_DESELECT)) |>
        dplyr::collect()
    })
    # nolint end

    default_coldef <- LOCALES_COLDEF

    mod_render_table_server(
      id = ID_RENDER_TABLE_LAYER_4,
      parent_ns = ns,
      data = data,
      on_click = function(x) {x}, # nolint
      default_coldef = default_coldef,
      coldef = NULL
    )
  })
}
