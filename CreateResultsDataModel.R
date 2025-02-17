# Create database objects for results ------------------------------------------

# libraries --------------------------------------------------------------------

source("./_StartHere/03-upload-results/config/01-UploadResultsConfig.R")
source("./util/database/StrategusDatabaseUtil.R")

# implementation ---------------------------------------------------------------

# create a connection to use to create the schema if it does not exist ----
bootStrapConnectionDetails <- StrategusDatabaseUtil$getConnectionDetails (
  dbms = dbms,
  connectionString = bootStrapConnectionString
)

# create the database if it does not exist ----
conn <- DatabaseConnector::connect(bootStrapConnectionDetails)
StrategusDatabaseUtil$createDatabaseIfItDoesNotExist(dbName, conn)
DatabaseConnector::disconnect(conn)

# resultsConnectionDetails ----
resultsConnectionDetails <- StrategusDatabaseUtil$getConnectionDetails (
  dbms = dbms,
  connectionString = connectionString
)

# create the schema if it does not exist ----
conn <- DatabaseConnector::connect(resultsConnectionDetails)
StrategusDatabaseUtil$createSchemaIfItDoesNotExist(schemaName, conn)
DatabaseConnector::disconnect(conn)

# analysisSpecifications ----
analysisSpecifications <- ParallelLogger::loadSettingsFromJson (
  fileName = analysisSpecificationFilePath
)

# resultsDataModelSettings ---- 
resultsDataModelSettings <- Strategus::createResultsDataModelSettings (
  resultsDatabaseSchema = schemaName,
  resultsFolder = resultsPath
)

# Create results data model -------------------------

# Use the 1st results folder to define the results data model
resultsFolder <- list.dirs(path = resultsPath, full.names = T, recursive = F)[1]
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = schemaName,
  resultsFolder = file.path(resultsFolder, "strategusOutput")
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

