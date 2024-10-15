Using the Strategus Study Repo Template
=================

This guide will walk through how to use the Strategus study repo template to set
up a project for an OHDSI Network study. This guide assumes you are familiar
with the [OHDSI Network Study
principles](https://ohdsi.github.io/TheBookOfOhdsi/StudySteps.html) and [OHDSI
Network Research](https://ohdsi.github.io/TheBookOfOhdsi/NetworkResearch.html)
chapters in the Book of OHDSI. 

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

Additional packages may be required, for example the [ROhdsiWebApi](https://github.com/OHDSI/ROhdsiWebApi) which is used to download cohorts. If you need this package or any others, you can install them using `remotes::install_github()` for GitHub hosted packages or `install.packages()` if it is on CRAN.

## Design Your Study

To start, ensure you have defined the cohorts and negative control outcomes necessary for your study. This guide will assume you are using [ATLAS](https://atlas-demo.ohdsi.org/). The [DownloadCohorts.R](DownloadCohorts.R) provides an example to show how this is done to download and store cohorts/negative control outcomes in the study project.

Next, review the [Creating Analysis Specifications Documentation](https://ohdsi.github.io/Strategus/articles/CreatingAnalysisSpecification.html) 
on the Strategus repository. This will provide an overview of using Strategus to 
construct the analysis specification which captures the inputs for your study.

This repository contains a script called `CreateStrategusAnalysisSpecification.R` which you can use to start setting up your study. This script contains...<TODO>.

### Cohorts

<TODO>

https://github.com/OHDSI/PhenotypeLibrary/
https://academy.ehden.eu/course/index.php?categoryid=all



### Analytical Choices

<TODO>

#### Characterization

<TODO>

#### Estimation

<TODO>

#### Prediction

<TODO>

## Executing the study

<TODO>

See https://ohdsi.github.io/Strategus/articles/ExecuteStrategus.html

`StrategusCodeToRun.R`

## Review Results

<TODO>

## Provide Results To Study Coordinator

<TODO>


