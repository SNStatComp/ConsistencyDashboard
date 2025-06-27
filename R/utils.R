#' get connection to database
#'
#' @param server_address server address
#' @param database database name
#' @param username username to be used to login to the database
#' @param password password to be used to login to the database
#' @param db_driver sql db driver to be used to setup connection to database
#' @param sqlite_path sqlite path when using a local db
#'
#' @return a connection object to the specified database
get_db_connection <- function(
    server_address = DB_SERVER,
    database = DB_DATABASE,
    username = DB_USERNAME,
    password = DB_PASSWORD,
    db_driver = DB_DRIVER,
    sqlite_path = SQLITE_DB_PATH) {

  if (nzchar(sqlite_path)) {
    return(DBI::dbConnect(RSQLite::SQLite(), sqlite_path))
  }

  vars <- list(
    DB_SERVER = server_address,
    DB_DATABASE = database,
    DB_USERNAME = username,
    DB_PASSWORD = password,
    DB_DRIVER = db_driver
  )
  check_environment_vars(vars)

  logger::log_debug(
    sprintf("login to %s using username/password", server_address)
  )

  con <- tryCatch(
    {
      DBI::dbConnect(
        odbc::odbc(),
        Driver = db_driver,
        Server = server_address,
        UID = username,
        PWD = password,
        Database = database,
        TrustServerCertificate = "yes"
      )
    },
    error = function(e) {
      logger::log_error(conditionMessage(e))
      stop(
        sprintf(
          "Error during creating database connection: %s", conditionMessage(e)
        )
      )
    }
  )
  return(con)
}

#' javascript function for getting clicked cell in a table
#'
#' @param id cell
#'
#' @return value of clicked cell
get_js_click <- function(id, clickable_columns = NULL) {
  js_click <- sprintf(
    "function(rowInfo, column, data) {
      if (window.Shiny && rowInfo.values[column.name] !== null%s) {
        Shiny.setInputValue(
          '%s-table_click',
          {
            row: rowInfo.values,
            column_name: column.name,
            timestamp: Date.now()
          },
          { priority: 'event' }
        )
      }
    }",
    if (!is.null(clickable_columns)) {
      paste0(
        " && [",
        paste(
          sprintf("'%s'", clickable_columns),
          collapse = ","
        ), "].includes(column.name)"
      )
    } else {
      ""
    },
    id
  )
  return(htmlwidgets::JS(js_click))
}

#' Check environment vars
#' Check if the required variables are set
#' @param vars a list of environment variables
#' @return NULL if okay
#' @export
check_environment_vars <- function(vars) {
  unset <- names(vars)[vars == ""]
  if (length(unset) > 0) {
    stop(sprintf(
      "The following environment variables are not set: %s",
      paste(unset, collapse = ", ")
    ))
  }
}

#' Get a reference to a table in the configured schema
#'
#' This function returns a dplyr reference to a table.
#' When using a SQLite database, the schema is ignored.
#'
#' @param con Database connection
#' @param table Table name
#' @param schema Schema name (default: DB_SCHEMA). Ignored for SQLite.
#' @return dplyr table reference
get_table <- function(con, table, schema = DB_SCHEMA) {
  if (inherits(con, "SQLiteConnection")) {
    logger::log_debug("Using SQLite: no schema")
    return(dplyr::tbl(con, table))
  }
  logger::log_debug("Using schema: ", schema)
  return(dplyr::tbl(con, dbplyr::in_schema(schema, table)))
}
