# # #
#
# This implementation assumes you have cohorts you would like to use in an
# ATLAS instance. 
#
# Update the parameters below to match your study.  
#
# # #

# # #
#
# Files:
# The following parameters define where files for your study should be located.
#
# # #

studyDefRootDir <- "./inst/sampleStudy"
settingsFileName <- paste0(studyDefRootDir, "/Cohorts.csv")
jsonFolder <- paste0(studyDefRootDir, "/cohorts")
sqlFolder <- paste0(studyDefRootDir, "/sql/sql_server")
negativeControlOutcomesFile <- paste0(studyDefRootDir, "/negativeControlOutcomes.csv")

# # #
#
# Base URL:
# This is the URL of the WebAPI/Atlas instance you are sourcing data from. 
# 
# # #

baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"

# # #
# Un-comment the code below if your WebAPI instance has security enables
# # #

# ROhdsiWebApi::authorizeWebApi(
#   baseUrl = baseUrl,
#   authMethod = "windows"
# )

# # #
#
# Results Connection Detials:
# Connection details for the database that will hold the results.  
# 
# # #

# TODO: (JEG) FINISH THIS THOUGHT

# ------------------------------------------------------------------------------
# Study Design Variables
# ------------------------------------------------------------------------------

# # #
# Dates:
# If your study is not restricted to a specific time window, make these strings empty (i.e. '').
# # #

studyStartDate <- '20171201' #YYYYMMDD
studyEndDate <- '20231231'   #YYYYMMDD

# # #
#
# Cohorts and Negative Control:
# - Update the following to use the cohort ids and negative control concept set id
#   for your study. 
# - Each study in the cohort list will be assigned a sequence id that will be
#   used across the network studies. Sequence IDs will be assigned in the order
#   of the list supplied here (e.g. in the example below 1778211 will be assigned 1)
# 
# # #

cohortList <-
  list(
    list(1778211, "celecoxib"),
    list(1790989, "diclofenac"),
    list(1780946, "GI Bleed")
  )

negativeControlConceptSetId <- 1885090

outcomeCohortId <- 3
cleanWindow <- 365

targetCohortId <- 1001
targetCohortName <- "celecoxib new users"
comparatorCohortId <- 2001
comparatorCohortName <- "diclofenac new users"

# # #
# Exclude concepts
# # #

excludeConceptIdList <- c(1118084, 1124300)
excludeConceptNameList <- c("celecoxib", "diclofenac")

# # #
# Time at risk (TARs) variables 
# # #

tarLabel <- "On treatment"
tarRiskWindowStart  <- 1
tarStartAnchor <- "cohort start"
tarRiskWindowEnd  <- 0
tarEndAnchor <- "cohort end"

# # #
# Patient Level Prediction (PLP) Time at risk (TARs) variables 
# # #

plpTarRiskWindowStart  = 1
plpTarStartAnchor = "cohort start"
plpTarRiskWindowEnd  = 365
plpTarEndAnchor = "cohort start"

# # #
#
# Estimation settings:
#  - # If useCleanWindowForPriorOutcomeLookback is set to FALSE, lookback window is all time prior, 
#    (i.e. including only first events).
#  - If psMatchMaxRatio is bigger than 1, the outcome model will be conditioned on the matched set
#
# # #

useCleanWindowForPriorOutcomeLookback <- FALSE 
psMatchMaxRatio <- 1 




