################################################################################
# INSTRUCTIONS: The code below assumes you have access to a PostgreSQL database
# and permissions to insert data into tables created by running the 
# CreateResultsDataModel.R script. This script will loop over all of the 
# directories found under the "results" folder and upload the results. 
#
# This script also contains some commented out code for 
# setting read-only permissions for a user account on the results schema. 
# This is used when setting up a read-only user for use with a Shiny results 
# viewer. Additionally, there is commented out code that will allow you to run
# ANALYZE on each results table to ensure the database is performant.
# 
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################
source("scriptsForStudyCoordinator/ResultsSchemaHelperFunctions.R")
config <- config::get()

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = file.path(config$projectRootFolder, "inst", config$studySpecificationFileName)
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
for (resultFolder in list.dirs(path = config$resultFolder, full.names = T, recursive = F)) {
  resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
    resultsDatabaseSchema = config$resultsDatabaseSchema,
    resultsFolder = resultFolder,
    logFileName = file.path(config$projectRootFolder, "strategus-upload-results-log.txt")
  )
  
  Strategus::uploadResults(
    analysisSpecifications = analysisSpecifications,
    resultsDataModelSettings = resultsDataModelSettings,
    resultsConnectionDetails = config$resultsConnectionDetails
  )
}

# Set permissions & analyze tables ---------------------------------------------
grantReadOnlyPermissions()
analyzeAllTables()

# Unregister loggers -----------------------------------------------------------
ParallelLogger::unregisterLogger("RESULTS_FILE_LOGGER")
ParallelLogger::unregisterLogger("RESULTS_ERROR_LOGGER")