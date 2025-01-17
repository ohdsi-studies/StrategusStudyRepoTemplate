# # #
#
# This implementation assumes you have cohorts you would like to use in an
# ATLAS instance. 
#
# Update the parameters below to match your study.  
#
# # #

# Libraries --------------------------------------------------------------------

source("./util/database/StrategusDatabaseUtil.R")

# Implementation ---------------------------------------------------------------

# Files ---- 

# # #
# The following parameters define where files for your study should be located.
# # #

studyDefRootDir <- "./inst/sampleStudy"
settingsFileName <- paste0(studyDefRootDir, "/Cohorts.csv")
jsonFolder <- paste0(studyDefRootDir, "/cohorts")
sqlFolder <- paste0(studyDefRootDir, "/sql/sql_server")
negativeControlOutcomesFile <- paste0(studyDefRootDir, "/negativeControlOutcomes.csv")
studyDefinitionFile <- paste0(studyDefRootDir, "/sampleStudyAnalysisSpecification.json")

# Base URL ----

# # #
# This is the URL of the WebAPI/Atlas instance you are sourcing data from. 
# # #

baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
useWebApiAuthorization <- FALSE

# ------------------------------------------------------------------------------
# Study Design Variables
# ------------------------------------------------------------------------------

# Dates ----
# If your study is not restricted to a specific time window, make these strings empty (i.e. '').

studyStartDate <- '20171201' #YYYYMMDD
studyEndDate <- '20231231'   #YYYYMMDD

# Cohorts ----
# - Update the following to use the cohort ids and negative control concept set id
#   for your study. 
# - Each study in the cohort list will be assigned a sequence id that will be
#   used across the network studies. Sequence IDs will be assigned in the order
#   of the list supplied here (e.g. in the example below 1778211 will be assigned 1)

cohortList <-
  list(
    list(1778211, "celecoxib"),
    list(1790989, "diclofenac"),
    list(1780946, "GI Bleed")
  )

outcomeCohortId <- 3
cleanWindow <- 365

# Negative Control ----
negativeControlConceptSetId <- 1885090

# Create New Users Subset ----
createNewUsersSubset <- TRUE
newUsersDefinitionId <- 1
newUsersPriorTime <- 365
newUsersLimitTo <- "firstEver"

# For the CohortMethod analysis we'll use the subsetted cohorts
targetCohortId <- 1001
targetCohortName <- "celecoxib new users"
comparatorCohortId <- 2001
comparatorCohortName <- "diclofenac new users"

# Time at risk (TARs) variables ----

# # #
#
# Time at risk as used by the following modules (and potentially others)
#   - CharacterizationModule
#   - CohortIncidenceModule
#   - CohortMethodModule
#   - SelfControlledCaseSeriesmodule
#
# # #

tarLabel <- "On treatment"
tarRiskWindowStart  <- 1
tarStartAnchor <- "cohort start"
tarRiskWindowEnd  <- 0
tarEndAnchor <- "cohort end"

# Settings for specific modules ------------------------------------------------

# # #
#
# The following section contains settings for specific modules. Most of these
# modules have additional settings that are generally not modified. See
# CreateStrategusAnalysisSpecification.R to see the other variables that are used.  
#
# # #

# CohortMethodModule -----------------------------------------------------------

excludeConceptIdList <- c(1118084, 1124300)
excludeConceptNameList <- c("celecoxib", "diclofenac")

# PatientLevelPredictionModule -------------------------------------------------

plpTarRiskWindowStart  = 1
plpTarStartAnchor = "cohort start"
plpTarRiskWindowEnd  = 365
plpTarEndAnchor = "cohort start"

# # #
# Estimation settings:
#  - # If useCleanWindowForPriorOutcomeLookback is set to FALSE, lookback window is all time prior, 
#    (i.e. including only first events).
#  - If psMatchMaxRatio is bigger than 1, the outcome model will be conditioned on the matched set
# # #

useCleanWindowForPriorOutcomeLookback <- FALSE 
psMatchMaxRatio <- 1 

# CharacterizationModule ------------------------------------------------------
charMinPriorObservation <- 365
charDechallengeStopInterval <- 30
charDechallengeEvaluationWindow <- 30

# SelfControlledCaseSeriesmodule ---------------------------------------------------
sccsTargetCohortId <- c(1,2)
sscsTargetCohortName <- c("celecoxib", "diclofenac")


