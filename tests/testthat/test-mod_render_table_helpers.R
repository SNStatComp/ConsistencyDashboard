COLOURS <- list(green = "#D3EFDE",
                orange = "#FED8B1",
                red = "#F6BDC0")

LIMIT_RED <- 0.1
LIMIT_ORANGE <- 0.05

test_that("get_colour returns NULL if non-numeric argument is given.", {
  # Assert
  expect_equal(NULL, get_colour(NA, LIMIT_RED, LIMIT_ORANGE, COLOURS))
  expect_equal(NULL, get_colour("", LIMIT_RED, LIMIT_ORANGE, COLOURS))
  expect_equal(NULL, get_colour("10", LIMIT_RED, LIMIT_ORANGE, COLOURS))
})

test_that("get_colour returns appropriate colour when numeric argument is passed", {
  # Assert
  expect_equal(COLOURS$green, get_colour(0, LIMIT_RED, LIMIT_ORANGE, COLOURS))
  expect_equal(COLOURS$orange, get_colour(0.06, LIMIT_RED, LIMIT_ORANGE, COLOURS))
  expect_equal(COLOURS$red, get_colour(2,  LIMIT_RED, LIMIT_ORANGE, COLOURS))
})

test_that("get_colour gives error when limit_red < limit_orange", {
  # Arrange
  limit_red <- 0.05
  limit_orange <- 0.1

  # Assert
  expect_error(get_colour(0.5, limit_red, limit_orange, COLOURS))
})

test_that("merge_coldefs merges multiple colDefs correctly", {
  # Arrange
  coldef_1 <- reactable::colDef(name = "Color", align = "center")
  coldef_2 <- reactable::colDef(style = function(value) paste0("color:", value))

  # Act
  merged <- merge_coldefs(coldef_1, coldef_2)

  # Assert
  expect_true(is.list(merged))
  expect_equal(merged$name, "Color")
  expect_equal(merged$align, "center")
  expect_true(is.function(merged$style))
  expect_equal(merged$style("red"), "color:red")
})

test_that("merge_coldefs errors on duplicate parameters", {
  # Arrange
  coldef_1 <- reactable::colDef(name = "Color", align = "center")
  coldef_2 <- reactable::colDef(name = "Color", align = "left")

  # Assert
  expect_error(
    merge_coldefs(coldef_1, coldef_2)
  )
})

test_that("merge_coldefs works with single colDef argument", {
  # Arrange
  coldef <- reactable::colDef(name = "Color", align = "center")

  # Act
  merged <- merge_coldefs(coldef)

  # Assert
  expect_equal(merged$name, "Color")
  expect_equal(merged$align, "center")
})

test_that("merge_coldefs returns error with zero arguments", {
  # Assert
  expect_error(merge_coldefs())
})
