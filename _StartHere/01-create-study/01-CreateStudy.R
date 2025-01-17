# This script will create the study. ----

# # #
# See the referenced source files for details.
# # #

# libraries --------------------------------------------------------------------

source("./_StartHere/01-create-study/config/01-AuthorStudyConfiguration.R", echo=TRUE)

# implementation ---------------------------------------------------------------

# Delete the existing version of the study ----
unlink(studyDefRootDir, recursive = TRUE, force = TRUE)

# Create the study ----
source("./DownloadCohorts.R", echo=TRUE)
source("./CreateStrategusAnalysisSpecification.R", echo=TRUE)


