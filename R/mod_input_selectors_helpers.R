#' Get unique column values table
#' Retrieves the unique column values for every column specified in a table.
#' @param schema database schema
#' @param table database table
#' @param columns vector of column names
#'
#' @return Returns a list of unique values in database table for
#' specified columns
#' @export
#'
#' @examples get_unique_column_values_in_table(schema = "dbo",
#'                                             table = "table",
#'                                             columns = c("period", "group"))
get_unique_column_values_in_table <- function(schema, table, columns) {
  con <- get_db_connection()
  on.exit(DBI::dbDisconnect(con))

  data <- get_table(con, table, schema = schema) |>
    dplyr::select(dplyr::all_of(c(columns))) |>
    dplyr::distinct() |>
    dplyr::collect()

  if (nrow(data) == 0) return(NULL)

  result <- as.list(data)

  for (name in names(result)) {
    result[[name]] <- unique(result[[name]])
  }

  return(result)
}