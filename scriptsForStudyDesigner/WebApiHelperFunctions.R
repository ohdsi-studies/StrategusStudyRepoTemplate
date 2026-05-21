#' Cross platform auth for WebApi
#' If your WebAPI does not use security, set authMethod = "none"
authWebApi <- function(config = config::get(), authMethod = "windows") {
  if (authMethod == "none") {
    return(NULL)
  }
  params <- list(
    baseUrl = config$webApiUrl,
    authMethod = authMethod
  )
  if (.Platform$OS.type != "windows" || authMethod != "windows") {
    params$webApiUsername <- Sys.info()['user']
    if (rstudioapi::isAvailable())
      params$webApiPassword <- rstudioapi::askForSecret("Enter your web api password")
    else
      params$webApiPassword <- getPass::getPass("Enter your web api password: ")
  }
  do.call(ROhdsiWebApi::authorizeWebApi, params)
}

downloadCohortDefinitionSet <- function(config = config::get(), cohortsToDownload) {
  if (!tibble::is_tibble(cohortsToDownload)) {
    stop("cohortsToDownload must be a tibble with the following columns: atlasCohortId, cohortId, cohortName")
  }
  
  # Remove any previous results
  if (file.exists(file.path(config$projectRootFolder, "inst", "Cohorts.csv"))) {
    cli::cli_alert("Removing old assets.")
    unlink(file.path(config$projectRootFolder, "inst", "Cohorts.csv"))
    unlink(file.path(config$projectRootFolder, "inst", "cohorts"), recursive = TRUE)
    unlink(file.path(config$projectRootFolder, "inst", "sql", "sql_server"), recursive = TRUE)
  }
  
  cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
    baseUrl = config$webApiUrl,
    cohortIds = cohortsToDownload$atlasCohortId,
    generateStats = TRUE
  )
  
  # Rename cohorts
  if(any(!is.na(cohortsToDownload$cohortName))) {
    cohortDefinitionSet <- cohortDefinitionSet |>
      left_join(cohortsToDownload |> select(atlasCohortId, cohortName), by = c("atlasId" = "atlasCohortId"), suffix = c("", ".fromCohortsToDownload")) |>
      mutate(cohortName = coalesce(cohortName.fromCohortsToDownload, cohortName)) |>
      select(-cohortName.fromCohortsToDownload)
  }
  # Re-number cohorts
  if(any(!is.na(cohortsToDownload$cohortId))) {
    cohortDefinitionSet <- cohortDefinitionSet |>
      left_join(cohortsToDownload |> select(atlasCohortId, cohortId), by = c("atlasId" = "atlasCohortId"), suffix = c("", ".fromCohortsToDownload")) |>
      mutate(cohortId = coalesce(cohortId.fromCohortsToDownload, cohortId)) |>
      select(-cohortId.fromCohortsToDownload)
  }
  
  # Save the cohort definition set
  CohortGenerator::saveCohortDefinitionSet(
    cohortDefinitionSet = cohortDefinitionSet,
    settingsFileName = file.path(config$projectRootFolder, "inst", "Cohorts.csv"),
    jsonFolder = file.path(config$projectRootFolder, "inst", "cohorts"),
    sqlFolder = file.path(config$projectRootFolder, "inst", "sql", "sql_server")
  )
}