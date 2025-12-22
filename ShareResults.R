##=========== START OF INPUTS ==========

# NOTE: These values must match the values used in ExecuteAnalyses.R
outputLocation <- "e:/exampleStrategusStudy" # Where the intermediate and output files will be written
databaseName <- "CCAE" # Only used as a folder name for results from the study

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
config <- config::get()

outputLocation <- file.path(outputLocation, databaseName, "strategusResults")
zipFile <- file.path(outputLocation, paste0(databaseName, ".zip"))

Strategus::zipResults(
  resultsFolder = outputLocation,
  zipFile = zipFile
)

OhdsiSharing::sftpUploadFile(
  privateKeyFileName = config$sftpKeyFileName, 
  userName = config$sftpUserName,
  remoteFolder = config$sftpRemoteFolderName,
  fileName = zipFile
)