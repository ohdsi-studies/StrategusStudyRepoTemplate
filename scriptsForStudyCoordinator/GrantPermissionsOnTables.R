# Optional scripts to set permissions and to analyze tables ------------------

# Get the study configuration from the config.yml
config <- config::get()

connection <- DatabaseConnector::connect(
  connectionDetails = config$resultsConnectionDetails
)

# Grant read only permissions to all tables
sql <- "GRANT USAGE ON SCHEMA @schema TO @results_user;
GRANT SELECT ON ALL TABLES IN SCHEMA @schema TO @results_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA @schema TO @results_user;"

message("Setting permissions for results schema")
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

# Analyze all tables in the results schema
message("Analyzing all tables in results schema")
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

DatabaseConnector::disconnect(connection)
