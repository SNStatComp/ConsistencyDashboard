#' render_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_render_table_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    reactable::reactableOutput(ns(ID_RENDER_TABLE))
  )
}

#' render_table Server Functions
#'
#' @description Server logic for the render_table module.
#'
#' @param id Module id
#' @param parent_ns Namespace function from parent module (usually session$ns)
#' @param data Data to display in the table
#' @param on_click Callback function to handle clicks,
#' receives a list with 'column' and 'row'
#' @param default_coldef Default column definitions for the reactable table
#' @param coldef Specific column definitions for the reactable table
#' @noRd
mod_render_table_server <- function(id,
                                    parent_ns,
                                    data,
                                    subsidiary_data = NULL,
                                    on_click,
                                    default_coldef,
                                    coldef
                                    ) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns # nolint

    show_details <- function(index) {
      clicked_row <- data()[index, ]

      detail_data <- subsidiary_data() |>
         dplyr::filter(parent_id == clicked_row$unit_id) |>
         dplyr::select(-dplyr::any_of(COLUMNS_TO_DESELECT))

       htmltools::div(style = "padding: 1rem; margin-left: 15rem; margin-right: 50rem;",
                      reactable::reactable(detail_data,
                                           compact = TRUE,
                                           outlined = TRUE,
                                           striped = TRUE,
                                           defaultColDef = LOCALES_COLDEF,
                                           fullWidth = TRUE,
                                           columns = list(
                                             period = reactable::colDef(show = FALSE),
                                             parent_type = reactable::colDef(show = FALSE),
                                             parent_id = reactable::colDef(show = FALSE),
                                             variable = reactable::colDef(show = FALSE)
                                             )
                                           )
      )
    }

    output$table <- reactable::renderReactable({
      if (is.null(subsidiary_data) || nrow(subsidiary_data()) == 0) show_details <- NULL

      reactable::reactable(
        data(),
        defaultColDef = default_coldef,
        onClick = get_js_click(parent_ns(id)),
        columns = coldef,
        details = show_details,
        compact = TRUE,
        defaultPageSize = 50,
      )
    })

    shiny::observeEvent(
      input$table_click,
      {
        if (
          !is.null(input$table_click) && !is.null(input$table_click$column_name)
        ) {
          tryCatch(
            on_click(
              list(
                column = input$table_click$column_name,
                row = input$table_click$row,
                timestamp = input$table_click$timestamp
              )
            ),
            error = function(e) {
              message("Error in on_click callback: ", conditionMessage(e))
            }
          )
        }
      },
      ignoreInit = TRUE
    )
  })
}
