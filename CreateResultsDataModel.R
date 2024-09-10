# Code for creating the result schema and tables in a Postgres database
resultsDatabaseSchema <- "strategus_repo_test"
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/sampleStudyAnalysisSpecification.json"
)
resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  connectionString = keyring::key_get("resultsConnectionString", keyring = "ohda"),
  user = keyring::key_get("resultsAdmin", keyring = "ohda"),
  password = keyring::key_get("resultsAdminPassword", keyring = "ohda")
)

# Connect to the database ------------------------------------------------------
connection <- DatabaseConnector::connect(connectionDetails = resultsDatabaseConnectionDetails)

# Create the schema ------------------------------------------------------------
tryCatch(
  expr = {
    sql <- "CREATE SCHEMA @schema;"
    sql <- SqlRender::render(sql = sql, schema = resultsDatabaseSchema)
    DatabaseConnector::executeSql(connection = connection, sql = sql)
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
        cli::cli_inform("Stopping this script.")
        DatabaseConnector::disconnect(connection = connection)
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

# Disconnect from the database -------------------------------------------------
DatabaseConnector::disconnect(connection)

# Create results data model -------------------------

# Use the 1st set of results as the template
resultsFolder <- list.dirs(path = "results", full.names = T, recursive = F)[1]
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = file.path(resultsFolder, "strategusOutput")
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsDatabaseConnectionDetails
)