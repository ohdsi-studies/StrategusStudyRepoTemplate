# View Results Configuration ---------------------------------------------------

resultsDbPassword <- Sys.getenv("RESULTS_DB_PASSWORD")
schemaName <- "study_results"
connectionString <- paste0("jdbc:postgresql://localhost:5432/", dbName, "?user=postgres&password=", resultsDbPassword)

# ADD OR REMOVE MODULES TAILORED TO YOUR STUDY ----
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

