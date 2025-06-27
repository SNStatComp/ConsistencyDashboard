#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    shiny::fluidPage(
      shiny::h1(TITLE),
    ),
    shiny::tabsetPanel(
      id = ID_TABSET_PANEL,
      shiny::tabPanel(
        TAB_NAME_LAYER_1,
        mod_input_selectors_ui(ID_MOD_INPUT_SELECTORS, selected_group = NULL),
        mod_layer_1_ui(ID_LAYER_1)
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  golem::add_resource_path(
    "www",
    app_sys("app/www")
  )

  shiny::tags$head(
    golem::favicon(),
    golem::bundle_resources(
      path = app_sys("app/www"),
      app_title = "eurostat"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
