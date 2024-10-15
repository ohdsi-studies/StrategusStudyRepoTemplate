Using the Strategus Study Repo Template
=================

This guide will walk through how to use the Strategus study repo template to set
up a project for an OHDSI Network study. This guide assumes you are familiar
with the [OHDSI Network Study
principles](https://ohdsi.github.io/TheBookOfOhdsi/StudySteps.html) and [OHDSI
Network Research](https://ohdsi.github.io/TheBookOfOhdsi/NetworkResearch.html)
chapters in the Book of OHDSI. 

The following video is a helpful resource to get started with an OHDSI network study and covers some of the topics in this guide:

[![IMAGE ALT TEXT](http://img.youtube.com/vi/Aj4x6g7n3Mc/0.jpg)](http://www.youtube.com/watch?v=Aj4x6g7n3Mc "Initiate a network study")

The above video was part of the [OHDSI 2023 Save Our Sisyphus Challenge](https://ohdsi.org/sos-challenge/) which includes additional resources for network studies.

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

We'll reference the 🦸‍♀️ **Project Author** and 👩‍🔬 **Site Participant** throughout this guide.

## Setting up your execution environment

This section should be followed by both the 🦸‍♀️ **Project Author** and 👩‍🔬 **Site Participant**.

### Environment setup

- Follow [HADES R Setup guide](https://ohdsi.github.io/Hades/rSetup.html) to configure your R, RStudio & Java environment. 
- Install Python using [Reticulate](https://ohdsi.github.io/PatientLevelPrediction/articles/InstallationGuide.html#creating-python-reticulate-environment). More information on Reticulate is found [here](https://rstudio.github.io/reticulate/).

## Establishing your project

This section should be followed by the 🦸‍♀️ **Project Author**.




- Call `renv::restore()` to restore the R & Python environment for this project. **NOTE**: This is mandatory otherwise subsequent steps will not work properly.

## Design Your Study

To start, review the [Creating Analysis Specifications Documentation](https://ohdsi.github.io/Strategus/articles/CreatingAnalysisSpecification.html) 
on the Strategus repository. This will provide an overview of using Strategus to 
construct the analysis specification which captures the inputs for your study.

This repository contains a script called `CreateStrategusAnalysisSpecification.R` which
you can use to start setting up your study. This script contains...<TODO>.

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


