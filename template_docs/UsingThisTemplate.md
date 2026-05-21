# Strategus Study Template Documentation

This documentation is for teams who want to use this repository to start, run, and coordinate an OHDSI network study using Strategus.

An OHDSI network study generally starts with a study team that defines and documents the research question in a study protocol. This team then works to develop the cohorts and analysis specifications to turn the study design into executable code using the OHDSI HADES libraries. That design is then packaged so participating data partners can run the same study locally against their own OMOP CDM databases. Each site reviews its own output, shares approved aggregate results, and the Study Coordinator combines those results for evidence synthesis, reporting, or exploration in a Shiny results viewer.

This repository provides a starting structure for that workflow. It includes scripts for preparing study assets, creating a Strategus analysis specification, executing the study at participating sites, sharing results, uploading results into a central results schema, running EvidenceSynthesis, and launching a results viewer.

## Who This Documentation Is For

Most readers should start by identifying their role in the study.

**Study Designer**

The Study Designer adapts this template for a specific study. This person usually translates the protocol into executable study assets, downloads or prepares cohorts, creates the Strategus analysis specification, tests the study, and prepares the repository for participating sites.

Use the [Study Designer Guide](study-designer-guide.md).

**Site Participant**

The Site Participant runs the finalized study package at a participating data site. This person configures database connection details, runs the study against a local OMOP CDM, reviews local output, and shares approved aggregate results with the Study Coordinator.

Use the [Site Participant Guide](site-participant-guide.md).

**Study Coordinator**

The Study Coordinator collects results from participating sites and prepares them for review. This person configures results storage, downloads or receives site result ZIP files, creates the results data model, uploads site results, runs EvidenceSynthesis when applicable, and supports the Shiny results viewer.

Use the [Study Coordinator Guide](study-coordinator-guide.md).

## Recommended Reading Path

Everyone should begin with the shared setup requirements:

- [Prerequisites](prerequisites.md)

Then continue with the guide for your role:

- [Study Designer Guide](study-designer-guide.md)
- [Site Participant Guide](site-participant-guide.md)
- [Study Coordinator Guide](study-coordinator-guide.md)

Additional reference material is organized separately so the role guides can stay focused:

- [Configuration Reference](configuration-reference.md)

## README Template

OHDSI study repositories are expected to include a root `README.md` with standard study metadata. This metadata helps people understand the study and can be used to populate OHDSI study listings.

This template includes [templateREADME.md](templateREADME.md), which shows the recommended root `README.md` structure for a finalized study repository. Study Designers should copy that template into the repository root as `README.md` and update the fields for the study.

The README template includes:

- Study title and study status badge.
- Analytics use case.
- Study type.
- Tags.
- Study lead and contact information.
- Study start and end dates.
- Links to the protocol, publications, results explorer, and other study-specific resources.

Keep the root `README.md` accurate as the study progresses. It should help Site Participants, reviewers, and the broader OHDSI community understand the current state of the study.

## Network Study Lifecycle

A typical Strategus network study using this repository follows this path:

1. The Study Designer adapts the template for a specific study.
2. The Study Designer updates study metadata, protocol materials, and configuration.
3. The Study Designer prepares cohorts and reviews or edits the provided starting assets, including negative controls and covariates to exclude.
4. The Study Designer creates the Strategus analysis specification, usually saved as `inst/analysisSpecifications.json`.
5. The Study Designer tests the study locally and prepares the repository for site execution.
6. Site Participants restore the R environment and configure local database settings.
7. Site Participants run `ExecuteAnalyses.R` against their local OMOP CDM.
8. Site Participants review local aggregate output.
9. Site Participants use `ShareResults.R` to zip and upload approved results.
10. The Study Coordinator collects result ZIP files from participating sites.
11. The Study Coordinator creates the central results schema and uploads site results.
12. The Study Coordinator runs EvidenceSynthesis when applicable.
13. The Study Coordinator launches or publishes a Shiny results viewer.

## How The Repository Pieces Fit Together

The repository is organized around the same workflow.

`config.yml` contains shared configuration used by Study Designer and Study Coordinator workflows, including the study name, Strategus specification filenames, results database settings, SFTP settings, and Shiny viewer settings.

`scriptsForStudyDesigner/` contains scripts used while designing the study. These scripts help download cohort assets from ATLAS and create the Strategus analysis specification used for execution.

`inst/` contains study assets that are distributed with the repository. This includes cohort definitions, SQL, negative control outcomes, covariates to exclude, and Strategus analysis specifications.

`ExecuteAnalyses.R` is the main site-facing script for running the study. Participating sites edit the input block at the top of the script to point to their CDM, work schema, results folder, work folder, database name, and connection details.

`ShareResults.R` is the site-facing script for packaging and uploading aggregate results after local review.

`scriptsForStudyCoordinator/` contains scripts for central study coordination. These scripts support downloading result files, creating the results schema, uploading results, running EvidenceSynthesis, and launching the Shiny results viewer.

`Documents/` contains protocol-related materials, including the protocol R Markdown template and supporting style/reference files.

## A Note About Template And Study Repositories

This repository is a template. Some documentation is about adapting the template into a real study repository, and some documentation is about using the resulting study repository once it has been finalized.

When you are preparing a new study, expect to update names, paths, metadata, cohort definitions, analysis settings, and result-sharing configuration. When you are participating in a finalized study, you should only need to follow the site execution instructions provided by the study team.
