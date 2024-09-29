library(ShinyAppBuilder)
library(OhdsiShinyModules)

resultsDatabaseSchema <- "strategus_repo_test"

# Specify the connection to the results database
resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  connectionString = keyring::key_get("resultsConnectionString", keyring = "ohda"),
  user = keyring::key_get("resultsAdmin", keyring = "ohda"),
  password = keyring::key_get("resultsAdminPassword", keyring = "ohda")
)

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
  connectionDetails = resultsConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = resultsDatabaseSchema)
)
