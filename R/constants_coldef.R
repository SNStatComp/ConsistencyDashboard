COLOR_COLDEF <- reactable::colDef(
  style = function(value) {
    color <- get_colour(value)
    list(background = color)
  }
)

LOCALES_COLDEF <- reactable::colDef(
  format = reactable::colFormat(locales = LOCALES, separators = TRUE)
)
