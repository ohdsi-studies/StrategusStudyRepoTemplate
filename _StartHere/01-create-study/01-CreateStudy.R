# # #
#
# This script will create the study. See the referenced source files for details.
#
# # #


# # #
#
# Delete the existing version of the study
#
# # #

source("./_StartHere/01-create-study/config/01-AuthorStudyConfiguration.R", echo=TRUE)
unlink(studyDefRootDir, recursive = TRUE, force = TRUE)

# # #
#
# Create the study.
#
# # #

source("./DownloadCohorts.R", echo=TRUE)
source("./CreateStrategusAnalysisSpecification.R", echo=TRUE)


