# nolint start
# Database
DB_SCHEMA <- Sys.getenv("DB_SCHEMA")
DB_SERVER <- Sys.getenv("DB_SERVER")
DB_DATABASE <- Sys.getenv("DB_DATABASE")
DB_USERNAME <- Sys.getenv("DB_USERNAME")
DB_PASSWORD <- Sys.getenv("DB_PASSWORD")
DB_DRIVER <- Sys.getenv("DB_DRIVER")
SQLITE_DB_PATH <- Sys.getenv("SQLITE_DB_PATH")

# General
TITLE <- "Consistency Dashboard"
ID_TABSET_PANEL <- "tabsetpanel"
LOGFILE_DEFAULT <- file.path("logs", "log.txt")

# Layers
DB_LAYER_1_TABLE <- "layer1"
DB_LAYER_2_TABLE <- "layer2"
DB_LAYER_3_TABLE <- "layer3"
DB_LAYER_3_SUBSIDIARY_TABLE <- "layer3_subsidiary"
DB_LAYER_4_TABLE <- "layer4"

TAB_NAME_LAYER_1 <- "Layer 1"
TAB_NAME_LAYER_2 <- "Layer 2"
TAB_NAME_LAYER_3 <- "Layer 3"
TAB_NAME_LAYER_4 <- "Layer 4"

ID_LAYER_1 <- "layer_1"
ID_LAYER_2 <- "layer_2"
ID_LAYER_3 <- "layer_3"
ID_LAYER_4 <- "layer_4"

# Mod input selectors
ID_MOD_INPUT_SELECTORS <- "select_inputs"
ID_SELECT_PERIOD <- "select_period"
ID_SELECT_GROUP <- "select_group_type"

# Mod render table
ID_RENDER_TABLE <- "table"
ID_RENDER_TABLE_LAYER_1 <- "render_table_layer_1"
ID_RENDER_TABLE_LAYER_2 <- "render_table_layer_2"
ID_RENDER_TABLE_LAYER_3 <- "render_table_layer_3"
ID_RENDER_TABLE_LAYER_4 <- "render_table_layer_4"

# Unclickable columns
UNCLICKABLE_COLUMNS_LAYER_1 <- c("group_id")

# Locales
LOCALES <- "nl-NL"

# Colours
COLOURS <- list(
  green = "#D3EFDE",
  orange = "#FED8B1",
  red = "#F6BDC0"
)

# Thresholds
LIMIT_RED <- 0.1
LIMIT_ORANGE <- 0.05
LIMIT_GREEN <- 0

# Input names must be column names
SELECT_PERIOD_NAME <- "period"
SELECT_GROUP_NAME <- "group_type"

COLUMNS_TO_DESELECT <- c(
    SELECT_PERIOD_NAME,
    SELECT_GROUP_NAME,
    "timestamp"
)
# nolint end
