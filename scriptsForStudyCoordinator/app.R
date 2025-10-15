################################################################################
# INSTRUCTIONS: The code below assumes you uploaded results to a PostgreSQL 
# database per the UploadResults.R script.This script will launch a Shiny
# results viewer to analyze results from the study.
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

library(OhdsiShinyAppBuilder)
library(OhdsiShinyModules)

# ADD OR REMOVE MODULES TAILORED TO YOUR STUDY
shinyConfig <- initializeModuleConfig() |>
  addModuleConfig(
    createDefaultAboutConfig()
  )  |>
  addModuleConfig(
    createDefaultDatasourcesConfig()
  )  |>
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) |>
  addModuleConfig(
    createDefaultCohortDiagnosticsConfig()
  ) |>
  addModuleConfig(
    createDefaultCharacterizationConfig()
  ) |>
  addModuleConfig(
    createDefaultPredictionConfig()
  ) |>
  addModuleConfig(
    createDefaultEstimationConfig()
  ) 

# now create the shiny app based on the config file and view the results
# based on the connection 
ShinyAppBuilder::createShinyApp(
  config = shinyConfig, 
  connectionDetails = config$resultsConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = config$resultsDatabaseSchema)
)
