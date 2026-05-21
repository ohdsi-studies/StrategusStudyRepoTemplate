# Configuration Reference

This reference explains the main configuration values used by the study template.

The template intentionally separates study-level configuration from site-specific execution settings:

- `config.yml` is primarily for Study Designer and Study Coordinator workflows.
- `ExecuteAnalyses.R` contains Site Participant settings for running the study locally.
- `ShareResults.R` contains Site Participant settings for packaging and sharing approved aggregate results.

Most Site Participants should only need to edit `ExecuteAnalyses.R` and, when sharing results, `ShareResults.R`.

## `config.yml`

`config.yml` stores shared study and coordination settings.

### Study Identity And Assets

`studyName`

The human-readable name of the study. This is used by the Shiny results viewer and other coordinator-facing scripts.

`webApiUrl`

The ATLAS/WebAPI endpoint used by `scriptsForStudyDesigner/DownloadAssets.R` to retrieve cohort definitions.

`projectRootFolder`

The project root used by designer and coordinator scripts to find study assets. The default uses `getwd()`, so scripts should be run from the project root.

`studySpecificationFileName`

The filename of the Strategus analysis specification in `inst/`. `ExecuteAnalyses.R`, `CreateResultsDataModel.R`, and `UploadResults.R` use this value when loading the study design.

`evidenceSynthesisSpecificationFileName`

The filename used for the EvidenceSynthesis analysis specification in `inst/`.

### Results Database

`resultsDatabaseSchema`

The PostgreSQL schema where aggregate study results will be loaded. Prefer a lower-case schema name and avoid SQL reserved words or special characters.

`resultsConnectionDetails`

The `DatabaseConnector::createConnectionDetails()` object used by coordinator scripts and the Shiny viewer. The template builds this from environment variables:

- `OHDSI_RESULTS_DATABASE_SERVER`
- `OHDSI_RESULTS_DATABASE_USER`
- `OHDSI_RESULTS_DATABASE_PASSWORD`

Set those environment variables before running coordinator scripts.

### Coordinator Folders

`resultFolder`

The local folder where the Study Coordinator keeps unpacked site result folders before upload. `UploadResults.R` expects this folder to contain one immediate subfolder per data source.

`workFolder`

A general coordinator/design work folder for Strategus internals when needed by coordinator workflows. Site Participants configure their own `workFolder` in `ExecuteAnalyses.R`.

`evidenceSynthesisResultFolder`

The folder where EvidenceSynthesis result outputs are written before being uploaded to the results database.

`evidenceSynthesisWorkFolder`

The folder where EvidenceSynthesis intermediate work files are written.

### Shiny Viewer

`shinyReadOnlyUserName`

The database user that receives read-only permissions for viewing results in a hosted Shiny app.

The Shiny app is launched from `scriptsForStudyCoordinator/app.R` and uses `studyName`, `resultsConnectionDetails`, and `resultsDatabaseSchema`.

### SFTP Collection Settings

These settings are used by Study Coordinators only if the study uses secure SFTP to collect result ZIP files.

`sftpDownloadFolder`

The local folder where downloaded result ZIP files should be saved.

`sftpRemoteFolderName`

The remote SFTP folder containing site result ZIP files.

`sftpKeyFileName`

The private key file used by the Study Coordinator to connect to the secure SFTP server.

`sftpUserName`

The Study Coordinator SFTP user name.

## `ExecuteAnalyses.R`

`ExecuteAnalyses.R` is the main Site Participant script for running the study against a local OMOP CDM.

### Database Settings

`cdmDatabaseSchema`

The database schema containing the local OMOP CDM.

`workDatabaseSchema`

A writable schema where study cohort tables and temporary work tables can be created.

`cohortTableName`

The base name used for study cohort tables. This should be specific enough to distinguish the study from other work in the same work schema.

`connectionDetails`

The `DatabaseConnector::createConnectionDetails()` object for the local CDM database.

`options(sqlRenderTempEmulationSchema = "...")`

Optional setting for database platforms that do not support temporary tables directly.

### Output Settings

`resultsFolder`

The base folder where Strategus aggregate result files are written. `ExecuteAnalyses.R` appends `databaseName` to this path.

`workFolder`

The base folder where Strategus intermediate work files are written. `ExecuteAnalyses.R` appends `databaseName` to this path.

`databaseName`

The data source label used in output folder names and result ZIP names. Use a clear name without special characters.

`minCellCount`

The minimum cell count used for small-cell suppression in output tables.

### Study Specification

`ExecuteAnalyses.R` loads the Strategus analysis specification using `config.yml`:

```r
file.path(config$projectRootFolder, "inst", config$studySpecificationFileName)
```

Site Participants should not need to change the analysis specification filename.

## `ShareResults.R`

`ShareResults.R` packages aggregate results after local review.

`resultsFolder`

Must match the base `resultsFolder` used in `ExecuteAnalyses.R`.

`databaseName`

Must match the `databaseName` used in `ExecuteAnalyses.R`.

`sftpKeyFileName`

Private key file provided by the Study Coordinator if the study uses secure SFTP.

`sftpUserName`

SFTP user name provided by the Study Coordinator if the study uses secure SFTP.

`sftpRemoteFolderName`

Remote SFTP folder provided by the Study Coordinator if the study uses secure SFTP.

`ShareResults.R` creates the ZIP file in:

```text
<resultsFolder>/<databaseName>/
```

The ZIP file contains aggregate Strategus CSV outputs and should not contain patient-level data.

## Coordinator Scripts

The coordinator scripts read from `config.yml`:

- `scriptsForStudyCoordinator/DownloadZipFiles.R`
- `scriptsForStudyCoordinator/CreateResultsDataModel.R`
- `scriptsForStudyCoordinator/UploadResults.R`
- `scriptsForStudyCoordinator/EvidenceSynthesis.R`
- `scriptsForStudyCoordinator/app.R`

Run these scripts from the project root so relative paths and `config::get()` resolve as expected.

## Designer Scripts

The Study Designer scripts also read from `config.yml`:

- `scriptsForStudyDesigner/DownloadAssets.R`
- `scriptsForStudyDesigner/CreateStrategusAnalysisSpecifications.R`

The key design settings are `webApiUrl`, `projectRootFolder`, and `studySpecificationFileName`.
