#' Get unique tcis data.frame from tcis list object
#'
#' @description
#' Get the unique subset criteria from the tcis object to construct the 
#' cohortDefintionSet's subset definitions for each target/comparator
#' cohort
#' 
#' @param tcis The target/comparator/indication/subset (tcis) list of lists
#'
#' @return
#' A data.frame with the unique tcis entries
getUniqueTcis <- function(tcis) {
  dfUniqueTcis <- data.frame()
  for (i in seq_along(tcis)) {
    dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(cohortId = tcis[[i]]$targetId,
                                                   indicationId = paste(tcis[[i]]$indicationId, collapse = ","),
                                                   genderConceptIds = paste(tcis[[i]]$genderConceptIds, collapse = ","),
                                                   minAge = paste(tcis[[i]]$minAge, collapse = ","),
                                                   maxAge = paste(tcis[[i]]$maxAge, collapse = ",")
    ))
    if (!is.null(tcis[[i]]$comparatorId)) {
      dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(cohortId = tcis[[i]]$comparatorId,
                                                     indicationId = paste(tcis[[i]]$indicationId, collapse = ","),
                                                     genderConceptIds = paste(tcis[[i]]$genderConceptIds, collapse = ","),
                                                     minAge = paste(tcis[[i]]$minAge, collapse = ","),
                                                     maxAge = paste(tcis[[i]]$maxAge, collapse = ",")
      ))
    }
  }
  
  dfUniqueTcis <- unique(dfUniqueTcis)
  dfUniqueTcis$subsetDefinitionId <- 0 # Add a column for use when performing subsets
  return(dfUniqueTcis)  
}

#' Create the subsetted cohort definitions for the analysis specification
#'
#' @description
#' TODO: Describe this in detail and add functionality to provide
#' column-wise descriptions where a cohort is used.
#' 
#' @param tcis The target/comparator/indication/subset (tcis) list of lists
#' @param cohortDefinitionSet The cohorts used in the study
#' @param negativeControlOutcomeCohortSet Negative control outcome cohorts
#' for the study (mandatory if doing estimation study)
#'
#' @return
#' A list with 2 elements: `cohortDefinitionSet` with all subset definitions applied,
#' and `dfUniqueTcis` that sets the subsetDefinitionId for the unique combination
#' of tcis
createSubsets <- function(tcis, cohortDefinitionSet, negativeControlOutcomeCohortSet = NULL) {
  dfUniqueTcis <- getUniqueTcis(tcis)
  dfUniqueSubsetCriteria <- unique(dfUniqueTcis[,-1])
  
  for (i in seq_len(nrow(dfUniqueSubsetCriteria))) {
    uniqueSubsetCriteria <- dfUniqueSubsetCriteria[i,]
    dfCurrentTcis <- dfUniqueTcis[dfUniqueTcis$indicationId == uniqueSubsetCriteria$indicationId &
                                    dfUniqueTcis$genderConceptIds == uniqueSubsetCriteria$genderConceptIds &
                                    dfUniqueTcis$minAge == uniqueSubsetCriteria$minAge & 
                                    dfUniqueTcis$maxAge == uniqueSubsetCriteria$maxAge,]
    targetCohortIdsForSubsetCriteria <- as.integer(dfCurrentTcis[, "cohortId"])
    dfUniqueTcis[dfUniqueTcis$indicationId == dfCurrentTcis$indicationId &
                   dfUniqueTcis$genderConceptIds == dfCurrentTcis$genderConceptIds &
                   dfUniqueTcis$minAge == dfCurrentTcis$minAge & 
                   dfUniqueTcis$maxAge == dfCurrentTcis$maxAge,]$subsetDefinitionId <- i
    
    subsetOperators <- list()
    
    # Always first restrict for CM/PLP - also if running annual IRs need to change limitTo = 'firstEver' to 'all'
    subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createLimitSubset(
      priorTime = 365,
      followUpTime = 1,
      limitTo = "firstEver"
    )
    
    # Indication restriction (always first if there is an indication)
    indicationName <- ""
    if (uniqueSubsetCriteria$indicationId != "") {
      subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createCohortSubset(
        cohortIds = uniqueSubsetCriteria$indicationId,
        negate = FALSE,
        cohortCombinationOperator = "all",
        windows = list(
          CohortGenerator::createSubsetCohortWindow(
            startDay = -99999, 
            endDay = 0, 
            targetAnchor = "cohortStart",
            subsetAnchor = "cohortStart"
          ),
          CohortGenerator::createSubsetCohortWindow(
            startDay = 0, 
            endDay = 99999, 
            targetAnchor = "cohortStart",
            subsetAnchor = "cohortEnd"
          )
        )
      )
      # saving name for the cohort subset name
      indicationName <- cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == uniqueSubsetCriteria$indicationId]
    }
    
    # Demo settings
    demoName <- ""
    if (uniqueSubsetCriteria$genderConceptIds != "" ||
        uniqueSubsetCriteria$minAge != "" ||
        uniqueSubsetCriteria$maxAge != "") {
      subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createDemographicSubset(
        ageMin = if(uniqueSubsetCriteria$minAge == "") 0 else as.integer(uniqueSubsetCriteria$minAge),
        ageMax = if(uniqueSubsetCriteria$maxAge == "") 99999 else as.integer(uniqueSubsetCriteria$maxAge),
        gender = if(uniqueSubsetCriteria$genderConceptIds == "") NULL else as.integer(strsplit(uniqueSubsetCriteria$genderConceptIds, ",")[[1]])
      )
      
      if(uniqueSubsetCriteria$genderConceptIds != ""){
        # could map to name but for now doing code to make it generalizable
        demoName <- paste0(" gender ",uniqueSubsetCriteria$genderConceptIds)
      }
      if(uniqueSubsetCriteria$minAge != "" & uniqueSubsetCriteria$maxAge == ""){
        # check the >= is true
        demoName <- paste0(demoName, ' age >= ', uniqueSubsetCriteria$minAge)
      }
      if(uniqueSubsetCriteria$minAge == "" & uniqueSubsetCriteria$maxAge != ""){
        # check the >= is true
        demoName <- paste0(demoName, ' age <= ', uniqueSubsetCriteria$maxAge)
      }
      if(uniqueSubsetCriteria$minAge != "" & uniqueSubsetCriteria$maxAge != ""){
        # check the <= is true
        demoName <- paste0(demoName, ' ', uniqueSubsetCriteria$minAge, ' <= age <= ', uniqueSubsetCriteria$maxAge)
      }
      
    }
    
    # Time settings
    timeName <- ""
    if (studyStartDate != "" || studyEndDate != "") {
      subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createLimitSubset(
        calendarStartDate = if (studyStartDate == "") NULL else as.Date(studyStartDate, "%Y%m%d"),
        calendarEndDate = if (studyEndDate == "") NULL else as.Date(studyEndDate, "%Y%m%d")
      )
      
      if(studyStartDate != ""){
        timeName <- paste0(" from ", studyStartDate)
      }
      if(studyEndDate != ""){
        timeName <- paste0(timeName, " until ", studyEndDate)
      }
      
    }
    # add the indication/demo/year subset for the targets with this subset
    subsetDef <- CohortGenerator::createCohortSubsetDefinition(
      name = paste0("first time ",ifelse(indicationName == '', '', 'in '), indicationName, demoName, timeName),
      subsetCohortNameTemplate = "@baseCohortName - @subsetDefinitionName",
      definitionId = i,
      subsetOperators = subsetOperators
    )
    cohortDefinitionSet <- cohortDefinitionSet |>
      CohortGenerator::addCohortSubsetDefinition(
        cohortSubsetDefintion = subsetDef,
        targetCohortIds = targetCohortIdsForSubsetCriteria
      ) 
    
    # add the indication cohort without the indication subset
    if (uniqueSubsetCriteria$indicationId != "") {
      # Also create restricted version of indication cohort:
      subsetDef <- CohortGenerator::createCohortSubsetDefinition(
        name = paste0("first time ", demoName, timeName),
        subsetCohortNameTemplate = "@baseCohortName - @subsetDefinitionName",
        definitionId = i + 100,
        subsetOperators = subsetOperators[-2] # indic removed
      )
      cohortDefinitionSet <- cohortDefinitionSet |>
        CohortGenerator::addCohortSubsetDefinition(
          cohortSubsetDefintion = subsetDef,
          targetCohortIds = as.integer(uniqueSubsetCriteria$indicationId)
        )
    }  
  }

  # Check to make sure there are no duplicated cohort IDs between 
  # the cohortDefintionSet and negative control outcome cohorts.
  if (!is.null(negativeControlOutcomeCohortSet)) {
    if (any(duplicated(cohortDefinitionSet$cohortId, negativeControlOutcomeCohortSet$cohortId))) {
      dupedCohortIds <- intersect(cohortDefinitionSet$cohortId, negativeControlOutcomeCohortSet$cohortId)
      dupedCohorts <- cohortDefinitionSet |>
        dplyr::filter(cohortId %in% dupedCohortIds) |>
        dplyr::select(cohortId, cohortName) |>
        dplyr::mutate(source = "cohortDefinitionSet")
      dupedNcs <- negativeControlOutcomeCohortSet |>
        dplyr::filter(cohortId %in% dupedCohortIds) |>
        dplyr::select(cohortId, cohortName) |>
        dplyr::mutate(source = "negativeControlOutcomeCohortSet")
      allDupedCohorts <- cohortDefinitionSet |>
        dplyr::bind_rows(dupedNcs)
      cli::cli_alert_danger("Duplicate cohort IDs found in the cohortDefinitionSet and the negativeControlOutcomeCohortSet!")
      print.data.frame(allDupedCohorts)
      stop("*** Please resolve this identifier conflict and try again ***")
    }
  }
  
  return(
    list(
      cohortDefinitionSet = cohortDefinitionSet,
      dfUniqueTcis = dfUniqueTcis
    )
  )
}

#' Create the CohortGenerator module specifications
#'
#' @description
#' This function will create the shared resources for the Strategus analysis
#' specification that holds the cohort definition set and negative control
#' outcomes. It will also create the CohortGenerator module specifications.
#' 
#' @param cohortDefinitionSet The cohorts used in the study
#' @param negativeControlOutcomeCohortSet Negative control outcome cohorts
#' for the study (optional)
#'
#' @return
#' A list() with 2 elements: `sharedResourcesList` holds the a list of cohorts
#' and negative control outcomes and `moduleSpec` holds the CohortGenerator
#' module specifications
createCohortGeneratorModuleSpecifications <- function(cohortDefinitionSet, negativeControlOutcomeCohortSet) {
  cgModuleSettingsCreator <- CohortGeneratorModule$new()
  cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSet)
  cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications(
    generateStats = TRUE
  )
  sharedResourcesList <- list()
  sharedResourcesList[[1]] <- cohortDefinitionShared 
  if (!is.null(negativeControlOutcomeCohortSet)) {
    negativeControlsShared <- cgModuleSettingsCreator$createNegativeControlOutcomeCohortSharedResourceSpecifications(
      negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet,
      occurrenceType = "first",
      detectOnDescendants = TRUE
    )
    sharedResourcesList[[length(sharedResourcesList)+1]] <- negativeControlsShared
  }
  return(
    list(
      sharedResourcesList = sharedResourcesList,
      moduleSpec = cohortGeneratorModuleSpecifications
    )
  )
}

#' Create the CohortDiagnostics module specifications
#'
#' @description
#' This function will create the CohortDiagnostics module specifications.
#' 
#' @param cohortDefinitionSet The cohorts used in the study
#' @param runInclusionStatistics Generate and export statistic on the cohort 
#' inclusion rules? Default is TRUE
#' @param runIncludedSourceConcepts   Generate and export the source concepts 
#' included in the cohorts? Default is TRUE
#' @param runOrphanConcepts Generate and export potential orphan concepts? 
#' Default is TRUE
#' @param runTimeSeries Generate and export the time series diagnostics?
#' Default is FALSE
#' @param runVisitContext Generate and export index-date visit context?
#' Default is TRUE
#' @param runBreakdownIndexEvents Generate and export the breakdown of index 
#' events? Default is TRUE
#' @param runIncidenceRate Generate and export the cohort incidence rates?
#' Default is TRUE
#' @param runCohortRelationship Compute cohort relationships. Overlap is now 
#' computed with FeaturExtraction, time paramters are derived from 
#' temporalCovariateSettings relationship between two or more cohorts.
#' Default is TRUE
#' @param runTemporalCohortCharacterization Generate and export the temporal 
#' cohort characterization? Only records with values greater than 0.001 are 
#' returned.
#' @param minCharacterizationMean The minimum mean value for characterization 
#' output. Values below this will be cut off from output. This will help reduce 
#' the file size of the characterization output, but will remove information
#' on covariates that have very low values. The default is 0.01 (i.e. 1 percent)
#' @return
#' CohortDiagnostics module specifications
createcohortDiagnosticsModuleSpecifications <- function(
    cohortDefinitionSet, 
    runInclusionStatistics = TRUE,
    runIncludedSourceConcepts = TRUE,
    runOrphanConcepts = TRUE,
    runTimeSeries = FALSE,
    runVisitContext = TRUE,
    runBreakdownIndexEvents = TRUE,
    runIncidenceRate = TRUE,
    runCohortRelationship = TRUE,
    runTemporalCohortCharacterization = TRUE,
    minCharacterizationMean = 0.01
) {
  cdModuleSettingsCreator <- CohortDiagnosticsModule$new()
  cohortDiagnosticsModuleSpecifications <- cdModuleSettingsCreator$createModuleSpecifications(
    cohortIds = cohortDefinitionSet$cohortId,
    runInclusionStatistics = runInclusionStatistics,
    runIncludedSourceConcepts = runIncludedSourceConcepts,
    runOrphanConcepts = runOrphanConcepts,
    runTimeSeries = runTimeSeries,
    runVisitContext = runVisitContext,
    runBreakdownIndexEvents = runBreakdownIndexEvents,
    runIncidenceRate = runIncidenceRate,
    runCohortRelationship = runCohortRelationship,
    runTemporalCohortCharacterization = runTemporalCohortCharacterization,
    minCharacterizationMean = 0.01
  )
  return(cohortDiagnosticsModuleSpecifications)
}

#' Create the Characterization module specifications
#'
#' @description
#' This function will create the Characterization module specifications.
#' 
#' @param cohortDefinitionSet The cohorts used in the study
#' @param outcomes The outcomes and clean windows used in the study
#' @param timeAtRisks The time-at-risks used in the study
#' included in the cohorts? Default is TRUE
#' @param dechallengeStopInterval An integer specifying the how much time to add
#' to the cohort_end when determining whether the event starts during cohort and
#' ends after. Default is 30
#' @param dechallengeEvaluationWindow An integer specifying the period of time
#' after the cohort_end when you cannot see an outcome for a dechallenge 
#' success. Default is 30
#' @param casePreTargetDuration The number of days prior to case index we use 
#' for FeatureExtraction. Default is 365
#' @param casePostOutcomeDuration The number of days after case index we use 
#' for FeatureExtraction. Default is 365
#' @param minPriorObservation The minimum time (in days) in the database a 
#' patient in the target cohorts must be observed prior to index. Default is 365
#' @param minCharacterizationMean The minimum mean value for characterization 
#' output. Values below this will be cut off from output. This will help reduce 
#' the file size of the characterization output, but will remove information
#' on covariates that have very low values. The default is 0.01 (i.e. 1 percent)
#' @return
#' Characaterization module specifications
createCharacterizationModuleSpecifications <- function(
    cohortDefinitionSet, 
    outcomes,
    timeAtRisks,
    dechallengeStopInterval = 30,
    dechallengeEvaluationWindow = 30,
    casePreTargetDuration = 365,
    casePostOutcomeDuration = 365,
    minPriorObservation = 365,
    minCharacterizationMean = 0.01
) {
  cModuleSettingsCreator <- CharacterizationModule$new()
  allCohortIdsExceptOutcomes <- cohortDefinitionSet |>
    dplyr::filter(!cohortId %in% outcomes$cohortId) |>
    dplyr::pull(cohortId)
  
  characterizationModuleSpecifications <- cModuleSettingsCreator$createModuleSpecifications(
    targetIds = allCohortIdsExceptOutcomes,
    outcomeIds = outcomes$cohortId,
    outcomeWashoutDays = outcomes$cleanWindow,
    riskWindowStart = timeAtRisks$riskWindowStart,
    startAnchor = timeAtRisks$startAnchor,
    riskWindowEnd = timeAtRisks$riskWindowEnd,
    endAnchor = timeAtRisks$endAnchor,
    dechallengeStopInterval = dechallengeStopInterval,
    dechallengeEvaluationWindow = dechallengeEvaluationWindow,
    casePreTargetDuration = casePreTargetDuration,
    casePostOutcomeDuration = casePostOutcomeDuration,
    minPriorObservation = minPriorObservation,
    minCharacterizationMean = minCharacterizationMean
  )
  return(characterizationModuleSpecifications)
}

#' Create the CohortIncidence module specifications
#'
#' @description
#' This function will create the CohortIncidence module specifications.
#' 
#' @param cohortDefinitionSet The cohorts used in the study
#' @param outcomes The outcomes and clean windows used in the study
#' @param timeAtRisks The time-at-risks used in the study
#' included in the cohorts? Default is TRUE
#' @param studyStartDate Restrict the study to a specific start date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param studyEndDate Restrict the study to a specific end date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param stratifyByYear Stratify incidence rates by index year? Default is TRUE
#' @param stratifyByGender Stratify incidence rates by gender? Default is TRUE
#' @param stratifyByAge Stratify incidence rates by `stratificationAgeBreaks`? 
#' Default is TRUE
#' @param stratificationAgeBreaks Vector of age breaks to use when 
#' `stratifyByAge` is TRUE. Default is 10 year age buckets from age 0 - 110.
#' @return
#' CohortIncidence module specifications
createCohortIncidenceModuleSpecifications <- function(
    cohortDefinitionSet, 
    outcomes,
    timeAtRisks,
    studyStartDate = "",
    studyEndDate = "",
    stratifyByYear = TRUE,
    stratifyByGender = TRUE,
    stratifyByAge = TRUE,
    stratificationAgeBreaks = seq(0, 110, by = 10)
){
  ciModuleSettingsCreator <- CohortIncidenceModule$new()
  exposureIndicationIds <- cohortDefinitionSet |>
    dplyr::filter(!cohortId %in% outcomes$cohortId & isSubset) |>
    dplyr::pull(cohortId)
  targetList <- lapply(
    exposureIndicationIds,
    function(cohortId) {
      CohortIncidence::createCohortRef(
        id = cohortId, 
        name = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == cohortId]
      )
    }
  )
  outcomeList <- lapply(
    seq_len(nrow(outcomes)),
    function(i) {
      CohortIncidence::createOutcomeDef(
        id = i, 
        name = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == outcomes$cohortId[i]], 
        cohortId = outcomes$cohortId[i], 
        cleanWindow = outcomes$cleanWindow[i]
      )
    }
  )
  
  tars <- list()
  for (i in seq_len(nrow(timeAtRisks))) {
    tars[[i]] <- CohortIncidence::createTimeAtRiskDef(
      id = i, 
      startWith = gsub("cohort ", "", timeAtRisks$startAnchor[i]), 
      endWith = gsub("cohort ", "", timeAtRisks$endAnchor[i]), 
      startOffset = timeAtRisks$riskWindowStart[i],
      endOffset = timeAtRisks$riskWindowEnd[i]
    )
  }
  analysis1 <- CohortIncidence::createIncidenceAnalysis(
    targets = exposureIndicationIds,
    outcomes = seq_len(nrow(outcomes)),
    tars = seq_along(tars)
  )
  
  # Some of the settings require study dates with hyphens
  studyStartDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyStartDate)
  studyEndDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyEndDate)
  
  # NOTE: Passing an empty string to CohortIncidence::createDateRange
  # will not work since it assumes a non-missing value is formatted
  # as a date string so checking the parameters here so we only pass
  # the non-empty values specified by the user
  createDateRangeArgs <- list()
  if (studyStartDateWithHyphens != "") {
    createDateRangeArgs["startDate"] <- studyStartDateWithHyphens
  }
  if (studyEndDateWithHyphens != "") {
    createDateRangeArgs["endDate"] <- studyEndDateWithHyphens
  }
  irStudyWindow <- do.call(CohortIncidence::createDateRange, createDateRangeArgs)
  
  irDesign <- CohortIncidence::createIncidenceDesign(
    targetDefs = targetList,
    outcomeDefs = outcomeList,
    tars = tars,
    analysisList = list(analysis1),
    studyWindow = irStudyWindow,
    strataSettings = CohortIncidence::createStrataSettings(
      byYear = stratifyByYear,
      byGender = stratifyByGender,
      byAge = stratifyByAge,
      ageBreaks = stratificationAgeBreaks
    )
  )
  cohortIncidenceModuleSpecifications <- ciModuleSettingsCreator$createModuleSpecifications(
    irDesign = irDesign$toList()
  )
  return(cohortIncidenceModuleSpecifications)
}

#' Create the CohortMethod module specifications
#'
#' @description
#' This function will create the CohortMethod module specifications.
#' 
#' @param tcis The target/comparator/indication/subset (tcis) list of lists
#' @param dfUniqueTcis A data.frame of unique 
#' target/comparator/indication/subset combinations created from
#' @seealso[getUniqueTcis()]
#' @param cohortDefinitionSet The cohorts used in the study
#' @param outcomes The outcomes and clean windows used in the study
#' @param negativeControlOutcomeCohortSet Negative control outcome cohorts
#' for the study
#' @param timeAtRisks The time-at-risks used in the study
#' included in the cohorts? Default is TRUE
#' @param studyStartDate Restrict the study to a specific start date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param studyEndDate Restrict the study to a specific end date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param useCleanWindowForPriorOutcomeLookback If FALSE, lookback window 
#' is all time prior, i.e., including only first events. Default is FALSE
#' @param cmMaxCohortSizeForFitting If the target or comparator cohort are 
#' larger than this number, they will be downsampled before fitting the 
#' propensity model. The model will be used to compute propensity scores for 
#' all subjects. The purpose of the sampling is to gain speed. Setting this 
#' number to 0 means no downsampling will be applied. Default is 250,000
#' @param cmMaxCovBalanceCohortSize If the target or comparator cohort are 
#' larger than this number, they will be downsampled before computing covariate 
#' balance to save time. Setting this number to 0 means no downsampling 
#' will be applied. Default is 250,000
#' @param psMatchMaxRatio The maximum number of persons in the comparator arm 
#' to be matched to each person in the treatment arm. A maxRatio of 0 means no 
#' maximum: all comparators will be assigned to a target person. Default is 1.
#' @param restrictToCommonPeriod Restrict the analysis to the period when 
#' both treatments are observed? Default is TRUE
#' @return
#' CohortMethod module specifications
createCohortMethodModuleSpecifications <- function(
    tcis,
    dfUniqueTcis,
    cohortDefinitionSet, 
    outcomes,
    negativeControlOutcomeCohortSet,
    timeAtRisks,
    studyStartDate = "",
    studyEndDate = "",
    useCleanWindowForPriorOutcomeLookback = FALSE,
    cmMaxCohortSizeForFitting = 250000,
    cmMaxCovBalanceCohortSize = 250000,
    psMatchMaxRatio = 1,
    restrictToCommonPeriod = TRUE
) {
  cmModuleSettingsCreator <- CohortMethodModule$new()
  covariateSettings <- FeatureExtraction::createDefaultCovariateSettings(
    addDescendantsToExclude = TRUE # Keep TRUE because you're excluding concepts
  )
  
  # code below errors if same outcome with different cleanWindows - should we enable?
  outcomeList <- append(
    lapply(seq_len(nrow(outcomes)), function(i) {
      if (useCleanWindowForPriorOutcomeLookback)
        priorOutcomeLookback <- outcomes$cleanWindow[i]
      else
        priorOutcomeLookback <- 99999
      CohortMethod::createOutcome(
        outcomeId = outcomes$cohortId[i],
        outcomeOfInterest = TRUE,
        trueEffectSize = NA,
        priorOutcomeLookback = priorOutcomeLookback
      )
    }),
    lapply(negativeControlOutcomeCohortSet$cohortId, function(i) {
      CohortMethod::createOutcome(
        outcomeId = i,
        outcomeOfInterest = FALSE,
        trueEffectSize = 1
      )
    })
  )
  # removing any duplicates
  outcomeList <- unique(outcomeList)
  
  targetComparatorOutcomesList <- list()
  for (i in seq_along(tcis)) {
    tci <- tcis[[i]]
    # Get the subset definition ID that matches
    # the target ID. The comparator will also use the same subset
    # definition ID
    currentSubsetDefinitionId <- dfUniqueTcis |>
      dplyr::filter(cohortId == tci$targetId &
                      indicationId == paste(tci$indicationId, collapse = ",") &
                      genderConceptIds == paste(tci$genderConceptIds, collapse = ",") &
                      minAge == paste(tci$minAge, collapse = ",") &
                      maxAge == paste(tci$maxAge, collapse = ",")) |>
      dplyr::pull(subsetDefinitionId)
    targetId <- cohortDefinitionSet |>
      dplyr::filter(subsetParent == tci$targetId & subsetDefinitionId == currentSubsetDefinitionId) |>
      dplyr::pull(cohortId)
    comparatorId <- cohortDefinitionSet |>
      dplyr::filter(subsetParent == tci$comparatorId & subsetDefinitionId == currentSubsetDefinitionId) |>
      dplyr::pull(cohortId)
    targetComparatorOutcomesList[[i]] <- CohortMethod::createTargetComparatorOutcomes(
      targetId = targetId,
      comparatorId = comparatorId,
      outcomes = outcomeList,
      excludedCovariateConceptIds = c(tci$excludedCovariateConceptIds, covariateConceptsToExclude)
    )
  }
  getDbCohortMethodDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(
    restrictToCommonPeriod = restrictToCommonPeriod,
    studyStartDate = studyStartDate,
    studyEndDate = studyEndDate,
    maxCohortSize = 0,
    covariateSettings = covariateSettings
  )
  createPsArgs = CohortMethod::createCreatePsArgs(
    maxCohortSizeForFitting = cmMaxCohortSizeForFitting,
    errorOnHighCorrelation = TRUE,
    stopOnError = FALSE, # Setting to FALSE to allow Strategus complete all CM operations; when we cannot fit a model, the equipoise diagnostic should fail
    estimator = "att",
    prior = Cyclops::createPrior(
      priorType = "laplace", 
      exclude = c(0), 
      useCrossValidation = TRUE
    ),
    control = Cyclops::createControl(
      noiseLevel = "silent", 
      cvType = "auto", 
      seed = 1, 
      resetCoefficients = TRUE, 
      tolerance = 2e-07, 
      cvRepetitions = 1, 
      startingVariance = 0.01
    )
  )
  matchOnPsArgs = CohortMethod::createMatchOnPsArgs(
    maxRatio = psMatchMaxRatio,
    caliper = 0.2,
    caliperScale = "standardized logit",
    allowReverseMatch = FALSE,
    stratificationColumns = c()
  )
  # stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs(
  #   numberOfStrata = 5,
  #   stratificationColumns = c(),
  #   baseSelection = "all"
  # )
  computeSharedCovariateBalanceArgs = CohortMethod::createComputeCovariateBalanceArgs(
    maxCohortSize = cmMaxCovBalanceCohortSize,
    covariateFilter = NULL
  )
  computeCovariateBalanceArgs = CohortMethod::createComputeCovariateBalanceArgs(
    maxCohortSize = cmMaxCovBalanceCohortSize,
    covariateFilter = FeatureExtraction::getDefaultTable1Specifications()
  )
  fitOutcomeModelArgs = CohortMethod::createFitOutcomeModelArgs(
    modelType = "cox",
    stratified = psMatchMaxRatio != 1,
    useCovariates = FALSE,
    inversePtWeighting = FALSE,
    prior = Cyclops::createPrior(
      priorType = "laplace", 
      useCrossValidation = TRUE
    ),
    control = Cyclops::createControl(
      cvType = "auto", 
      seed = 1, 
      resetCoefficients = TRUE,
      startingVariance = 0.01, 
      tolerance = 2e-07, 
      cvRepetitions = 1, 
      noiseLevel = "quiet"
    )
  )
  cmAnalysisList <- list()
  for (i in seq_len(nrow(timeAtRisks))) {
    createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(
      firstExposureOnly = FALSE,
      washoutPeriod = 0,
      removeDuplicateSubjects = "keep first",
      censorAtNewRiskWindow = TRUE,
      removeSubjectsWithPriorOutcome = TRUE,
      priorOutcomeLookback = 99999,
      riskWindowStart = timeAtRisks$riskWindowStart[[i]],
      startAnchor = timeAtRisks$startAnchor[[i]],
      riskWindowEnd = timeAtRisks$riskWindowEnd[[i]],
      endAnchor = timeAtRisks$endAnchor[[i]],
      minDaysAtRisk = 1,
      maxDaysAtRisk = 99999
    )
    cmAnalysisList[[i]] <- CohortMethod::createCmAnalysis(
      analysisId = i,
      description = sprintf(
        "Cohort method, %s",
        timeAtRisks$label[i]
      ),
      getDbCohortMethodDataArgs = getDbCohortMethodDataArgs,
      createStudyPopArgs = createStudyPopArgs,
      createPsArgs = createPsArgs,
      matchOnPsArgs = matchOnPsArgs,
      # stratifyByPsArgs = stratifyByPsArgs,
      computeSharedCovariateBalanceArgs = computeSharedCovariateBalanceArgs,
      computeCovariateBalanceArgs = computeCovariateBalanceArgs,
      fitOutcomeModelArgs = fitOutcomeModelArgs
    )
  }
  cohortMethodModuleSpecifications <- cmModuleSettingsCreator$createModuleSpecifications(
    cmAnalysisList = cmAnalysisList,
    targetComparatorOutcomesList = targetComparatorOutcomesList,
    analysesToExclude = NULL,
    refitPsForEveryOutcome = FALSE,
    refitPsForEveryStudyPopulation = FALSE,  
    cmDiagnosticThresholds = CohortMethod::createCmDiagnosticThresholds()
  )
  
  return(cohortMethodModuleSpecifications)
}

#' Create the SelfControlledCaseSeries module specifications
#'
#' @description
#' This function will create the SelfControlledCaseSeries module specifications.
#' 
#' @param tcis The target/comparator/indication/subset (tcis) list of lists
#' @param cohortDefinitionSet The cohorts used in the study
#' @param outcomes The outcomes and clean windows used in the study
#' @param negativeControlOutcomeCohortSet Negative control outcome cohorts
#' for the study
#' @param timeAtRisks The time-at-risks used in the study
#' included in the cohorts? Default is TRUE
#' @param studyStartDate Restrict the study to a specific start date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param studyEndDate Restrict the study to a specific end date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param useCleanWindowForPriorOutcomeLookback If there are more than this 
#' number of cases for a single outcome cases will be sampled to this size. 
#' maxCasesPerOutcome = 0 indicates no maximum size. Default is 100,000,
#' mostly used to limit computation for negative controls. 
#' @return
#' SelfControlledCaseSeries module specifications
createSelfControlledCaseSeriesModuleSpecifications <- function(
    tcis,
    cohortDefinitionSet, 
    outcomes,
    negativeControlOutcomeCohortSet,
    timeAtRisks,
    studyStartDate = "",
    studyEndDate = "",
    sccsMaxCasesPerOutcome = 100000
) {
  sccsModuleSettingsCreator <- SelfControlledCaseSeriesModule$new()
  uniqueTargetIndicationsDemo <- lapply(tcis,
                                        function(x) data.frame(
                                          exposureId = c(x$targetId, x$comparatorId),
                                          nestingCohortId = if (is.null(x$indicationId)) NA else x$indicationId,
                                          genderConceptIds = paste(x$genderConceptIds, collapse = ","),
                                          minAge = if (is.null(x$minAge)) NA else x$minAge,
                                          maxAge = if (is.null(x$maxAge)) NA else x$maxAge
                                        )) |>
    dplyr::bind_rows() |>
    dplyr::distinct()
  
  targetInds <- uniqueTargetIndicationsDemo %>%
    dplyr::select("exposureId", "nestingCohortId") %>%
    dplyr::distinct() 
  
  sccsDemoIds <- uniqueTargetIndicationsDemo %>%
    dplyr::select("genderConceptIds", "minAge", "maxAge") %>% 
    dplyr::distinct() %>%
    dplyr::mutate(analysisId = dplyr::row_number())
  
  # add the rowIds as we will use this for the excludes
  # as SCCS wants to do cartesian of targetInd and demo
  uniqueTargetIndicationsDemo <- uniqueTargetIndicationsDemo %>%
    dplyr::inner_join(
      y = sccsDemoIds,
      by = c("genderConceptIds", "minAge", "maxAge")
    ) 

  # now do the target/ind based on the targetInds
  eoList <- list()
  for (i in seq_len(nrow(targetInds))) {
    targetIndication <- targetInds[i, ]
    currentIndicationId <- NULL
    if (!is.na(targetIndication$nestingCohortId)) {
      currentIndicationId <- targetIndication$nestingCohortId
    }
    
    # Specify the indication/outcome pairs for the current exposure
    for (outcomeId in unique(outcomes$cohortId)) {
      eoList[[length(eoList) + 1]] <- SelfControlledCaseSeries::createExposuresOutcome(
        outcomeId = outcomeId,
        nestingCohortId = currentIndicationId,
        exposures = list(
          SelfControlledCaseSeries::createExposure(
            exposureId = targetIndication$exposureId,
            trueEffectSize = NA
          )
        )
      )
    }
    
    # Specify the indication/negative control outcome pairs for the current exposure
    for (outcomeId in negativeControlOutcomeCohortSet$cohortId) {
      eoList[[length(eoList) + 1]] <- SelfControlledCaseSeries::createExposuresOutcome(
        outcomeId = outcomeId,
        nestingCohortId = currentIndicationId,
        exposures = list(SelfControlledCaseSeries::createExposure(
          exposureId = targetIndication$exposureId, 
          trueEffectSize = 1
        ))
      )
    }
    
  }
  
  # now do the analyses based on the demos
  sccsAnalysisList <- list()
  for (i in seq_len(nrow(sccsDemoIds))) {
    demo <- sccsDemoIds[i, ]
    
    getDbSccsDataArgs <- SelfControlledCaseSeries::createGetDbSccsDataArgs(
      maxCasesPerOutcome = sccsMaxCasesPerOutcome,
      studyStartDates = if (studyStartDate == "") NULL else studyStartDate,
      studyEndDates = if (studyEndDate == "") NULL else studyEndDate,
      deleteCovariatesSmallCount = 0
    )
    createStudyPopulationArgs = SelfControlledCaseSeries::createCreateStudyPopulationArgs(
      firstOutcomeOnly = TRUE,
      naivePeriod = 365,
      minAge = if (is.na(demo$minAge)) NULL else demo$minAge,
      maxAge = if (is.na(demo$maxAge)) NULL else demo$maxAge
    )
    covarPreExp <- SelfControlledCaseSeries::createEraCovariateSettings(
      label = "Pre-exposure",
      includeEraIds = "exposureId",
      start = -30,
      startAnchor = "era start",
      end = -1,
      endAnchor = "era start",
      firstOccurrenceOnly = FALSE,
      allowRegularization = FALSE,
      profileLikelihood = FALSE,
      exposureOfInterest = FALSE
    )
    calendarTimeSettings <- SelfControlledCaseSeries::createCalendarTimeCovariateSettings(
      calendarTimeKnots = 5,
      allowRegularization = TRUE,
      computeConfidenceIntervals = FALSE
    )
    seasonalitySettings <- SelfControlledCaseSeries::createSeasonalityCovariateSettings(
      seasonKnots = 5,
      allowRegularization = TRUE,
      computeConfidenceIntervals = FALSE
    )
    # Use grid with gradients likelihood approximation:
    fitSccsModelArgs <- SelfControlledCaseSeries::createFitSccsModelArgs(
      profileGrid = seq(log(0.1), log(10), length.out = 8),
      profileBounds = NULL
    )
    for (j in seq_len(nrow(timeAtRisks))) {
      covarExposureOfInt <- SelfControlledCaseSeries::createEraCovariateSettings(
        label = "Main",
        includeEraIds = "exposureId",
        start = timeAtRisks$riskWindowStart[j],
        startAnchor = gsub("cohort", "era", timeAtRisks$startAnchor[j]),
        end = timeAtRisks$riskWindowEnd[j],
        endAnchor = gsub("cohort", "era", timeAtRisks$endAnchor[j]),
        firstOccurrenceOnly = FALSE,
        allowRegularization = FALSE,
        profileLikelihood = TRUE,
        exposureOfInterest = TRUE
      )
      createSccsIntervalDataArgs <- SelfControlledCaseSeries::createCreateSccsIntervalDataArgs(
        eraCovariateSettings = list(covarPreExp, covarExposureOfInt),
        seasonalityCovariateSettings = seasonalitySettings,
        calendarTimeCovariateSettings = calendarTimeSettings
      )
      description <- "SCCS"
      if (demo$genderConceptIds == "8507") {
        description <- sprintf("%s, male", description)
      } else if (demo$genderConceptIds == "8532") {
        description <- sprintf("%s, female", description)
      }
      if (!is.na(demo$minAge) || !is.na(demo$maxAge)) {
        description <- sprintf("%s, age %s-%s",
                               description,
                               if(is.na(demo$minAge)) "" else demo$minAge,
                               if(is.na(demo$maxAge)) "" else demo$maxAge)
      }
      description <- sprintf("%s, %s", description, timeAtRisks$label[j])
      sccsAnalysisList[[length(sccsAnalysisList) + 1]] <- SelfControlledCaseSeries::createSccsAnalysis(
        analysisId = length(sccsAnalysisList) + 1,
        description = description,
        getDbSccsDataArgs = getDbSccsDataArgs,
        createStudyPopulationArgs = createStudyPopulationArgs,
        createIntervalDataArgs = createSccsIntervalDataArgs,
        fitSccsModelArgs = fitSccsModelArgs
      )
    }
  }
  
  # now figure out what to exclude
  includeSccs <- uniqueTargetIndicationsDemo %>% 
    dplyr::select("exposureId","nestingCohortId", "analysisId") %>%
    dplyr::distinct()
  
  # remove the included from all combinations to get the combinations you dont want
  analysesToExclude <- expand.grid(
    exposureId = unique(uniqueTargetIndicationsDemo$exposureId),
    analysisId = unique(uniqueTargetIndicationsDemo$analysisId),
    nestingCohortId = unique(uniqueTargetIndicationsDemo$nestingCohortId)
  ) |>
    dplyr::anti_join(includeSccs, by = dplyr::join_by(exposureId, analysisId,nestingCohortId))
  
  if (nrow(analysesToExclude) == 0) {
    analysesToExclude <- NULL  
  }
  
  sccsAnalysesSpecifications <- SelfControlledCaseSeries::createSccsAnalysesSpecifications(
    sccsAnalysisList = sccsAnalysisList,
    exposuresOutcomeList = eoList,
    analysesToExclude = analysesToExclude,
    combineDataFetchAcrossOutcomes = FALSE,
    sccsDiagnosticThresholds = SelfControlledCaseSeries::createSccsDiagnosticThresholds()
  )
  
  selfControlledModuleSpecifications <- sccsModuleSettingsCreator$createModuleSpecifications(
    sccsAnalysesSpecifications = sccsAnalysesSpecifications$toList()
  )
  
  return(selfControlledModuleSpecifications)
}

#' Create the PatientLevelPrediction module specifications
#'
#' @description
#' This function will create the PatientLevelPrediction module specifications.
#' 
#' @param tcis The target/comparator/indication/subset (tcis) list of lists
#' @param dfUniqueTcis A data.frame of unique 
#' target/comparator/indication/subset combinations created from
#' @seealso[getUniqueTcis()]
#' @param cohortDefinitionSet The cohorts used in the study
#' @param outcomes The outcomes and clean windows used in the study
#' @param negativeControlOutcomeCohortSet Negative control outcome cohorts
#' for the study
#' @param timeAtRisks The time-at-risks used in the study
#' included in the cohorts? Default is TRUE
#' @param studyStartDate Restrict the study to a specific start date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param studyEndDate Restrict the study to a specific end date?
#' Default is "" and any value must be formatted as YYYYMMDD
#' @param useCleanWindowForPriorOutcomeLookback If FALSE, lookback window 
#' is all time prior, i.e., including only first events. Default is FALSE
#' @param plpMaxSampleSize If not NULL, the number of people to sample from the 
#' target cohort. Default is 1,000,000,
#' @return
#' PatientLevelPrediction module specifications
createPatientLevelPredictionModuleSpecifications <- function(
    tcis,
    dfUniqueTcis, 
    cohortDefinitionSet, 
    outcomes,
    timeAtRisks,
    studyStartDate = "",
    studyEndDate = "",
    useCleanWindowForPriorOutcomeLookback = FALSE,
    plpMaxSampleSize = 1000000
) {
  plpModuleSettingsCreator <- PatientLevelPredictionModule$new()
  modelDesignList <- list()
  uniqueTargetIds <- unique(unlist(lapply(tcis, function(x) { c(x$targetId ) })))
  dfUniqueTis <- dfUniqueTcis[dfUniqueTcis$cohortId %in% uniqueTargetIds, ]
  for (i in 1:nrow(dfUniqueTis)) {
    tci <- dfUniqueTis[i,]
    cohortId <- cohortDefinitionSet |> 
      dplyr::filter(subsetParent == tci$cohortId & subsetDefinitionId == tci$subsetDefinitionId) |>
      dplyr::pull(cohortId)
    for (j in seq_len(nrow(timeAtRisks))) {
      for (k in seq_len(nrow(outcomes))) {
        if (useCleanWindowForPriorOutcomeLookback)
          priorOutcomeLookback <- outcomes$cleanWindow[k]
        else
          priorOutcomeLookback <- 99999
        modelDesignList[[length(modelDesignList) + 1]] <- PatientLevelPrediction::createModelDesign(
          targetId = cohortId,
          outcomeId = outcomes$cohortId[k],
          restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(
            sampleSize = plpMaxSampleSize,
            studyStartDate = studyStartDate,
            studyEndDate = studyEndDate,
            firstExposureOnly = FALSE,
            washoutPeriod = 0
          ),
          populationSettings = PatientLevelPrediction::createStudyPopulationSettings(
            riskWindowStart = timeAtRisks$riskWindowStart[j],
            startAnchor = timeAtRisks$startAnchor[j],
            riskWindowEnd = timeAtRisks$riskWindowEnd[j],
            endAnchor = timeAtRisks$endAnchor[j],
            removeSubjectsWithPriorOutcome = TRUE,
            priorOutcomeLookback = priorOutcomeLookback,
            requireTimeAtRisk = FALSE,
            binary = TRUE,
            includeAllOutcomes = TRUE,
            firstExposureOnly = FALSE,
            washoutPeriod = 0,
            minTimeAtRisk = timeAtRisks$riskWindowEnd[j] - timeAtRisks$riskWindowStart[j],
            restrictTarToCohortEnd = FALSE
          ),
          covariateSettings = FeatureExtraction::createCovariateSettings(
            useDemographicsGender = TRUE,
            useDemographicsAgeGroup = TRUE,
            useConditionGroupEraLongTerm = TRUE,
            useDrugGroupEraLongTerm = TRUE,
            useVisitConceptCountLongTerm = TRUE
          ),
          preprocessSettings = PatientLevelPrediction::createPreprocessSettings(),
          modelSettings = PatientLevelPrediction::setLassoLogisticRegression()
        )
      }
    }
  }
  plpModuleSpecifications <- plpModuleSettingsCreator$createModuleSpecifications(
    modelDesignList = modelDesignList
  )
  
  return(plpModuleSpecifications)
}