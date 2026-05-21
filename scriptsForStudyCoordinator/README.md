# Study Coordination

The study coordinator will coordinate with sites participating in the network study to aggregate results and publish a results viewer for the totality of evidence generated. The scripts in this folder support study coordination for network studies.

## Setup results schema

Once you and other study participants have run your study via Strategus on one or more data sources, you will need to set up a database schema to hold the results of your study. This is done using the `CreateResultsDataModel.R` script. This script will create a the results schema with the name specified in your config.yml file's `resultsDatabaseSchema` and the supporting results tables. This script requires no modification on your part - just run it as is.

**NOTE**: You only need to run this script one time to set up the schema and create the tables. If you re-run this script, it will warn you that re-creating the schema & tables will remove prior results. You should only remove prior results **if you no longer need them**. Once data is dropped, it cannot be recovered to be careful!

## Upload results

Once you have setup your results schema, you are ready to upload your results. To do this, run `UploadResults.R`. This script will use the path to the folder in your config.yml `resultFolder` and assumes the folder structure under `resultFolder` is a sub folder per database contributing results. This script will iterate through all of your results and upload them to the results database. This script requires no modification on your part - just run it as is.

## Run evidence sythesis for meta-analysis

The `EvidenceSynthesis.R` script is used to run the meta-analysis for your Cohort Method and Self-Controlled Case Series analysis. This script will run the meta-analysis and upload the results in a single step. 

**NOTE**: You can only run the meta-analysis **after all results are uploaded**.