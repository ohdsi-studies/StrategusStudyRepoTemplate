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

# # #
# 
# show installed versions of packages
#
# # #

installed.packages()[, c("Package", "Version")]




