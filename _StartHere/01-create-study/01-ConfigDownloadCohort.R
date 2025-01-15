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

# # #
#
# Files:
# The following parameters define where files for your study should be located.
#
# # #

settingsFileName <- "inst/sampleStudy/Cohorts.csv"
jsonFolder <- "inst/sampleStudy/cohorts"
sqlFolder <- "inst/sampleStudy/sql/sql_server"
negativeControlOutcomesFile <- "inst/sampleStudy/negativeControlOutcomes.csv"

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

