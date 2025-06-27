# ConsistencyDashboard

This repository contains a Shiny application for analyzing and visualizing Eurostat data.
The application is built as an R package using the [golem](https://github.com/ThinkR-open/golem) framework,
ensuring modularity, scalability, and ease of deployment.

This package is not maintained and comes 'as is'

## Features

- Modular Shiny app structure for maintainability and scalability
- Database connectivity using environment variables for secure configuration
- Multi-layered data visualization and interaction
- Customizable UI with external resources (JS/CSS)
- Automated testing and CI/CD integration
- Ready for deployment on RStudio Connect, Shiny Server, Docker, and more

## Getting Started

### Prerequisites

- R (>= 4.0.0)
- [golem](https://github.com/ThinkR-open/golem)
- [shiny](https://shiny.rstudio.com/)
- [DBI](https://cran.r-project.org/package=DBI), [odbc](https://cran.r-project.org/package=odbc)
- Other dependencies listed in `DESCRIPTION`

### Installation

Clone the repository and install dependencies:

```r
# Install required packages
install.packages(c("golem", "shiny", "DBI", "odbc", "config", "dplyr", "reactable"))

# Install the package (from the project root)
devtools::install()
```

### Configuration

Set the required environment variables for database access in a `.Renviron` file:

```
DB_SERVER=your_server
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_DRIVER=your_odbc_driver
DB_SCHEMA=your_schema

# When using a sqlite database you just need this:
SQLITE_DB_PATH=your_sqlite_file
```

### Running the App

To run the app in development mode:

```r
# From the project root
golem::run_dev()
```

Or use the provided script:

```r
source("dev/run_dev.R")
```

## Project Structure

- `R/` - R source code (modules, helpers, UI, server, etc.)
- `inst/app/www/` - Static resources (JS, CSS)
- `data_preperation/` - SQL scripts for data preparation
- `tests/` - Unit tests
- `dev/` - Development scripts for setup, development, and deployment

## Deployment

See [`dev/03_deploy.R`](dev/03_deploy.R) for deployment instructions to various platforms, including RStudio Connect, ShinyApps.io, and Docker.

## License

See the `DESCRIPTION` file for licence information.

## Authors

See the `DESCRIPTION` file for author information.

---
This project was generated using the [golem](https://github.com/ThinkR-open/golem) framework.
