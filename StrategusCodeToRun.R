# -------------------------------------------------------
#                     PLEASE READ
# -------------------------------------------------------
#
# You must call "renv::restore()" and follow the prompts
# to install all of the necessary R libraries to run this
# project. This is a one-time operation that you must do
# before running any code.
#
# !!! PLEASE RESTART R AFTER RUNNING renv::restore() !!!
#
# -------------------------------------------------------
#renv::restore()

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

##=========== START OF INPUTS ==========
cdmDatabaseSchema <- "iqvia_germany.cdm_iqvia_germany_v2915"
workDatabaseSchema <- "scratch.scratch_asena5"
outputLocation <- file.path(getwd(), "results")
databaseName <- "cdm_iqvia_germany_v2915" # Only used as a folder name for results from the study
minCellCount <- 5
cohortTableName <- "strategus_repo_test_cdm_iqvia_germany_v2915"

# Create the connection details for your CDM
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html
options(sqlRenderTempEmulationSchema = 'scratch.scratch_asena5')
connectionDetails = DatabaseConnector::createConnectionDetails(
  dbms = "spark",
  user = "token",
  connectionString = keyring::key_get("dataBricksConnectionString", keyring="ohda"),
  password = keyring::key_get("dataBricksPassword", keyring="ohda")
)

#conn <- DatabaseConnector::connect(connectionDetails)
#DatabaseConnector::disconnect(conn)

##=========== END OF INPUTS ==========
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/sampleStudyAnalysisSpecification.json"
)

executionSettings <- Strategus::createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, databaseName, "strategusWork"),
  resultsFolder = file.path(outputLocation, databaseName, "strategusOutput"),
  minCellCount = minCellCount
)

if (!dir.exists(file.path(outputLocation, databaseName))) {
  dir.create(file.path(outputLocation, databaseName), recursive = T)
}
ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(outputLocation, databaseName, "executionSettings.json")
)

Strategus::execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  connectionDetails = connectionDetails
)