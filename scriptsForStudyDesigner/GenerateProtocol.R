# AGS - This script is not working yet. 2 issues:
# 1. When using security-enabled WebAPI, concept retrieval fails
# 2. When using public OHDSI WebAPI without security, it fails to render sccs
# with the following error:
# processing file: study_protocol.qmd
# |................                                 |  32% [cohort_inc]        Picked up _JAVA_OPTIONS: -Xmx8g
# |...............................                  |  64% [sccs]              
# 
# Error in `data.frame()`:
#   ! arguments imply differing number of rows: 1, 0
# Backtrace:
  
source("helperFunctions/WebApiHelperFunctions.R")
config <- config::get()
authWebApi()

# open this inside your strategus project or set the directory
# using setwd('location to strategus directory')
ProtocolGenerator::generateProtocol(
  jsonLocation =   file.path(config$projectRootFolder, "inst", config$studySpecificationFileName),
  webAPI = config$webApiUrl, 
  outputLocation = file.path(config$projectRootFolder, "extras"), 
  outputName = 'protocol.html', 
  intermediateDir = tempdir()
)