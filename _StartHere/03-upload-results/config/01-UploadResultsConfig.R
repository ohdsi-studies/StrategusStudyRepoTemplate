# Configuration file for data upload -------------------------------------------

# ----
#
# This file contains the configuration details for uploading data for a study that has been run.  
#
# ----

# Files ----

analysisSpecificationFilePath <- "inst/sampleStudy/sampleStudyAnalysisSpecification.json"
resultsPath <- "results"

# Results Connection Details ----

# # #
# Connection details and schema for the database that will hold the results.  
# # #

dbName <- "study_results"
dbms <- "postgresql"
connectionString <- "jdbc:postgresql://localhost:5432/postgres?user=postgres&password=ohdsi"

