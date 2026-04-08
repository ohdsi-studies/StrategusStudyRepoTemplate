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

source("scriptsForStudyDesigner/WebApiHelperFunctions.R")
library(dplyr)
config <- config::get()
authWebApi()

# Define the cohorts that you'd like to download for use in this 
# study. Here is how the cohortsToDownload tribble is organized
#  - atlasCohortId: must match the ATLAS cohort identifier
#  - cohortId: a custom cohort ID or set to NA to use the ATLAS cohort identifier
#  - cohortName: a custom cohort name or set to NA to the ATLAS cohort name
cohortsToDownload <- tibble::tribble(
  ~atlasCohortId, ~cohortId, ~cohortName,
  22492, 1, "celecoxib",
  22493, 2, "diclofenac",
  22494, 3, "GI Bleed"
)

downloadCohortDefinitionSet(
  config = config,
  cohortsToDownload = cohortsToDownload
)
