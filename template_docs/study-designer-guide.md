# Study Designer Guide

This guide is for the person or team adapting this template into a specific Strategus network study.

The Study Designer translates the protocol and study design decisions into executable study assets. In this repository, that usually means updating the study metadata, reviewing the protocol materials, downloading or preparing cohorts, reviewing starting assets such as negative controls and covariates to exclude, creating the Strategus analysis specification, and testing the study before sharing it with participating sites.

Before using this guide, review the [Prerequisites](prerequisites.md).

## Study Design Workflow

A typical Study Designer workflow is:

1. Define the study protocol and analytic design.
2. Update the repository metadata and configuration.
3. Prepare cohort definitions and other study assets.
4. Review and edit the provided negative controls and covariates to exclude.
5. Create the Strategus analysis specification.
6. Test the study locally.
7. Prepare the repository and instructions for Site Participants.

## Update Study Metadata

Start with the root `README.md`. OHDSI study repositories are expected to include study metadata that can be used to populate the OHDSI study list.

The template in `template_docs/templateREADME.md` shows the expected fields, including:

- Study title and status badge.
- Analytics use case.
- Study type.
- Study lead and contact information.
- Study dates.
- Protocol, publication, and results explorer links.

Rename the `.Rproj` file so it matches the repository name for the finalized study. For example, if the study repository is named `ExampleNetworkStudy`, rename `StrategusStudyRepoTemplate.Rproj` to `ExampleNetworkStudy.Rproj`. This makes the project easier for Site Participants to recognize and open in RStudio.

## Review Configuration

Review `config.yml` early. It contains shared values used by the Study Designer and Study Coordinator workflows, including study asset locations, analysis specification filenames, results database settings, EvidenceSynthesis folders, SFTP download settings, and results-viewer settings.

At minimum, review:

- `studyName`: the human-readable name used by study coordination and the Shiny results viewer.
- `resultsDatabaseSchema`: the schema where aggregate results will be loaded by the Study Coordinator. Its recommended to use lower-case and avoid any SQL reserved characters.
- `webApiUrl`: the ATLAS/WebAPI endpoint used to download cohort definitions.
- `projectRootFolder`: the root folder used by scripts to find study assets.
- `resultFolder`: the folder where collected site results are expected when uploading results centrally.
- `evidenceSynthesisResultFolder`: the folder where EvidenceSynthesis aggregate outputs will be written.
- `evidenceSynthesisWorkFolder`: the folder where EvidenceSynthesis intermediate files will be written.
- `studySpecificationFileName`: the Strategus analysis specification used by `ExecuteAnalyses.R`.
- `evidenceSynthesisSpecificationFileName`: the Strategus analysis specification used for EvidenceSynthesis.
- `resultsConnectionDetails`: the Study Coordinator's connection to the PostgreSQL results database.
- Shiny viewer settings: values used when launching or hosting a results viewer.
- SFTP settings: values used only if the study uses secure SFTP for result ZIP sharing.

The default values are placeholders or template defaults. Update them to match the study before distributing the repository.

## Prepare The Protocol Materials

The `Documents/` folder contains protocol-related materials, including `Protocol.Rmd`, bibliography/style files, and rendering assets.

You can use the provided files as a protocol-writing starting point, or replace the `Documents/` folder with the completed protocol and any supporting files for the study. The important goal is that the repository contains the current study protocol or a clear link to it so Site Participants and reviewers can understand the study design they are executing.

Use these files as a starting point for documenting:

- Study rationale and objectives.
- Target, comparator, indication, subgroup, and outcome definitions.
- Analysis design.
- Data source expectations.
- Planned dissemination and results review.

The protocol should drive the settings used in `scriptsForStudyDesigner/CreateStrategusAnalysisSpecifications.R`.

## Prepare Cohort Assets

The template includes `scriptsForStudyDesigner/DownloadAssets.R` to download cohort definitions from an ATLAS/WebAPI instance.

Before running it, review:

- `config.yml`, especially `webApiUrl`.
- `scriptsForStudyDesigner/DownloadAssets.R`, especially `cohortsToDownload`.
- `scriptsForStudyDesigner/WebApiHelperFunctions.R`, especially the WebAPI authentication approach.

`DownloadAssets.R` writes cohort assets into `inst/`, including:

- `inst/Cohorts.csv`
- `inst/cohorts/`
- `inst/sql/sql_server/`

After downloading assets, confirm that the cohort IDs and names match the study design. Cohort IDs used in the analysis specification must match the IDs in these assets.

## Review Starting Assets

This template provides starting assets that should be reviewed by the study team before the analysis specification is created.

Review and edit:

- `inst/negativeControlOutcomes.csv`
- `inst/covariateConceptsToExclude.csv`

These files are intended as starting points. The study team should decide whether the provided negative control outcomes and excluded covariate concepts are appropriate for the research question, target-comparator pairs, and analytic design.

The provided negative controls and concepts to exclude were curated by OHDSI community members and are included as vetted starting assets. They were not chosen indiscriminately, but they still need study-specific review before being used in a finalized analysis specification.

## Create The Strategus Analysis Specification

The main design script is `scriptsForStudyDesigner/CreateStrategusAnalysisSpecifications.R`.

This script loads the cohort assets and starting assets from `inst/`, defines the study design, creates module specifications for the selected HADES modules, and saves the Strategus analysis specification.

The main user-editable areas include:

- `tcis`: target, comparator, indication, and subgroup definitions.
- `outcomes`: outcome cohort IDs and clean windows.
- `timeAtRisks`: time-at-risk settings for characterization, incidence, and cohort method analyses.
- `sccsTimeAtRisks`: time-at-risk settings for SelfControlledCaseSeries.
- `plpTimeAtRisks`: prediction time-at-risk settings.
- `studyStartDate` and `studyEndDate`: optional calendar time restrictions.
- Module-specific sizing or modeling settings above the "DO NOT MODIFY" line.

The script saves the analysis specification to:

```text
inst/analysisSpecifications.json
```

by using the `studySpecificationFileName` value in `config.yml`.

## Choose Strategus Modules

The template includes settings for several Strategus HADES modules:

- CohortGenerator
- CohortDiagnostics
- Characterization
- CohortIncidence
- CohortMethod
- SelfControlledCaseSeries
- PatientLevelPrediction

If a study does not use all modules, remove unused module specifications from the `moduleSpecsList` near the bottom of `CreateStrategusAnalysisSpecifications.R`. You may also remove related setup code when it is clearly not needed, but keep changes focused and deliberate.

The modules included in the analysis specification should match the protocol and the participant-facing execution instructions.

## Test The Study

Before distributing the study repository, run the study in a test environment. This can be a local OMOP CDM or an appropriate synthetic/test database such as Eunomia.

Use `ExecuteAnalyses.R` to test the site execution workflow. Confirm that:

- `renv::restore()` completes successfully.
- The analysis specification loads from `inst/analysisSpecifications.json`.
- Database connection details work.
- CDM and work schemas are configured correctly.
- The selected Strategus modules execute as expected.
- Results are written to the configured output folder.
- `ShareResults.R` can create the aggregate result ZIP file.

Testing should catch missing assets, stale cohort IDs, module mismatches, and configuration problems before Site Participants receive the repository.

## Prepare Site Instructions

After testing, make sure Site Participants have clear instructions for:

- Required prerequisites.
- How to download or clone the study repository.
- How to restore the `renv` environment.
- Which values to edit in `ExecuteAnalyses.R`.
- Where local results will be written.
- How to review aggregate CSV outputs.
- How to run `ShareResults.R`.
- How approved result ZIP files should be shared with the Study Coordinator.

If the study uses secure SFTP, provide the required user name, private key, and upload instructions through an appropriate secure channel.

## Before Distribution

Before sharing the study package with participating sites, check that:

- The root `README.md` metadata is updated.
- `config.yml` no longer contains irrelevant template defaults.
- `Documents/` contains the current protocol materials.
- `inst/` contains the final cohort assets and reviewed starting assets.
- `inst/analysisSpecifications.json` has been regenerated after the final design changes.
- `ExecuteAnalyses.R` has clear site-facing input placeholders.
- `ShareResults.R` reflects the intended result-sharing workflow.
- Participant-facing instructions use the current script names and output folder names.

## Next Steps

After the study package is ready, Site Participants should follow the [Site Participant Guide](site-participant-guide.md).

Study Coordinators collecting results should follow the [Study Coordinator Guide](study-coordinator-guide.md).
