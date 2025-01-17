
source("./_StartHere/01-create-study/config/01-AuthorStudyConfiguration.R")

# test the results connection details ------------------------------------------
print("Getting connection...")
conn <- DatabaseConnector::connect(resultsConnectionDetails)
print("Closing connection")
DatabaseConnector::disconnect(conn)
print("Done.")

