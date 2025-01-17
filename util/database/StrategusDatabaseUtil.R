StrategusDatabaseUtil <- {}

StrategusDatabaseUtil$getConnectionDetails <- function(dbms, connectionString) {
  # get the jdbc driver dir
  jdbcDriverDir <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
  # create the dir if it does not exist
  if(dir.exists(jdbcDriverDir) == FALSE) {
    dir.create(jdbcDriverDir, recursive = TRUE)
  }
  # download the driver if it does not exist
  searchString <- paste0("^", dbms)
  driverExists <- any(grepl(searchString, list.files(jdbcDriverDir)))
  if (driverExists == FALSE) {
    print("Driver not found, downloading it now...")
    DatabaseConnector::downloadJdbcDrivers(dbms)
    print("Done downloading driver.")
  }
  # create the connection details
  resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = dbms,
    connectionString = connectionString
  )
  # return
  return(resultsConnectionDetails)
}


