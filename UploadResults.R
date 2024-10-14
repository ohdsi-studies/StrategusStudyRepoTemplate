# Code for uploading results to a Postgres database
#resultsDatabaseSchema <- "strategus_repo_test"
resultsDatabaseSchema <- "viewerdemo2024"
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/sampleStudyAnalysisSpecification.json"
)
# resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
#   dbms = "postgresql",
#   connectionString = keyring::key_get("resultsConnectionString", keyring = "ohda"),
#   user = keyring::key_get("resultsAdmin", keyring = "ohda"),
#   password = keyring::key_get("resultsAdminPassword", keyring = "ohda")
# )
resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = Sys.getenv("OHDSI_RESULTS_DATABASE_SERVER"),
  user = Sys.getenv("OHDSI_RESULTS_DATABASE_USER"),
  password = Sys.getenv("OHDSI_RESULTS_DATABASE_PASSWORD")
)

# Setup logging ----------------------------------------------------------------
ParallelLogger::clearLoggers()
ParallelLogger::addDefaultFileLogger(
  fileName = "upload-log.txt",
  name = "RESULTS_FILE_LOGGER"
)
ParallelLogger::addDefaultErrorReportLogger(
  fileName = "upload-errorReport.txt",
  name = "RESULTS_ERROR_LOGGER"
)

# Upload Results ---------------------------------------------------------------
for (resultFolder in list.dirs(path = "results", full.names = T, recursive = F)) {
  resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
    resultsDatabaseSchema = resultsDatabaseSchema,
    resultsFolder = file.path(resultFolder, "strategusOutput"),
  )
  
  Strategus::uploadResults(
    analysisSpecifications = analysisSpecifications,
    resultsDataModelSettings = resultsDataModelSettings,
    resultsConnectionDetails = resultsDatabaseConnectionDetails
  )
}

connection <- DatabaseConnector::connect(
  connectionDetails = resultsDatabaseConnectionDetails
)

# Grant read only permissions to all tables
sql <- "GRANT USAGE ON SCHEMA @schema TO @results_user;
GRANT SELECT ON ALL TABLES IN SCHEMA @schema TO @results_user; 
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA @schema TO @results_user;"

message("Setting permissions for results schema")
sql <- SqlRender::render(
  sql = sql, 
  schema = resultsDatabaseSchema,
  results_user = 'shinyproxy'
)
DatabaseConnector::executeSql(
  connection = connection, 
  sql = sql,
  progressBar = FALSE,
  reportOverallTime = FALSE
)
  
# Analyze all tables in the results schema
message("Analyzing all tables in results schema")
sql <- "ANALYZE @schema.@table_name;"
tableList <- DatabaseConnector::getTableNames(
  connection = connection,
  databaseSchema = resultsDatabaseSchema
)
for (i in 1:length(tableList)) {
  DatabaseConnector::renderTranslateExecuteSql(
    connection = connection,
    sql = sql,
    schema = resultsDatabaseSchema,
    table_name = tableList[i],
    progressBar = FALSE,
    reportOverallTime = FALSE
  )
}

DatabaseConnector::disconnect(connection)

# Unregister loggers -----------------------------------------------------------
ParallelLogger::unregisterLogger("RESULTS_FILE_LOGGER")
ParallelLogger::unregisterLogger("RESULTS_ERROR_LOGGER")