ROhdsiWebApi::authorizeWebApi(
  baseUrl = keyring::key_get("webApiUrl", keyring = "ohda"),
  authMethod = "windows"
)
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = keyring::key_get("webApiUrl", keyring = "ohda"),
  cohortIds = c(
    3909, # New users of Celecoxib
    5903, # New users of Diclofenac
    5904 # GI Bleed
  ),
  generateStats = TRUE
)

# Rename cohorts
cohortDefinitionSet[cohortDefinitionSet$cohortId == 3909,]$cohortName <- "celecoxib"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 5903,]$cohortName <- "diclofenac"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 5904,]$cohortName <- "GI Bleed"

# Re-number cohorts
cohortDefinitionSet[cohortDefinitionSet$cohortId == 3909,]$cohortId <- 1
cohortDefinitionSet[cohortDefinitionSet$cohortId == 5903,]$cohortId <- 2
cohortDefinitionSet[cohortDefinitionSet$cohortId == 5904,]$cohortId <- 3

