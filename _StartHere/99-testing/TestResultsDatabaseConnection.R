# libraries --------------------------------------------------------------------

source("./_StartHere/03-upload-results/config/01-UploadResultsConfig.R")
source("./util/database/StrategusDatabaseUtil.R")

# implementation ---------------------------------------------------------------

# test the results connection details ----
print("Getting connection...")
conn <- DatabaseConnector::connect(resultsConnectionDetails)
print("Closing connection")
DatabaseConnector::disconnect(conn)
print("Done.")

