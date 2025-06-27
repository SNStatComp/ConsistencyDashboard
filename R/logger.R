logger <- logger::layout_glue_generator(format = "{time} {level}: -> {msg}")
logger::log_layout(logger)

# Ensure directory exists
if (!dir.exists(dirname(LOGFILE_DEFAULT))) {
  dir.create(dirname(LOGFILE_DEFAULT), recursive = TRUE)
}

if (!file.exists(LOGFILE_DEFAULT)) {
  file.create(LOGFILE_DEFAULT)
}

logger::log_appender(
  logger::appender_tee(file = LOGFILE_DEFAULT, max_lines = 10e3)
)
