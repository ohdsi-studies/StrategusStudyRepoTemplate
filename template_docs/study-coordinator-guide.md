# Study Coordinator Guide

This guide is for the person or team collecting aggregate results from participating sites and preparing them for review.

As a Study Coordinator, your role is to define the result collection process, configure the central results database, create the Strategus results data model, upload site result folders, run EvidenceSynthesis when applicable, and support a Shiny results viewer.

Before using this guide, review the [Prerequisites](prerequisites.md).

## Study Coordination Workflow

A typical Study Coordinator workflow is:

1. Review and update coordinator settings in `config.yml`.
2. Decide how Site Participants will share approved result ZIP files.
3. Collect and unpack result ZIP files into the configured result folder.
4. Create the central results schema and Strategus results data model.
5. Upload site results into the results database.
6. Run EvidenceSynthesis if the study includes meta-analysis.
7. Launch or publish the Shiny results viewer.

## Review Coordinator Configuration

Study coordination is driven by `config.yml`.

Review and update:

- `studyName`: the name shown in the Shiny results viewer.
- `resultsDatabaseSchema`: the PostgreSQL schema where aggregate results will be loaded.
- `resultFolder`: the local folder containing one unpacked result folder per contributing data source.
- `evidenceSynthesisResultFolder`: the folder where EvidenceSynthesis outputs will be written.
- `evidenceSynthesisWorkFolder`: the folder where EvidenceSynthesis intermediate files will be written.
- `studySpecificationFileName`: the Strategus analysis specification used to create and upload study results.
- `evidenceSynthesisSpecificationFileName`: the EvidenceSynthesis analysis specification file.
- `resultsConnectionDetails`: the PostgreSQL connection used for creating tables, uploading results, and serving the results viewer.
- `shinyReadOnlyUserName`: the database user that will receive read-only access for the Shiny viewer.
- SFTP settings, if the study uses secure SFTP to collect result ZIP files.

The `resultsConnectionDetails` setting is commonly built from environment variables such as `OHDSI_RESULTS_DATABASE_SERVER`, `OHDSI_RESULTS_DATABASE_USER`, and `OHDSI_RESULTS_DATABASE_PASSWORD`. Confirm these are set before running coordinator scripts.

## Collect Site Result ZIP Files

Each Site Participant should share an approved result ZIP file created from aggregate Strategus CSV outputs. These ZIP files should not contain patient-level data.

Study Coordinators can choose the collection process that works best for the study. Some studies use secure SFTP, but SFTP is only one option.

If the study uses secure SFTP, configure the SFTP settings in `config.yml`:

- `sftpDownloadFolder`
- `sftpRemoteFolderName`
- `sftpKeyFileName`
- `sftpUserName`

Then use:

```text
scriptsForStudyCoordinator/DownloadZipFiles.R
```

to download uploaded result ZIP files.

Regardless of the collection method, unpack the ZIP files so `config$resultFolder` contains one immediate subfolder per data source. `UploadResults.R` iterates over those immediate subfolders and uploads each one.

For example:

```text
results/
  CCAE/
  MDCD/
  Optum/
```

Each data-source folder should contain the aggregate Strategus result files for that source.

## Create The Results Data Model

Before uploading results, create the results schema and table structure.

Run:

```text
scriptsForStudyCoordinator/CreateResultsDataModel.R
```

This script:

- Connects to the PostgreSQL results database using `config$resultsConnectionDetails`.
- Creates the configured `resultsDatabaseSchema`.
- Loads the study analysis specification from `inst/<studySpecificationFileName>`.
- Calls `Strategus::createResultDataModel()` to create the result tables.

If the results schema already exists, the helper function will ask whether to preserve it or drop and recreate it. Dropping the schema removes previously uploaded results, so only do that when you are sure the existing results are no longer needed.

## Upload Site Results

After the results data model exists and site ZIP files have been unpacked, run:

```text
scriptsForStudyCoordinator/UploadResults.R
```

This script loops over the immediate subfolders under `config$resultFolder`. For each folder, it creates Strategus result data model settings and uploads that site's aggregate results into the configured PostgreSQL schema.

After upload, the script grants read-only permissions for the Shiny viewer user and runs `ANALYZE` on the PostgreSQL tables to support query performance.

## Run EvidenceSynthesis

If the study includes population-level estimation analyses, specifically CohortMethod and/or SelfControlledCaseSeries, that require meta-analysis, run:

```text
scriptsForStudyCoordinator/EvidenceSynthesis.R
```

This script:

- Creates an EvidenceSynthesis analysis specification.
- Saves it to `inst/<evidenceSynthesisSpecificationFileName>`.
- Executes EvidenceSynthesis against the uploaded results database.
- Writes EvidenceSynthesis outputs to `evidenceSynthesisResultFolder`.
- Uploads EvidenceSynthesis results back into the results database.
- Grants read-only permissions and analyzes the result tables.

Review the script before running it. The default EvidenceSynthesis sources are configured for CohortMethod and SelfControlledCaseSeries results. If the study does not use one of those methods, remove the corresponding EvidenceSynthesis source and analysis.

## Launch The Shiny Results Viewer

After results are uploaded, the coordinator can launch the Shiny results viewer:

```text
scriptsForStudyCoordinator/app.R
```

This script uses `config.yml` for:

- The app title and study description.
- The PostgreSQL results database connection.
- The results schema.
- The Shiny module configuration.

Review the module list in `app.R` and remove modules that do not apply to the study. For example, if the study does not include PatientLevelPrediction, remove the corresponding prediction module from the Shiny configuration.

If the viewer will be hosted, confirm that the viewer database account has read-only access to the results schema.

## Coordinator Checklist

Before publishing or sharing results, confirm that:

- All expected site result ZIP files have been received.
- ZIP files have been unpacked into one folder per data source under `config$resultFolder`.
- The results schema was created successfully.
- Site results uploaded without errors.
- EvidenceSynthesis was run if required by the study protocol.
- The Shiny results viewer opens and shows the expected modules.
- Read-only permissions are configured for any hosted viewer.
- Results have passed the study team's review process.

## Common Issues

**The results schema already exists**

`CreateResultsDataModel.R` will ask whether to preserve or recreate the schema. Preserve it unless you intentionally want to remove existing uploaded results.

**No results are uploaded**

Confirm that ZIP files were unpacked and that `config$resultFolder` contains one immediate subfolder per data source. `UploadResults.R` does not upload nested folders recursively.

**Upload fails for one site**

Check that the folder contains a valid Strategus result export for the same analysis specification used by the study.

**EvidenceSynthesis fails**

Confirm that the source methods configured in `EvidenceSynthesis.R` match the modules included in the study and uploaded to the results database.

**The Shiny viewer launches but modules are empty**

Confirm that the corresponding Strategus module results were uploaded and that the Shiny module list in `app.R` matches the study design.
