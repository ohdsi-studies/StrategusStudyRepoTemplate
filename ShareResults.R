##=========== START OF INPUTS ==========
outputLocation <- 'D:/git/ohdsi-studies/SemaglutideNaion'
databaseName <- "MDCD"
# For uploading the results. You should have received the key file from the study coordinator:
keyFileName <- "[location where you are storing: e.g. ~/keys/study-data-site-covid19.dat]"
userName <- "[user name provided by the study coordinator: eg: study-data-site-covid19]"

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
outputLocation <- file.path(outputLocation, "results", databaseName, "strategusOutput")
zipFile <- file.path(outputLocation, paste0(databaseName, ".zip"))

Strategus::zipResults(
  resultsFolder = outputLocation,
  zipFile = zipFile
)

OhdsiSharing::sftpUploadFile(
  privateKeyFileName = keyFileName, 
  userName = userName,
  remoteFolder = "/your-study/",
  fileName = zipFile
)