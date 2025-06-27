#' layer_3 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_layer_3_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    mod_render_table_ui(ns(ID_RENDER_TABLE_LAYER_3))
  )
}

#' layer_3 Server Functions
#'
#' @noRd
mod_layer_3_server <- function(id, parent_session, rv) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # nolint start
    data <- shiny::reactive({
      con <- get_db_connection()
      on.exit(DBI::dbDisconnect(con))

      get_table(con, DB_LAYER_3_TABLE) |>
        dplyr::filter(variable == rv$click_2$row$variable &&
          group_id == rv$click_1$row$group_id &&
          stat1 == rv$click_2$row$stat1 &&
          stat2 == rv$click_2$row$stat2 &&
          period == rv$selected_period &&
          group_type == rv$selected_group_type) |>
        dplyr::arrange(dplyr::desc(score)) |>
        dplyr::select(-dplyr::any_of(COLUMNS_TO_DESELECT)) |>
        dplyr::collect()
      # nolint end
    })

    # nolint start
    subsidiary_data <- shiny::reactive({
      data <- data()
      con <- get_db_connection()
      on.exit(DBI::dbDisconnect(con))

      get_table(con, DB_LAYER_3_SUBSIDIARY_TABLE) |>
        dplyr::filter(parent_id %in% data$unit_id &&
          parent_type %in% data$unit_type &&
          variable == rv$click_2$row$variable &&
          period == rv$selected_period &&
          stat %in% c(rv$click_2$row$stat1, rv$click_2$row$stat2)) |>
        dplyr::collect()
    })
    # nolint end

    on_click <- function(click_info) {
      rv$click_3 <- click_info
    }

    default_coldef <- LOCALES_COLDEF
    coldef <- list(score = COLOR_COLDEF)

    mod_render_table_server(
      id = ID_RENDER_TABLE_LAYER_3,
      parent_ns = ns,
      data = data,
      subsidiary_data = subsidiary_data,
      on_click = on_click,
      default_coldef = default_coldef,
      coldef = coldef
    )
  })
}
