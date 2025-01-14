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

# # # 
# 
# Libraries
# 
# # #

library(dplyr)

# # # 
# 
# Implementation
# 
# # #

baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
# Use this if your WebAPI instance has security enables
# ROhdsiWebApi::authorizeWebApi(
#   baseUrl = baseUrl,
#   authMethod = "windows"
# )

cohortList <-
  list(
    list(1778211, "celecoxib"),
    list(1790989, "diclofenac"),
    list(1780946, "GI Bleed")
  )

negativeControlConceptId <- 1885090

settingsFileName <- "inst/sampleStudy/Cohorts.csv"
jsonFolder <- "inst/sampleStudy/cohorts"
sqlFolder <- "inst/sampleStudy/sql/sql_server"
negativeControlOutcomesFile <- "inst/sampleStudy/negativeControlOutcomes.csv"

cohortIds <- sapply(cohortList, function(x) as.numeric(x[1]))

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = TRUE
)

cohortTibble <- tibble(
  ID = sapply(cohortList, `[[`, 1),
  Name = sapply(cohortList, `[[`, 2)
)

# Rename renumber cohorts
for (i in seq_len(nrow(cohortTibble))) {
  cohortDefinitionSet[cohortDefinitionSet$cohortId == cohortTibble$ID[i], "cohortName"] <- cohortTibble$Name[i]
  cohortDefinitionSet[cohortDefinitionSet$cohortId == cohortTibble$ID[i], "cohortId"] <- i
}

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
  conceptSetId = negativeControlConceptId,
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
  file = negativeControlOutcomesFile,
  warnOnFileNameCaseMismatch = F
)
