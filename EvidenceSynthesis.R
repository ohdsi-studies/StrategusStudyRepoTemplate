################################################################################
# INSTRUCTIONS: The code below assumes you uploaded results to a PostgreSQL 
# database per the UploadResults.R script.This script will create the 
# analysis specification for running the EvidenceSynthesis module, execute
# EvidenceSynthesis, create the results tables and upload the results.
# 
# Review the code below and note the "sourceMethod" parameter used in the
# esModuleSettingsCreator$createEvidenceSynthesisSource() function. If your 
# study is not using CohortMethod and/or SelfControlledCaseSeries you should
# remove that from the evidenceSynthesisAnalysisList.
# ##############################################################################

library(dplyr)
library(Strategus)

resultsDatabaseSchema <- "results"

# Specify the connection to the results database
resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = Sys.getenv("OHDSI_RESULTS_DATABASE_SERVER"),
  user = Sys.getenv("OHDSI_RESULTS_DATABASE_USER"),
  password = Sys.getenv("OHDSI_RESULTS_DATABASE_PASSWORD")
)

esModuleSettingsCreator = EvidenceSynthesisModule$new()
evidenceSynthesisSourceCm <- esModuleSettingsCreator$createEvidenceSynthesisSource(
  sourceMethod = "CohortMethod",
  likelihoodApproximation = "adaptive grid"
)
metaAnalysisCm <- esModuleSettingsCreator$createBayesianMetaAnalysis(
  evidenceSynthesisAnalysisId = 1,
  alpha = 0.05,
  evidenceSynthesisDescription = "Bayesian random-effects alpha 0.05 - adaptive grid",
  evidenceSynthesisSource = evidenceSynthesisSourceCm
)
evidenceSynthesisSourceSccs <- esModuleSettingsCreator$createEvidenceSynthesisSource(
  sourceMethod = "SelfControlledCaseSeries",
  likelihoodApproximation = "adaptive grid"
)
metaAnalysisSccs <- esModuleSettingsCreator$createBayesianMetaAnalysis(
  evidenceSynthesisAnalysisId = 2,
  alpha = 0.05,
  evidenceSynthesisDescription = "Bayesian random-effects alpha 0.05 - adaptive grid",
  evidenceSynthesisSource = evidenceSynthesisSourceSccs
)
evidenceSynthesisAnalysisList <- list(metaAnalysisCm, metaAnalysisSccs)
evidenceSynthesisAnalysisSpecifications <- esModuleSettingsCreator$createModuleSpecifications(
  evidenceSynthesisAnalysisList
)
esAnalysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addModuleSpecifications(evidenceSynthesisAnalysisSpecifications)

ParallelLogger::saveSettingsToJson(
  esAnalysisSpecifications, 
  file.path("inst/sampleStudy/esAnalysisSpecification.json"))


resultsExecutionSettings <- Strategus::createResultsExecutionSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = file.path("results", "evidence_sythesis", "strategusOutput"),
  workFolder = file.path("results", "evidence_sythesis", "strategusWork")
)

Strategus::execute(
  analysisSpecifications = esAnalysisSpecifications,
  executionSettings = resultsExecutionSettings,
  connectionDetails = resultsConnectionDetails
)

resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = resultsExecutionSettings$resultsFolder,
)

Strategus::createResultDataModel(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

Strategus::uploadResults(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)
