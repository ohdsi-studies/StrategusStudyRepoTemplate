library(dplyr)
baseUrl <- keyring::key_get("webApiUrl", keyring = "ohda")
ROhdsiWebApi::authorizeWebApi(
  baseUrl = baseUrl,
  authMethod = "windows"
)
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
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

# Save the cohort definition set
CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet
)


# Download and save the negative control outcomes
negativeControlOutcomeCohortSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = 1720,
  baseUrl = baseUrl
) %>%
  ROhdsiWebApi::resolveConceptSet(
    baseUrl = baseUrl
  ) %>%
  ROhdsiWebApi::getConcepts(
    baseUrl = baseUrl
  ) %>%
  rename(outcomeConceptId = "conceptId",
         cohortName = "conceptName") %>%
  mutate(cohortId = row_number() + 1000) %>%
  select(cohortId, cohortName, outcomeConceptId)

CohortGenerator::writeCsv(
  x = negativeControlOutcomeCohortSet,
  file = "inst/negativeControlOutcomes.csv",
  warnOnFileNameCaseMismatch = F
)
