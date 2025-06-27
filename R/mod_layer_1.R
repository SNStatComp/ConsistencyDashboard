#' layer_1 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_layer_1_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    mod_render_table_ui(ns(ID_RENDER_TABLE_LAYER_1))
  )
}

#' layer_1 Server Functions
#'
#' @noRd
mod_layer_1_server <- function(id, parent_session, rv) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # nolint start
    data <- shiny::reactive({
      req(c(rv$selected_period,
            rv$selected_group_type))

      con <- get_db_connection()
      on.exit(DBI::dbDisconnect(con))
      get_table(con, DB_LAYER_1_TABLE) |>
        dplyr::filter(period == rv$selected_period &&
                      group_type == rv$selected_group_type) |>
        dplyr::arrange(group_id) |>
        dplyr::select(-dplyr::any_of(COLUMNS_TO_DESELECT)) |>
        dplyr::collect()
    })
    # nolint end

    on_click <- function(click_info) {
      if (click_info$column %in% UNCLICKABLE_COLUMNS_LAYER_1) return()
      rv$click_1 <- click_info
    }

    default_coldef <- merge_coldefs(COLOR_COLDEF, LOCALES_COLDEF)

    mod_render_table_server(
      id = ID_RENDER_TABLE_LAYER_1,
      parent_ns = ns,
      data = data,
      on_click = on_click,
      default_coldef = default_coldef,
      coldef = NULL
    )
  })
}
