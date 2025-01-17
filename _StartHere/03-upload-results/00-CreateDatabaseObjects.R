# Create database objects for results ------------------------------------------

# libraries --------------------------------------------------------------------

source("./_StartHere/03-upload-results/config/01-UploadResultsConfig.R")
source("./util/database/StrategusDatabaseUtil.R")

# implementation ---------------------------------------------------------------

# create a connection to use to create the schema if it does not exist ----
bootStrapConnectionDetails <- StrategusDatabaseUtil$getConnectionDetails (
  dbms = dbms,
  connectionString = connectionString
)

# create the schema if it does not exist ----
conn <- DatabaseConnector::connect(bootStrapConnectionDetails)
StrategusDatabaseUtil$createDatabaseIfItDoesNotExist(dbName, conn)
DatabaseConnector::disconnect(conn)

# resultsConnectionDetails ----
resultsConnectionDetails <- StrategusDatabaseUtil$getConnectionDetails (
  dbms = "postgresql",
  connectionString = paste0("jdbc:postgresql://localhost:5432/", dbName, "?user=postgres&password=ohdsi")
)

# analysisSpecifications ----
analysisSpecifications <- ParallelLogger::loadSettingsFromJson (
  fileName = analysisSpecificationFilePath
)

# resultsDataModelSettings ---- 
resultsDataModelSettings <- Strategus::createResultsDataModelSettings (
  resultsDatabaseSchema = dbName,
  resultsFolder = resultsPath
)

# createResultDataModel ----
Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

