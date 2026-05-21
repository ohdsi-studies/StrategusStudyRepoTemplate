##=========== START OF INPUTS ==========

# NOTE: These values must match the values used in ExecuteAnalyses.R
resultsFolder <- "e:/exampleStrategusStudy/results" # Where the output files were written
databaseName <- "CCAE" # Only used as a folder name for results from the study
# For uploading the results. You should have received these values from the Study Coordinator:
sftpKeyFileName <- "[location where you are storing: e.g. ~/keys/study-data-site-covid19.dat]"
sftpUserName <- "[user name provided by the Study Coordinator: eg: study-data-site-covid19]"
sftpRemoteFolderName <- "[remote folder name provided by the Study Coordinator]"

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
resultsFolder <- file.path(resultsFolder, databaseName)
zipFile <- file.path(resultsFolder, paste0(databaseName, ".zip"))

Strategus::zipResults(
  resultsFolder = resultsFolder,
  zipFile = zipFile
)

OhdsiSharing::sftpUploadFile(
  privateKeyFileName = sftpKeyFileName, 
  userName = sftpUserName,
  remoteFolder = sftpRemoteFolderName,
  fileName = zipFile
)
