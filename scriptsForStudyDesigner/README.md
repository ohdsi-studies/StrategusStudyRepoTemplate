# Design Your Study

The following sections will highlight the steps required to design your study and to run [Strategus](https://github.com/OHDSI/Strategus). At this point, these instructions assume you have created a protocol for your study, designed and evaluated your cohorts and other inputs for your study and have approval to execute. 

## Download Study Assets

The `DownloadAssets.R` script is used to download the cohorts used in your study from ATLAS. Once you have run this script, your study cohorts will live in the `inst` subfolder of this project. **NOTE**: If you change your cohorts in ATLAS you . Please see the instructions in the script for more details on how to enumerate the cohorts to download. 

## Create the analysis specification

The `CreateStrategusAnalysisSpecifications.R` script is used to create the analysis specification JSON that is the input into running your study via Strategus. This script is designed to be general purpose for executing HADES modules for characterization, estimation and prediction via Strategus. Here we will discuss how to work with this file for the design of your study. 

### Intent of this script

This script was created with the intent that it is used as the framework for large-scale analytics. This means that it is designed to run all analyses across the full set of target-comparator-outcomes that are specified in this script. We have designed this script to provide sections for user input such that users should only focus on editing these code sections and leave the remainder of the script untouched. The remainder of the script reflects OHDSI best-practices around large-scale execution of the various HADES packages and should only be changed with purpose, not just for experimentation.

### Editing `CreateStrategusAnalysisSpecifications.R`

The very top part of the script should not be changed:

```r
library(Strategus)
library(tibble)
config <- config::get()

negativeControlOutcomeCohortSet <- CohortGenerator::readCsv(
  file = file.path(config$projectRootFolder, "inst", "negativeControlOutcomes.csv")
)

covariateConceptsToExclude <- CohortGenerator::readCsv(
  file = file.path(config$projectRootFolder, "inst", "covariateConceptsToExclude.csv")
) |>
  dplyr::pull("conceptId")

cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = file.path(config$projectRootFolder, "inst", "Cohorts.csv"),
  jsonFolder = file.path(config$projectRootFolder, "inst", "cohorts"),
  sqlFolder = file.path(config$projectRootFolder, "inst", "sql", "sql_server")
)
```

This code block is loading the libraries, cohorts, negative controls and covariates to exclude to define the study in the remainder of the script. There is no need to change this code. After this section, you'll want to update the code in the section starting with `tcis` with the inputs for your study. This script contains a sample study and you'll want to update this to reflect the design/inputs for your study.

### Target-Comparator-Indication-Subgroup (tcis)

The Target-Comparator-Indication-Subgroup (tcis) is a list-of-lists - the idea here is that you will specify the Target-Comparator for your study and if necessary the indication cohort and subgroup settings. The `targetId`,`comparatorId` and `indicationId` must refer to cohort IDs from the production ATLAS instance. The `targetId` and `comparatorId` and mandatory. The indication cohort is optional and can be used if you'd like to subgroup your target/comparator cohorts by an indication cohort. You can set `indicationId` to NULL if you do not need to subgroup your target/comparator cohorts. Additionally, you can use `genderConceptIds`, `minAge`, `maxAge` to subgroup the target/comparator to a specific gender or to specific age ranges. The `excludedCovariateConceptIds` is a list of concept IDs that cannot be used to construct covariates when performing estimation. This is to be used only for exclusion concepts that are specific to the target-comparator combination. More details about this specific setting are found [here](https://ohdsi.github.io/CohortMethod/reference/createTargetComparatorOutcomes.html). If you have multiple Target-Comparators for your study, you will add another `list()` entry to the `tcis` list. Below is an example for reference.

```r
tcis <- list(
  list(
    targetId = 2245, # New users of ACE inhibitors
    comparatorId = 13204, # New users of Alpha-1 Blockers
    indicationId = 9900, # Hypertension
    genderConceptIds = c(8507, 8532), # use valid genders (remove unknown)
    minAge = NULL, # All ages In years. Can be NULL
    maxAge = NULL, # All ages In years. Can be NULL
    excludedCovariateConceptIds = c(
      1341238,
      1350489,
      1363053,
      1308216,
      1310756,
      1331235,
      1334456,
      1335471,
      1340128,
      1341927,
      1342439,
      1363749,
      1373225
    ) 
  ),
  list(
    targetId = 2245, # New users of ACE inhibitors
    comparatorId = 13203, # New users of TZD
    indicationId = 9900, # Hypertension
    genderConceptIds = c(8507, 8532), # use valid genders (remove unknown)
    minAge = NULL, # All ages In years. Can be NULL
    maxAge = NULL, # All ages In years. Can be NULL
    excludedCovariateConceptIds = c(
      1341238,
      1350489,
      1363053,
      1308216,
      1310756,
      1331235,
      1334456,
      1335471,
      1340128,
      1341927,
      1342439,
      1363749,
      1373225
    ) 
  )
)
```

### Outcomes

The next object `outcomes` holds a tribble (data.frame) of the outcomes of interest for your study. Here the `~cohortId, ~cleanWindow` define the columns for the tribble. Each line below defines a new row in the tribble where `cohortId` is the outcome cohort ID from the production ATLAS. The `cleanWindow` is the number of days that are required between outcome events to be considered a "new" outcome. More details about the `cleanWindow` (named priorOutcomeLookback) are described
[here](https://ohdsi.github.io/CohortMethod/reference/createOutcome.html).

The following shows 1 outcome and 1 clean window for reference,

```r
outcomes <- tibble::tribble(
  ~cohortId, ~cleanWindow,
  3,    365,          # GI Bleed
)
```

In this example, outcome `cohortId = 3` has a clean window of `365` days.

### Time-at-risk (TAR)

Next you will specify the time-at-risk periods for the Cohort Chacterization, Cohort Incidence and Cohort Method analyses. An example is shown below. 

```r
timeAtRisks <- tibble::tribble(
  ~label,         ~riskWindowStart, ~startAnchor,   ~riskWindowEnd, ~endAnchor,
  "On treatment", 1,                "cohort start", 0,              "cohort end"
)
```

The Self-Controlled Case Series warrants its own time-at-risk windows and these are specified in the same way as earlier but in a different tibble called `sccsTimeAtRisks`.

```r
# Try to avoid intent-to-treat TARs for SCCS, or then at least disable calendar time spline:
sccsTimeAtRisks <- tibble::tribble(
  ~label,         ~riskWindowStart, ~startAnchor,   ~riskWindowEnd, ~endAnchor,
  "On treatment", 1,                "cohort start", 0,              "cohort end"
)
```

Similarly Patient-Level Prediction should use fixed-time windows and warrants its own specification stored in `plpTimeAtRisks`.

```r
# Try to use fixed-time TARs for patient-level prediction:
plpTimeAtRisks <- tibble::tribble(
  ~riskWindowStart, ~startAnchor,   ~riskWindowEnd, ~endAnchor,
  1,                "cohort start", 365,            "cohort start"
)
```

### Calendar time restriction

The following settings allow you to restrict your study to a specific start/end date. Dates must be specified as `YYYYMMDD` as described below:

```r
studyStartDate <- "" # YYYYMMDD, e.g. "2001-02-01" for January 1st, 2001
studyEndDate <- "" # YYYYMMDD
```

You can specify these in 3 ways: start date only, end date only or a full date range (start & end date). These dates are then used in the script in 2 ways: first, they will be used when creating the cohort subsets to limit the cohorts based on the start/end dates specified. These dates will then be used to restrict the Cohort Method, Self-Controlled Case Series and Patient-Level Prediction analyses to this date range.

### Create the analysis specification

Once you have made the changes to the `CreateStrategusAnalysisSpecifications.R` to reflect the design of your study (as described above), you can run the full script to produce the `analysisSpecification.json` for your study. You only need to run this script **one time**. Once the `analysisSpecification.json` is created, you are ready to run your study via Strategus.

### Frequently Asked Questions

1. **What if I don't need/want to use all HADES modules in my study?** You can remove/comment out code in `CreateStrategusAnalysisSpecifications.R` based on your study needs. The easiest approach is commenting out/removing any unnecessary modules from the `moduleSpecList` at the bottom of the script which will remove them from the analysis specification entirely. You may optionally remove any code pertaining to modules that are not part of your study. 
2. **Do I have to use`CreateStrategusAnalysisSpecifications.R` to create my study's analysis specification?** No, you do not! You can create your own analysis specification using Strategus and HADES modules. If you go this route, you can use `CreateStrategusAnalysisSpecifications.R` for reference to make sure you are carrying over OHDSI best-practices around large-scale execution of the various HADES packages.
3. **Do I need to regenerate the analysis specification every time I run the study?** No, this is a one time activity and is used to capture your study design in the analysis specification JSON file. If you change your cohorts, you should re-run `DownloadAssets.R` and then recreate your analysis specification (which includes your cohort definitions) by running `CreateStrategusAnalysisSpecifications.R`.