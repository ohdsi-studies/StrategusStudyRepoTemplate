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

# libraries --------------------------------------------------------------------

source("./_StartHere/02-run-study/config/01-RunStudyConfiguration.R")

# implementation ---------------------------------------------------------------

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

# You can use this snippet to test your connection
#conn <- DatabaseConnector::connect(connectionDetails)
#DatabaseConnector::disconnect(conn)

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = analysisSpecificationFilePath
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