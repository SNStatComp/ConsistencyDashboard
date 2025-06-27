#' input_selectors UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_input_selectors_ui <- function(id, selected_group = NULL) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 2,
        shiny::uiOutput(ns("select_period_ui"))
      ),
      if (is.null(selected_group)) {
        shiny::column(
          width = 2,
          shiny::uiOutput(ns("select_group_type_ui"))
        )
      } else {
        shiny::column(
          width = 2,
          shiny::br(),
          shiny::strong("Selected group:"),
          shiny::p(selected_group)
        )
      }
    )
  )
}

#' input_selectors Server Functions
#'
#' @noRd
mod_input_selectors_server <- function(id, session, rv) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns # nolint

    options <- get_unique_column_values_in_table(
      DB_SCHEMA, DB_LAYER_1_TABLE, c(SELECT_PERIOD_NAME, SELECT_GROUP_NAME)
    )

    output$select_period_ui <- shiny::renderUI({
      shiny::selectInput(
        ns(ID_SELECT_PERIOD),
        SELECT_PERIOD_NAME,
        options$period
      )
    })

    output$select_group_type_ui <- shiny::renderUI({
      shiny::selectInput(
        ns(ID_SELECT_GROUP),
        SELECT_GROUP_NAME,
        options$group_type
      )
    })

    shiny::observe({
      rv$selected_period <- input$select_period
      rv$selected_group_type <- input$select_group_type
    })
  })
}
