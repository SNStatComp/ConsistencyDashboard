#' Get a color based on a numeric value
#'
#' Returns a color hex code depending on the value.
#' Used for conditional cell coloring in tables.
#'
#' @param value Numeric value to evaluate
#' @param limit_red Numeric value that represents lower bound for colour red.
#' @param limit_orange Numeric value that represents lower bound for colour orange.
#' @param colours Named list that includes hex colour code values for red, green and orange.
#' @return A color string or NULL if value is not numeric or NULL
get_colour <- function(value,
                       limit_red = LIMIT_RED,
                       limit_orange = LIMIT_ORANGE,
                       colours = COLOURS) {
  if (is.null(value) || is.na(value) || !is.numeric(value)) return(NULL)
  if (limit_red < limit_orange) stop("limit_red should be bigger than limit_orange.")

  if (value > limit_red) return(colours$red)
  if (value > limit_orange) return(colours$orange)

  return(colours$green)
}

#' Merge reactable::colDef() objects into one
#'
#' @description
#' Merges multiple `reactable::colDef()` objects into a single `reactable::colDef()` object.
#'
#' @param ... One or more `reactable::colDef()` objects. These are passed as arguments
#' to this function. Each `colDef()` object must contain uniquely named parameters.
#' Duplicate parameter names across the colDef arguments will cause an error.
#'
#' @return A single merged `reactable::colDef()` object.
#'
#' @examples
#' merge_coldefs(
#'   reactable::colDef(name = "Color", align = "center"),
#'   reactable::colDef(style = function(value) paste0("color:", value))
#' )
merge_coldefs <- function(...) {
  coldef_list <- list(...)

  # Validate: check at least one parameter is given.
  if (length(coldef_list) == 0) {
    stop("Function merge_coldefs was called with zero parameters. Must pass at least 1.")
  }

  # Flatten the named parameters from all colDefs into a single list
  combined_parameters <- do.call(c, coldef_list)

  parameter_names <- names(combined_parameters)

  # Validate: check for duplicate parameter names
  duplicate_parameters <- unique(parameter_names[duplicated(parameter_names)])
  if (length(duplicate_parameters) > 0) {
    stop(sprintf(
      "Duplicate parameter(s) found across colDef arguments: %s",
      paste(duplicate_parameters, collapse = ", ")
    ))
  }

  merged_coldef <- do.call(reactable::colDef, combined_parameters)

  return(merged_coldef)
}
