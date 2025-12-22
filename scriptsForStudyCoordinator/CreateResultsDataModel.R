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
source("helperFunctions/ResultsSchemaHelperFunctions.R")

# Get the study configuration from the config.yml
config <- config::get()

# Need at least one results folder to know what table structure to create. 
# resultsFolder should at least contain a 'strategusResults' subfolder:
# Use the 1st results folder to define the results data model
resultsFolder <- list.dirs(path = config$resultFolder, full.names = T, recursive = F)[1]
if (!dir.exists(file.path(resultsFolder, "strategusResults"))) {
  stop(paste0(file.path(resultsFolder, "strategusResults"), " folder must exist, with results, to create the results model."))
}

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
  resultsFolder = file.path(resultsFolder, "strategusResults")
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = config$resultsConnectionDetails
)