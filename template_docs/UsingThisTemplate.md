Using the Strategus Study Repo Template
=================

This guide will walk through how to use the Strategus study repo template to set
up a project for an OHDSI Network study. This guide assumes you are familiar
with the [OHDSI Network Study
principles](https://ohdsi.github.io/TheBookOfOhdsi/StudySteps.html) and [OHDSI
Network Research](https://ohdsi.github.io/TheBookOfOhdsi/NetworkResearch.html)
chapters in the Book of OHDSI. If you have any questions on how to use this template please post it as an issue in the [issue tracker](https://github.com/ohdsi-studies/StrategusStudyRepoTemplate/issues).

In this guide we'll assume there are 2 roles:

- 🦸‍♀️ **Project Author**: The project author is the person responsible
for capturing the design decisions based on the
study protocol. This person is responsible for establishing the 
GitHub repository for the study and updating the README.md to register the study on the list of [on-going OHDSI Network
Studies](https://data.ohdsi.org/OhdsiStudies). Additionally, this person should
run the study on their site's OMOP data or on some synthetic data set (i.e. [Eunomia](https://github.com/OHDSI/Eunomia)) to ensure it is in good working
order. Additionally, this person may also have responsibilty for uploading results from participating network sites, setting up the results viewer and running Evidence Synthesis as mentioned in the [Study Execution](https://ohdsi.github.io/TheBookOfOhdsi/NetworkResearch.html#study-execution) section.

- 👩‍🔬 **Site Participant**: The study site participant is responsible for
executing the study against their OMOP CDM, reviewing study results and providing
them back to the network study coordinator. 

This guide is intended for the 🦸‍♀️ **Project Author**. The guide for the 👩‍🔬 **Site Participant** is found in [Study Execution](StudyExecution.md).

The following video is the first in a series of videos for the [OHDSI 2023 Save Our Sisyphus Challenge](https://ohdsi.org/sos-challenge/). The Save Our Sisyphus Challenge was a multi-week effort with a series of presentations to help navigate the process of an OHDSI network study. The first video covers how to inititate a network study and is very helpful to review:

[![How to initiate an OHDSI network study](http://img.youtube.com/vi/Aj4x6g7n3Mc/0.jpg)](http://www.youtube.com/watch?v=Aj4x6g7n3Mc "How to initiate an OHDSI network study")

## Template usage & organization

This project template is designed as a way to get started with using Strategus for running a network study. The R scripts and resources aim to design a sample study to allow you to follow along with the steps in this guide. You will want to review the R scripts and adjust them to the design of your study and later remove the sample study artifacts which are located in the `inst/sampleStudy` folder.

## Setting up your execution environment

This section should be followed by both the 🦸‍♀️ **Project Author** and 👩‍🔬 **Site Participant**.

### Environment setup

- Follow [HADES R Setup guide](https://ohdsi.github.io/Hades/rSetup.html) to configure your R, RStudio & Java environment. 
- Install Python using [Reticulate](https://ohdsi.github.io/PatientLevelPrediction/articles/InstallationGuide.html#creating-python-reticulate-environment). More information on Reticulate is found [here](https://rstudio.github.io/reticulate/).

Note this is covered in the [Study Execution](StudyExecution.md) document as well.

## Establishing your project

The remainder of this document should be followed by the 🦸‍♀️ **Project Author**.

### IMPORTANT - run renv::restore
Call `renv::restore()` to restore the R & Python environment for this project. <ins>**NOTE**: This is mandatory otherwise subsequent steps will not work properly<ins>.

Additional packages may be required, for example the [ROhdsiWebApi](https://github.com/OHDSI/ROhdsiWebApi) which is used to download cohorts. If you need this package or any others, you can install them using `remotes::install_github()` for GitHub hosted packages or `install.packages()` if it is on CRAN. If a package is required for study execution then it must be included in the renv.lock file of the project using [renv::record("package")](https://rstudio.github.io/renv/reference/record.html).

## Design Your Study

### Download cohorts
To start, ensure you have defined the cohorts and negative control outcomes necessary for your study. This guide will assume you are using [ATLAS](https://atlas-demo.ohdsi.org/). The [DownloadCohorts.R](DownloadCohorts.R) provides an example to show how this is done to download and store cohorts/negative control outcomes in the study project.

### Create analysis specifications
Next, review the [Creating Analysis Specifications Documentation](https://ohdsi.github.io/Strategus/articles/CreatingAnalysisSpecification.html) 
on the Strategus repository. This will provide an overview of using Strategus to 
construct the analysis specification which captures the inputs for your study.

This repository contains a script called [CreateStrategusAnalysisSpecification.R](CreateStrategusAnalysisSpecification.R) which you can use to create the analysis specification(s) your study. This script is organzied into sections to allow you to define the cohorts of interest, the time-at-risk and other settings. This script uses all of the Strategus HADES modules for OMOP CDM analytics so you can tailor this script to suit the needs of your study.

At the end of the [CreateStrategusAnalysisSpecification.R](CreateStrategusAnalysisSpecification.R) script, you will see the following code:

```r
# Create the analysis specifications ------------------------------------------
analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addSharedResources(cohortDefinitionShared) |> 
  Strategus::addSharedResources(negativeControlsShared) |>
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortDiagnosticsModuleSpecifications) |>
  Strategus::addModuleSpecifications(characterizationModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortIncidenceModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortMethodModuleSpecifications) |>
  Strategus::addModuleSpecifications(selfControlledModuleSpecifications) |>
  Strategus::addModuleSpecifications(plpModuleSpecifications)
```

In the code above, you may opt to comment out any/all modules you are not planning to use for the study or just remove that module's code all together from the [CreateStrategusAnalysisSpecification.R](CreateStrategusAnalysisSpecification.R). This script will serve as a reference for how you created the analysis specification for the study and **it is not used by 👩‍🔬 Site Participant**.  

Finally you will see the code to save the analysis specification as shown here:

```r
ParallelLogger::saveSettingsToJson(
  analysisSpecifications, 
  file.path("inst", "sampleStudy", "sampleStudyAnalysisSpecification.json")
)
```

You will want to modify the code above to save your analysis specification to the root of the `inst` folder (or anywhere else you feel is appropriate off of the `inst` folder). Its also advisable to remove the `inst/sampleStudy` resources once you've tested your study.

## Executing the study

The instructions for [Study Execution](StudyExecution.md) are found in a seperate file. This file will require an update to reflect the way in which you'd like to have users execute your study. For example you will find placeholders for `YourNetworkStudyName` in that document which should be replaced with something appropriate for your study. Additionally, you may have different analysis specifictions in your study and you can detail that in this file. It may also be easier for 👩‍🔬 **Site Participants** if you include this information directly in the README.md of your project. 

## Working with results

Once you have results for the study, see the [Working With Results](
https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html) vignette which details how to load the results into a PostgreSQL database and use Shiny to view the results. This guide assumes you have access to a PostgreSQL database with access to create a new schema to hold the results of the study. We'll refer to this as the `results` schema. Each study's results should be stored in their own schema to prevent any data collision.

- **CreateResultsDataModel.R**: This script will create the results data model tables based on your analysis specification for the study. This script assumes you have set up your `results` schema ahead of time and have a database account with permissions to create tables.
- **UploadResults.R**: This script will iterate over the files in the "results" subfolder and upload the results to your `results` schema tables. This script assumes that you have successfully created the results tables by running the CreateResultsDataModel.R script (or thorugh some other mechanism for creating the tables).
- **app.R**: This is the Shiny results viewer which will query the `results` schema to obtain results. This script may require modification to remove any modules that were not used in your study.

### Running EvidenceSynthesis

If your study involves population-level estimation, you will want to run the HADES EvidenceSynthesis module to produce a meta-analysis for the databases involved in the study. The HADES EvidenceSynthesis module is designed to run off of the `results` schema once all of the results are uploaded.

The **EvidenceSynthesis.R** script contains the code for defining the EvidenceSynthesis analysis, executing the analysis against the `results` schema and code to create the results tables and upload the results.