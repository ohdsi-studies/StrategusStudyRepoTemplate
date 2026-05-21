# Prerequisites

This page describes the setup a team should have in place before using this repository to design, run, coordinate, or review a Strategus network study.

Not every role needs every tool. Study Designers need the full study-design environment, Site Participants need a working local execution environment for their OMOP CDM, and Study Coordinators need access to shared result storage and result-viewer infrastructure.

## Start Here

The first setup step for most users is the official OHDSI [HADES R setup guide](https://ohdsi.github.io/Hades/rSetup.html). That page walks through the core software needed to run OHDSI R packages, including R, RTools or platform build tools, RStudio, Java, and GitHub Personal Access Token setup for installing packages from GitHub. It also includes platform-specific instructions for Windows and Mac and a small verification step using `SqlRender` to confirm that R and Java are working together.

Use the HADES setup guide as the source of truth for installing the base R tooling. This page explains how those prerequisites apply to this Strategus study template.

Before working with the role-specific guides, make sure you can:

1. Open the repository as an RStudio project.
2. Restore the project R environment with `renv::restore()`.
3. Connect from R to any database you need for your role.
4. Confirm that you have the required database permissions.

The project lockfile currently records R `4.4.1`. Use that version where possible, especially when preparing a study package for distribution.

## Local R Environment

All roles should have a working HADES-compatible R environment.

Install and configure:

- R, preferably the version recorded in `renv.lock`.
- RStudio or another R development environment.
- RTools on Windows when package compilation is required.
- Java, because several OHDSI packages use Java-based database and SQL tooling.
- Git or another way to download the study repository.

The HADES setup guide provides the detailed installation steps for these components. It also describes how to increase the Java heap size by setting `_JAVA_OPTIONS`, which is commonly needed for OHDSI package workflows. This repository also sets Java-related options in `ExecuteAnalyses.R`, but users should still follow the HADES guidance when configuring their local environment.

After opening the project, restore the package environment:

```r
renv::restore()
```

This installs the R packages recorded in `renv.lock`, including Strategus and the HADES modules used by the template. Restoring the environment can take a while, especially on a fresh machine.

After `renv::restore()` completes, restart R before running study scripts.

## Python And Reticulate

Some HADES workflows, especially PatientLevelPrediction workflows, can require Python through `reticulate`.

If the study uses modules that depend on Python, install and configure Python before running the study. The Study Designer should confirm whether Python is required for the finalized study package and communicate that clearly to Site Participants.

## Database Connectivity

Most users need to connect from R to a database.

Site Participants need access to:

- The OMOP CDM database schema containing patient-level data.
- A writable work schema where study cohort tables and temporary study artifacts can be created.

Study Coordinators need access to:

- A PostgreSQL results database where aggregate study results can be loaded.
- A database account with permission to create schemas and tables when initializing the results data model.
- A database account with permission to insert results when uploading site outputs.

Database connections are created with `DatabaseConnector::createConnectionDetails()`. Each site should test its connection before running the full study.

## Site Execution Permissions

Site Participants should confirm that their database account can:

- Read from the OMOP CDM schema.
- Create, write to, and drop study tables in the work schema.
- Execute SQL translated for the site's database platform.
- Write output files to the configured local results folder.

The main site execution script is `ExecuteAnalyses.R`. Site-specific database values are entered in the input block near the top of that script.

## Results Database Requirements

Study coordination uses a central results database. The current template assumes PostgreSQL for the results database and Shiny results viewer workflow.

The Study Coordinator should have:

- A PostgreSQL server available for aggregate results.
- A target results schema name for the study.
- Database credentials available to R, commonly through environment variables referenced in `config.yml`.
- Permission to create the results schema and Strategus result tables.
- Permission to grant read-only access for the Shiny results viewer user, if a hosted viewer will be used.

The results schema is created by `scriptsForStudyCoordinator/CreateResultsDataModel.R`.

## Result Sharing

This template provides `ShareResults.R` to help Site Participants package their local results for sharing. The script zips the aggregate CSV files produced by Strategus. Patient-level data are not included in the shared result ZIP file.

Study Coordinators can choose the result-sharing approach that works best for their study. Some OHDSI network studies use a secure SFTP server to coordinate result ZIP files from participating sites, but SFTP is only one supported approach.

Site Participants need:

- The ability to review the aggregate CSV outputs produced by the study.
- A local environment that can run `ShareResults.R`.
- Instructions from the Study Coordinator for how approved result ZIP files should be shared.
- SFTP credentials and a private key only if the study is using the secure SFTP workflow.

Study Coordinators need:

- A process for collecting approved result ZIP files from participating sites.
- A local folder for collected result ZIP files.
- SFTP credentials, a remote folder name, and a download folder only if the study is using the secure SFTP workflow.

When SFTP is used, Site Participants enter the upload settings provided by the Study Coordinator in `ShareResults.R`. Study Coordinators configure their SFTP download settings in `config.yml` for use by the scripts in `scriptsForStudyCoordinator/`.

## Role-Specific Checklist

**Study Designer**

- R, RStudio, RTools, Java, and restored `renv` environment.
- Access to the ATLAS/WebAPI instance used to retrieve cohort definitions.
- Ability to run `scriptsForStudyDesigner/DownloadAssets.R`.
- Ability to review and edit starting assets such as negative controls and covariates to exclude.
- Ability to run `scriptsForStudyDesigner/CreateStrategusAnalysisSpecifications.R`.
- Access to a test OMOP CDM or synthetic database for validating the study package.

**Site Participant**

- R, RStudio, Java, and restored `renv` environment.
- Database connection details for the local OMOP CDM.
- Read access to the CDM schema.
- Write access to a work schema.
- Local folder where Strategus work files and results can be written.
- Instructions for sharing the aggregate result ZIP file.
- SFTP credentials and private key if the study uses secure SFTP.

**Study Coordinator**

- R, RStudio, Java, and restored `renv` environment.
- PostgreSQL results database access.
- Permission to create the results schema and tables.
- Access to site result ZIP files.
- SFTP credentials if downloading results from a secure SFTP server.
- Shiny viewer database account and read-only permissions if hosting a results viewer.

## Helpful External References

- [HADES R setup](https://ohdsi.github.io/Hades/rSetup.html): official OHDSI instructions for installing R, RTools or platform build tools, RStudio, Java, and GitHub PAT support.
- [Connecting to a database using HADES](https://ohdsi.github.io/Hades/connecting.html)
- [DatabaseConnector connection details](https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html)
- [Strategus documentation](https://ohdsi.github.io/Strategus/)

## Next Steps

After confirming the prerequisites, continue with the guide for your role:

- [Study Designer Guide](study-designer-guide.md)
- [Site Participant Guide](site-participant-guide.md)
- [Study Coordinator Guide](study-coordinator-guide.md)
