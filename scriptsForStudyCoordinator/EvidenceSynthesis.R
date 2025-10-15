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

config <- config::get()

# EvidenceSynthesis Settings ---------------------------------------------------
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

# Execute EvidenceSynthesis ----------------------------------------------------
resultsExecutionSettings <- Strategus::createResultsExecutionSettings(
  resultsDatabaseSchema = config$resultsDatabaseSchema,
  resultsFolder = file.path("results", "evidence_sythesis", "strategusOutput"),
  workFolder = file.path("results", "evidence_sythesis", "strategusWork")
)

Strategus::execute(
  analysisSpecifications = esAnalysisSpecifications,
  executionSettings = resultsExecutionSettings,
  connectionDetails = config$resultsConnectionDetails
)

# Upload Results ---------------------------------------------------------------
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = config$resultsDatabaseSchema,
  resultsFolder = resultsExecutionSettings$resultsFolder,
)

Strategus::createResultDataModel(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = config$resultsConnectionDetails
)

Strategus::uploadResults(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = config$resultsConnectionDetails
)

# Set permissions & analyze tables ---------------------------------------------
source("scriptsForStudyCoordinator/GrantPermissionsOnTables.R")
