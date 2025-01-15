# # #
#
#  set up environment
#
# # #

renv::restore()

# # #
#
# Add libraries not included in the lock file
#
# # #

remotes::install_github("https://github.com/OHDSI/ROhdsiWebApi","v1.3.3", upgrade="never")
if (!requireNamespace("Eunomia", quietly = TRUE) || packageVersion("Eunomia") != "2.0.0") {
  remotes::install_version("Eunomia", version = '2.0.0', upgrade = "never")
}

# # #
# 
# show installed versions of packages
#
# # #

installed.packages()[, c("Package", "Version")]




