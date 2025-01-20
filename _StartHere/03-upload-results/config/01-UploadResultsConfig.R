# Configuration file for data upload -------------------------------------------

# ----
#
# This file contains the configuration details for uploading data for a study that has been run.  
#
# ----

# Files ----

analysisSpecificationFilePath <- "inst/sampleStudy/sampleStudyAnalysisSpecification.json"
resultsPath <- "./results"

# Results Connection Details ----

# # #
# Connection details and schema for the database that will hold the results.  
# # #

resultsDbPassword <- Sys.getenv("RESULTS_DB_PASSWORD")
dbName <- "strategus"
schemaName <- "study_results"
dbms <- "postgresql"
bootStrapConnectionString <- paste0("jdbc:postgresql://localhost:5432/postgres?user=postgres&password=", resultsDbPassword)
connectionString <- paste0("jdbc:postgresql://localhost:5432/", dbName, "?user=postgres&password=", resultsDbPassword)

