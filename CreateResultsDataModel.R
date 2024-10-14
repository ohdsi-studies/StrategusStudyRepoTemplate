# Code for creating the result schema and tables in a Postgres database
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