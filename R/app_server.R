#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  rv <- shiny::reactiveValues(
    click_1 = NULL,
    click_2 = NULL,
    click_3 = NULL,
    selected_period = NULL,
    selected_group_type = NULL
  )

  mod_layer_1_server(ID_LAYER_1, session, rv)
  mod_input_selectors_server(ID_MOD_INPUT_SELECTORS, session, rv)

  shiny::observeEvent(rv$click_1, {
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_4, session = session)
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_3, session = session)
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_2, session = session)
    shiny::insertTab(
      ID_TABSET_PANEL,
      shiny::tabPanel(
        TAB_NAME_LAYER_2,
        mod_input_selectors_ui(
          ID_MOD_INPUT_SELECTORS, selected_group = rv$selected_group_type
        ),
        mod_layer_2_ui(ID_LAYER_2)),
      session = session, select = TRUE
    )
    mod_layer_2_server(ID_LAYER_2, session, rv)
  }, ignoreInit = TRUE)

  shiny::observeEvent(rv$click_2, {
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_4, session = session)
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_3, session = session)
    shiny::insertTab(
      ID_TABSET_PANEL,
      shiny::tabPanel(
        TAB_NAME_LAYER_3,
        mod_input_selectors_ui(
          ID_MOD_INPUT_SELECTORS, selected_group = rv$selected_group_type
        ),
        mod_layer_3_ui(ID_LAYER_3)),
      session = session, select = TRUE
    )
    mod_layer_3_server(ID_LAYER_3, session, rv)
  }, ignoreInit = TRUE)

  shiny::observeEvent(rv$click_3, {
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_4, session = session)
    shiny::insertTab(
      ID_TABSET_PANEL,
      shiny::tabPanel(
        TAB_NAME_LAYER_4,
        mod_input_selectors_ui(
          ID_MOD_INPUT_SELECTORS, selected_group = rv$selected_group_type
        ),
        mod_layer_4_ui(ID_LAYER_4)),
      session = session, select = TRUE
    )
    mod_layer_4_server(ID_LAYER_4, session, rv)
  }, ignoreInit = TRUE)

  # Close other layers when the group_type changes
  shiny::observeEvent(rv$selected_group_type, {
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_2, session = session)
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_3, session = session)
    shiny::removeTab(ID_TABSET_PANEL, TAB_NAME_LAYER_4, session = session)
    rv$click_1 <- NULL
    rv$click_2 <- NULL
    rv$click_3 <- NULL
  }, ignoreInit = TRUE)
}
