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
options(java.parameters = "-Xss15m")
Sys.setenv(DATABASECONNECTOR_JAR_FOLDER = './drivers')
if(!dir.exists('./drivers')){
  dir.create('./drivers')
  DatabaseConnector::downloadJdbcDrivers(
    dbms = 'postgresql',
    pathToDriver = './drivers'
  )
}

# Get the study configuration from the config.yml
config <- config::get()

library(OhdsiShinyAppBuilder)
library(OhdsiShinyModules)

themePackage <- "OhdsiShinyAppBuilder"
# ADD OR REMOVE MODULES TAILORED TO YOUR STUDY
shinyConfig <- OhdsiShinyAppBuilder::initializeModuleConfig() |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultAboutConfig()
  )  |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultDatasourcesConfig()
  )  |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultCohortGeneratorConfig()
  ) |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultCohortDiagnosticsConfig()
  ) |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultCharacterizationConfig()
  ) |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultPredictionConfig()
  ) |>
  OhdsiShinyAppBuilder::addModuleConfig(
    OhdsiShinyAppBuilder::createDefaultEstimationConfig()
  ) 

# now create the shiny app based on the config file and view the results
# based on the connection 
OhdsiShinyAppBuilder::createShinyApp(
  title = config$studyName, # Change this to something friendly for the title of the app
  studyDescription = config$studyName, # Change this to something friendly for the description of the app
  config = shinyConfig, 
  connectionDetails = config$resultsConnectionDetails,
  resultDatabaseSettings = OhdsiShinyAppBuilder::createDefaultResultDatabaseSettings(schema = config$resultsDatabaseSchema),
  themePackage = themePackage
)
