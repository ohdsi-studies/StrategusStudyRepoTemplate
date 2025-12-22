################################################################################
# INSTRUCTIONS: Make sure you have downloaded your cohorts and concept sets 
# using DownloadAssets.R and that those are stored in the "inst" folder of the
# of the project. This script is written to use the sample study cohorts
# located in "inst/sampleStudy" so you will need to modify this in the code 
# below. 
# 
# See the Create analysis specifications section
# of the UsingThisTemplate.md for more details.
# 
# More information about Strategus HADES modules can be found at:
# https://ohdsi.github.io/Strategus/reference/index.html#omop-cdm-hades-modules.
# This help page also contains links to the corresponding HADES package that
# further details.
# ##############################################################################
library(Strategus)
library(tibble)
source("helperFunctions/AnalysisSpecificationsHelperFunctions.R")
config <- config::get()

negativeControlOutcomeCohortSet <- CohortGenerator::readCsv(
  file = file.path(config$projectRootFolder, "inst", "negativeControlOutcomes.csv")
)

covariateConceptsToExclude <- CohortGenerator::readCsv(
  file = file.path(config$projectRootFolder, "inst", "covariateConceptsToExclude.csv")
) |>
  dplyr::pull("conceptId")

cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = file.path(config$projectRootFolder, "inst", "Cohorts.csv"),
  jsonFolder = file.path(config$projectRootFolder, "inst", "cohorts"),
  sqlFolder = file.path(config$projectRootFolder, "inst", "sql", "sql_server")
)

tcis <- list(
  #standard analyses that would be performed during routine signal detection
  list(
    targetId = 1, # Celecoxib
    comparatorId = 2, # diclofenac
    indicationId = NULL, # When desired, you can use this to subset the target & comparator to an indication cohort that overlaps the target/comparator start date. Can be NULL.
    genderConceptIds = c(8507, 8532), # use valid genders (remove unknown)
    minAge = NULL, # All ages In years. Can be NULL
    maxAge = NULL, # All ages In years. Can be NULL
    excludedCovariateConceptIds = c(
      1118084, # celecoxib
      1124300  # diclofenac
    ) 
  )
)

outcomes <- tibble::tribble(
  ~cohortId, ~cleanWindow,
  3,    365,          # GI Bleed
)

# Time-at-risks (TARs) for the outcomes of interest in your study
timeAtRisks <- tibble::tribble(
  ~label,         ~riskWindowStart, ~startAnchor,   ~riskWindowEnd, ~endAnchor,
  "On treatment", 1,                "cohort start", 0,              "cohort end"
)
# Try to avoid intent-to-treat TARs for SCCS, or then at least disable calendar time spline:
sccsTimeAtRisks <- tibble::tribble(
  ~label,         ~riskWindowStart, ~startAnchor,   ~riskWindowEnd, ~endAnchor,
  "On treatment", 1,                "cohort start", 0,              "cohort end"
)
# Try to use fixed-time TARs for patient-level prediction:
plpTimeAtRisks <- tibble::tribble(
  ~riskWindowStart, ~startAnchor,   ~riskWindowEnd, ~endAnchor,
  1,                "cohort start", 365,            "cohort start"
)

# If you are not restricting your study to a specific time window, 
# please make these strings empty
studyStartDate <- "" # Specify in "YYYYMMDD" format
studyEndDate <- ""   # Specify in "YYYYMMDD" format

########################################################
# Below the line - DO NOT MODIFY -----------------------
########################################################

# Don't change below this line (unless you know what you're doing) -------------

# Shared Resources -------------------------------------------------------------
subsets <- createSubsets(
  tcis = tcis,
  cohortDefinitionSet = cohortDefinitionSet,
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet
)
cohortDefinitionSet <- subsets$cohortDefinitionSet
dfUniqueTcis <- subsets$dfUniqueTcis

# Strategus module settings --------------------------------------------------------
cohortGeneratorModuleSpecifications <- createCohortGeneratorModuleSpecifications(
  cohortDefinitionSet = cohortDefinitionSet,
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet
)

cohortDiagnosticsModuleSpecifications <- createcohortDiagnosticsModuleSpecifications(
  cohortDefinitionSet = cohortDefinitionSet
)

characterizationModuleSpecifications <- createCharacterizationModuleSpecifications(
  cohortDefinitionSet = cohortDefinitionSet,
  outcomes = outcomes,
  timeAtRisks = timeAtRisks
)

cohortIncidenceModuleSpecifications <- createCohortIncidenceModuleSpecifications(
  cohortDefinitionSet = cohortDefinitionSet,
  outcomes = outcomes,
  timeAtRisks = timeAtRisks,
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate
)

cohortMethodModuleSpecifications <- createCohortMethodModuleSpecifications(
  tcis = tcis,
  dfUniqueTcis = dfUniqueTcis,
  cohortDefinitionSet = cohortDefinitionSet,
  outcomes = outcomes,
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet,
  timeAtRisks = timeAtRisks,
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate
)

selfControlledModuleSpecifications <- createSelfControlledCaseSeriesModuleSpecifications(
  tcis = tcis,
  cohortDefinitionSet = cohortDefinitionSet,
  outcomes = outcomes,
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet,
  timeAtRisks = sccsTimeAtRisks,
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate
)

# PatientLevelPredictionModule Settings -------------------------------------------------
patientLevelPredictionModuleSpecifications <- createPatientLevelPredictionModuleSpecifications(
  tcis = tcis,
  dfUniqueTcis = dfUniqueTcis,
  cohortDefinitionSet = cohortDefinitionSet,
  outcomes = outcomes,
  timeAtRisks = plpTimeAtRisks,
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate
)

# Create the analysis specifications ------------------------------------------
# To disable specific modules, just remove them here:
moduleSpecsList <- list(
  cohortGeneratorModuleSpecifications$moduleSpec,
  cohortDiagnosticsModuleSpecifications,
  characterizationModuleSpecifications,
  cohortIncidenceModuleSpecifications,
  cohortMethodModuleSpecifications,
  selfControlledModuleSpecifications,
  patientLevelPredictionModuleSpecifications
)

analysisSpecifications <- Strategus::createEmptyAnalysisSpecifications()
for (sharedResource in cohortGeneratorModuleSpecifications$sharedResourcesList) {
  analysisSpecifications <- Strategus::addSharedResources(analysisSpecifications, sharedResource)
}
for (moduleSpec in moduleSpecsList) {
  analysisSpecifications <- Strategus::addModuleSpecifications(analysisSpecifications, moduleSpec)
}

ParallelLogger::saveSettingsToJson(
  analysisSpecifications, 
  file.path(config$projectRootFolder, "inst", config$studySpecificationFileName)
)