################################################################################
# INSTRUCTIONS: The code below assumes you have access to a PostgreSQL database
# and permissions to create tables in an existing schema specified by the
# resultsDatabaseSchema parameter.
# 
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################
source("scriptsForStudyCoordinator/ResultsSchemaHelperFunctions.R")

# Get the study configuration from the config.yml
config <- config::get()

createResultsSchema(
  resultsDatabaseConnectionDetails = config$resultsConnectionDetails,
  resultsDatabaseSchema = config$resultsDatabaseSchema
)

# Don't make changes below this line -------------------------------------------
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = file.path(config$projectRootFolder, "inst", config$studySpecificationFileName)
)

# Create results data model -------------------------
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = config$resultsDatabaseSchema,
  resultsFolder = config$projectRootFolder, # NOTE: With Strategus v1.5, this parameter is ignored when creating the results data model
  logFileName = file.path(config$projectRootFolder, "strategus-create-results-data-model-log.txt")
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = config$resultsConnectionDetails
)