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
source("scriptsForStudyCoordinator/ResultsSchemaHelperFunctions.R")
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
evidenceSynthesisSourceSccsGridWithGradients <- esModuleSettingsCreator$createEvidenceSynthesisSource(
  sourceMethod = "SelfControlledCaseSeries",
  likelihoodApproximation = "grid with gradients"
)
metaAnalysisSccs <- esModuleSettingsCreator$createBayesianMetaAnalysis(
  evidenceSynthesisAnalysisId = 2,
  alpha = 0.05,
  evidenceSynthesisDescription = "Bayesian random-effects alpha 0.05 - grid with gradients",
  evidenceSynthesisSource = evidenceSynthesisSourceSccsGridWithGradients
)
evidenceSynthesisAnalysisList <- list(metaAnalysisCm, metaAnalysisSccs)
evidenceSynthesisAnalysisSpecifications <- esModuleSettingsCreator$createModuleSpecifications(
  evidenceSynthesisAnalysisList
)
esAnalysisSpecifications <- Strategus::createEmptyAnalysisSpecifications() |>
  Strategus::addModuleSpecifications(evidenceSynthesisAnalysisSpecifications)

ParallelLogger::saveSettingsToJson(
  esAnalysisSpecifications, 
  file.path(config$projectRootFolder, "inst", config$evidenceSynthesisSpecificationFileName)
)

# Execute EvidenceSynthesis ----------------------------------------------------
resultsExecutionSettings <- Strategus::createResultsExecutionSettings(
  resultsDatabaseSchema = config$resultsDatabaseSchema,
  resultsFolder = config$evidenceSynthesisResultFolder,
  workFolder = config$evidenceSynthesisWorkFolder
)

Strategus::execute(
  analysisSpecifications = esAnalysisSpecifications,
  executionSettings = resultsExecutionSettings,
  connectionDetails = config$resultsConnectionDetails
)

# Upload results ---------------------------------
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = config$resultsDatabaseSchema,
  resultsFolder = config$evidenceSynthesisResultFolder,
  logFileName = file.path(config$evidenceSynthesisResultFolder, "strategus-upload-results-log.txt")
)

Strategus::uploadResults(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = config$resultsConnectionDetails
)

# Set permissions & analyze tables ---------------------------------------------
grantReadOnlyPermissions()
analyzeAllTables()

