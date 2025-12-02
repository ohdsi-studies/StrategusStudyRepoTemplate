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

# Get the study configuration from the config.yml
config <- config::get()

# Need at least one results folder to know what table structure to create. 
# resultsFolder should at least contain a 'strategusOutput' subfolder:
# Use the 1st results folder to define the results data model
# resultsFolder <- list.dirs(path = "results", full.names = T, recursive = F)[1]
resultsFolder <- "/Users/schuemie/Data/ExampleStrategusStudy"
if (!dir.exists(file.path(resultsFolder, "strategusOutput"))) {
  stop(paste0(file.path(resultsFolder, "strategusOutput"), " folder must exist, with results, to create the results model."))
}

# Don't make changes below this line -------------------------------------------
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = file.path(config$projectRootFolder, "inst", config$studySpecificationFileName)
)

# Create results data model -------------------------
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = config$resultsDatabaseSchema,
  resultsFolder = file.path(resultsFolder, "strategusOutput")
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = config$resultsConnectionDetails
)