
# ----
#
# Run Configuration:
# This file contains the parameters used for running a study.  
#
# ----

# Files ----

analysisSpecificationFilePath <- "inst/sampleStudy/sampleStudyAnalysisSpecification.json"

# Other parameters for running the study ----

cdmDatabaseSchema <- "main"
workDatabaseSchema <- "main"
outputLocation <- "results"
databaseName <- "Eunomia"
minCellCount <- 5
cohortTableName <- "sample_study"

# Connection details ---- 

connectionDetails <- Eunomia::getEunomiaConnectionDetails()
