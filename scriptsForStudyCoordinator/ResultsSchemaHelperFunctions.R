grantReadOnlyPermissions <- function(config = config::get()) {
  if (tolower(config$resultsConnectionDetails$dbms) == "postgresql") {
    if (config$resultsDatabaseSchema == "") {
      stop("resultsDatabaseSchema is empty. Please set this value in the config.yml")
    }
    if (config$shinyReadOnlyUserName == "") {
      stop("shinyReadOnlyUserName is empty. Please set this value in the config.yml")
    }
    
    connection <- DatabaseConnector::connect(
      connectionDetails = config$resultsConnectionDetails
    )
    on.exit(DatabaseConnector::disconnect(connection))
    
    # Grant read only permissions to all tables
    sql <- "GRANT USAGE ON SCHEMA @schema TO \"@results_user\";
    GRANT SELECT ON ALL TABLES IN SCHEMA @schema TO \"@results_user\";
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA @schema TO \"@results_user\";"
    
    message(glue::glue("Setting read-only permissions for user {config$shinyReadOnlyUserName} on tables in results schema: {config$resultsDatabaseSchema}"))
    sql <- SqlRender::render(
      sql = sql,
      schema = config$resultsDatabaseSchema,
      results_user = config$shinyReadOnlyUserName
    )
    DatabaseConnector::executeSql(
      connection = connection,
      sql = sql,
      progressBar = FALSE,
      reportOverallTime = FALSE
    )
  } else {
    cli::cli_alert_warning("Skipping grant read-only permissions since not using PostreSQL for results storage.")
  }
}

analyzeAllTables <- function(config = config::get()) {
  if (tolower(config$resultsConnectionDetails$dbms) == "postgresql") {
    if (config$resultsDatabaseSchema == "") {
      stop("resultsDatabaseSchema is empty. Please set this value in the config.yml")
    }
    connection <- DatabaseConnector::connect(
      connectionDetails = config$resultsConnectionDetails
    )
    on.exit(DatabaseConnector::disconnect(connection))
    
    # Analyze all tables in the results schema
    message(glue::glue("Analyzing all tables in results schema: {config$resultsDatabaseSchema}"))
    sql <- "ANALYZE @schema.@table_name;"
    tableList <- DatabaseConnector::getTableNames(
      connection = connection,
      databaseSchema = config$resultsDatabaseSchema
    )
    for (i in 1:length(tableList)) {
      DatabaseConnector::renderTranslateExecuteSql(
        connection = connection,
        sql = sql,
        schema = config$resultsDatabaseSchema,
        table_name = tableList[i],
        progressBar = FALSE,
        reportOverallTime = FALSE
      )
    }    
  } else {
    cli::cli_alert_warning("Skipping analyze all tables since not using PostreSQL for results storage.")
  }
}

createResultsSchema <- function(resultsDatabaseConnectionDetails, resultsDatabaseSchema) {
  # Connect to the database
  connection <- DatabaseConnector::connect(connectionDetails = resultsDatabaseConnectionDetails)
  opt <- options(show.error.messages = FALSE)
  on.exit({
    options(opt)
    on.exit(DatabaseConnector::disconnect(connection))
  })  
  
  # Create the schema
  tryCatch(
    expr = {
      sql <- "CREATE SCHEMA @schema;"
      sql <- SqlRender::render(sql = sql, schema = resultsDatabaseSchema)
      DatabaseConnector::executeSql(connection = connection, sql = sql, progressBar = FALSE)
    }, 
    error = function(e) {
      errorMsg <- paste0(
        e,
        "\n----------------------------------------------\n",
        "A schema with results already exists!\n",
        "----------------------------------------------\n",
        "Do you want to drop this schema and recreate all tables?\nNOTE: This will remove all previous results that have been uploaded.\n"
      )
      message(errorMsg)
      switch(
        menu(
          choices = c(
            no = "Stop this process and preserve the results schema and all tables.",
            yes = "Recreate results schema and tables which will remove all results."
          ),
          title = "How would you like to proceed?"
        ) + 1,
        cat("Nothing done\n"),
        no = {
          cli::cli_alert_info("Stopping and preserving results schema.")
          stop(silent = TRUE)
        }
        ,
        yes = {
          sql <- "DROP SCHEMA IF EXISTS @schema CASCADE; CREATE SCHEMA @schema;"
          sql <- SqlRender::render(sql = sql, schema = resultsDatabaseSchema)
          DatabaseConnector::executeSql(connection = connection, sql = sql)
        }
      )
    }  
  )
}