# # # 
# 
# Libraries
# 
# # #

library(dplyr)
source("./_StartHere/01-create-study/config/01-AuthorStudyConfiguration.R")

# # # 
# 
# Implementation
# 
# # #

# get the cohortIds as a list of integers
cohortIds <- sapply(cohortList, function(x) as.numeric(x[1]))

# create the cohortDefinitionSet
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = TRUE
)

# get the id and name as a tibble to use to update cohortDefinitionSet
cohortTibble <- tibble(
  ID = sapply(cohortList, `[[`, 1),
  Name = sapply(cohortList, `[[`, 2)
)

# rename and renumber cohorts
for (i in seq_len(nrow(cohortTibble))) {
  cohortDefinitionSet[cohortDefinitionSet$cohortId == cohortTibble$ID[i], "cohortName"] <- cohortTibble$Name[i]
  cohortDefinitionSet[cohortDefinitionSet$cohortId == cohortTibble$ID[i], "cohortId"] <- i
}

# Save the cohort definition set
CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = settingsFileName,
  jsonFolder = jsonFolder,
  sqlFolder = sqlFolder,
)

# Download and save the negative control outcomes
negativeControlOutcomeCohortSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = negativeControlConceptSetId,
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

# write the negativeControlOutcomeCohortSet to csv
CohortGenerator::writeCsv(
  x = negativeControlOutcomeCohortSet,
  file = negativeControlOutcomesFile,
  warnOnFileNameCaseMismatch = F
)
