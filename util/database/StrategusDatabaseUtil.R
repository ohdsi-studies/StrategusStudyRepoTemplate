# StrategusDatabaseUtil -------------------------------------------------------

# ----
# StrategusDatabaseUtil:
# A utility class for common database interactions.  
# ----

StrategusDatabaseUtil <- {}

# getConnectionDetails --------------------------------------------------------

# ----
# Gets the connection details. Downloads the driver if needed.  
# ----

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

# createSchemaIfItDoesNotExist ------------------------------------------------

# ----
# Creates the specified schema if it does not exist.  
# ----

StrategusDatabaseUtil$createDatabaseIfItDoesNotExist <- function(dbName, conn) {
  # Check if the database exists
  checkDbQuery <- sprintf("SELECT 1 FROM pg_database WHERE datname = '%s';", dbName)
  dbExists <- nrow(DatabaseConnector::querySql(conn, checkDbQuery)) > 0
  # Create the database if it doesn't exist
  if (dbExists == FALSE) {
    createDbQuery <- sprintf("CREATE DATABASE %s;", dbName)
    DatabaseConnector::executeSql(conn, createDbQuery)
  }
}


