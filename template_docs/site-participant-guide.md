# Site Participant Guide

This guide is for data partners who are running a finalized Strategus network study against a local OMOP CDM.

As a Site Participant, your role is to restore the study environment, configure local database settings, run the study, review the aggregate outputs, and share an approved result ZIP file with the Study Coordinator. The shared ZIP file will contain only the aggregate summary statistics in CSV files and does not contain patient-level data.

Before using this guide, review the [Prerequisites](prerequisites.md).

## Site Execution Workflow

A typical Site Participant workflow is:

1. Download or clone the finalized study repository.
2. Open the RStudio project.
3. Restore the R environment with `renv::restore()`.
4. Configure local database, results, and work folder settings in `ExecuteAnalyses.R`.
5. Run the study against the local OMOP CDM.
6. Review the aggregate results.
7. Use `ShareResults.R` to create a result ZIP file.
8. Share the approved ZIP file using the process provided by the Study Coordinator.

## Open The Study Repository

Download or clone the study repository to a local folder. Open the `.Rproj` file in RStudio so paths resolve relative to the project root.

The first time you open the project, R may report that packages recorded in the lockfile are not installed. This is expected for a fresh checkout.

## Restore The R Environment

Restore the project package environment before running study scripts:

```r
renv::restore()
```

Follow the prompts to install the required packages. This can take a while, especially on a new machine.

After `renv::restore()` completes, restart R before running the study.

## Configure `ExecuteAnalyses.R`

`ExecuteAnalyses.R` is the main script for running the study at a participating site. The section near the top of the file is intended for site-specific inputs.

Review and update:

- `cdmDatabaseSchema`: the schema containing the local OMOP CDM.
- `workDatabaseSchema`: a writable schema where study cohort tables and temporary work tables can be created.
- `cohortTableName`: the prefix used for study cohort tables.
- `resultsFolder`: the local folder where Strategus result files will be written.
- `workFolder`: the local folder where Strategus intermediate work files will be written.
- `databaseName`: the name used to identify this data source in the output folder structure.
- `minCellCount`: the minimum cell count used for small-cell suppression in output tables.
- `connectionDetails`: the DatabaseConnector settings for the local database.

Some database platforms also need a temporary emulation schema. If needed, set `options(sqlRenderTempEmulationSchema = "...")` near the top of `ExecuteAnalyses.R`.

The script also sets environment options such as `_JAVA_OPTIONS` and `VROOM_THREADS`. These are included to support common OHDSI execution needs, but your local environment should still follow the official HADES setup guidance described in [Prerequisites](prerequisites.md).

## Test The Database Connection

Before running the full study, test your database connection from R.

`ExecuteAnalyses.R` includes a commented example:

```r
conn <- DatabaseConnector::connect(connectionDetails)
DatabaseConnector::disconnect(conn)
```

Confirm that the connection succeeds and that the configured database account can read from the CDM schema and write to the work schema.

## Run The Study

After local settings are configured, run `ExecuteAnalyses.R`.

The script loads the Strategus analysis specification distributed with the study, creates execution settings, saves those execution settings for reference, and calls `Strategus::execute()`. The Study Designer controls the analysis specification file name in `config.yml`; Site Participants should not need to change it.

`ExecuteAnalyses.R` appends `databaseName` to the configured `resultsFolder` and `workFolder`.

By default, result files are written under:

```text
<resultsFolder>/<databaseName>/
```

Intermediate work files are written under:

```text
<workFolder>/<databaseName>/
```

Depending on the study design and database size, execution can take a long time. Leave R running until the script completes or fails with an error.

## Review Local Results

Before sharing results, review the aggregate outputs produced in the configured result folder.

The exact folder contents depend on the Strategus modules included in the study. Results are generally stored as CSV files organized by module.

Review should confirm that:

- The study completed successfully.
- Expected module result folders were created.
- Results are aggregate outputs suitable for sharing.
- No patient-level data are present in the files being shared.
- Any site-specific governance or approval process has been completed.

If the study fails or outputs are unexpected, contact the Study Coordinator before sharing results. Include the relevant log files or error messages, but do not share patient-level data.

## Create The Result ZIP File

After local review and approval, use `ShareResults.R` to package the aggregate results.

Before running it, confirm that:

- `resultsFolder` matches the value used in `ExecuteAnalyses.R`.
- `databaseName` matches the value used in `ExecuteAnalyses.R`.
- Any SFTP settings provided by the Study Coordinator are entered correctly if the study uses secure SFTP.

`ShareResults.R` calls `Strategus::zipResults()` to create a ZIP file from the aggregate Strategus result CSV files. It then uploads the ZIP file through `OhdsiSharing::sftpUploadFile()` when the study is configured to use secure SFTP.

The ZIP file is created in:

```text
<resultsFolder>/<databaseName>/
```

## Share Results

Follow the sharing instructions provided by the Study Coordinator.

Some studies use secure SFTP. Other studies may collect ZIP files through a different approved process. The important requirement is that only the approved aggregate result ZIP file is shared.

If the study uses secure SFTP, the Study Coordinator should provide:

- SFTP user name.
- Private key file.
- Remote folder or upload instructions.
- Any study-specific naming requirements.

Keep credentials and private keys secure. Do not commit them to the repository.

## Common Issues

**`renv::restore()` fails**

Confirm that the HADES setup prerequisites are complete, including RTools or platform build tools, Java, and GitHub access.

**Database connection fails**

Confirm the database platform, server, user name, password, driver setup, and network access. Test with a simple `DatabaseConnector::connect()` call before running the study.

**Permission errors occur during execution**

Confirm that the configured account has read access to the CDM schema and write access to the work schema.

**The study runs but no result ZIP is created**

Confirm that `resultsFolder` and `databaseName` match between `ExecuteAnalyses.R` and `ShareResults.R`, and confirm that the configured result folder exists.

**SFTP upload fails**

Confirm that the private key file, user name, and remote folder settings match the Study Coordinator's instructions. If the study is not using secure SFTP, create the ZIP file and share it through the approved alternate process.

## Next Steps

After the approved result ZIP file has been shared, the Study Coordinator will collect and upload results using the [Study Coordinator Guide](study-coordinator-guide.md).
