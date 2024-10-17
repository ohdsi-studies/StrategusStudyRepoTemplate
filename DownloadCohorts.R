################################################################################
# INSTRUCTIONS: This script assumes you have cohorts you would like to use in an
# ATLAS instance. Please note you will need to update the baseUrl to match
# the settings for your enviroment. You will also want to change the 
# CohortGenerator::saveCohortDefinitionSet() function call arguments to identify
# a folder to store your cohorts. This code will store the cohorts in 
# "inst/sampleStudy" as part of the template for reference. You should store
# your settings in the root of the "inst" folder and consider removing the 
# "inst/sampleStudy" resources when you are ready to release your study.
# 
# See the Download cohorts section
# of the UsingThisTemplate.md for more details.
# ##############################################################################

library(dplyr)
baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
# Use this if your WebAPI instance has security enables
# ROhdsiWebApi::authorizeWebApi(
#   baseUrl = baseUrl,
#   authMethod = "windows"
# )
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(
    1778211, # All exposures - celecoxib
    1790989, # All exposures - diclofenac
    1780946 # GI Bleed
  ),
  generateStats = TRUE
)

# Rename cohorts
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1778211,]$cohortName <- "celecoxib"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1790989,]$cohortName <- "diclofenac"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1780946,]$cohortName <- "GI Bleed"

# Re-number cohorts
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1778211,]$cohortId <- 1
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1790989,]$cohortId <- 2
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1780946,]$cohortId <- 3

# Save the cohort definition set
# NOTE: Update settingsFileName, jsonFolder and sqlFolder
# for your study.
CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = "inst/sampleStudy/Cohorts.csv",
  jsonFolder = "inst/sampleStudy/cohorts",
  sqlFolder = "inst/sampleStudy/sql/sql_server",
)


# Download and save the negative control outcomes
negativeControlOutcomeCohortSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = 1885090,
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
  mutate(cohortId = row_number() + 100) %>%
  select(cohortId, cohortName, outcomeConceptId)

# NOTE: Update file location for your study.
CohortGenerator::writeCsv(
  x = negativeControlOutcomeCohortSet,
  file = "inst/sampleStudy/negativeControlOutcomes.csv",
  warnOnFileNameCaseMismatch = F
)
