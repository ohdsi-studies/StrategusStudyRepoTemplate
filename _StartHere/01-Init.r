
# # #
# 
# clear the existing environment variables
#
# # #

rm(list = ls())

# # #
#
# bootstrap installing tools
#
# # #

if (!requireNamespace("usethis", quietly = TRUE) || packageVersion("usethis") != "3.1.0") {
  install.packages("usethis")
}

# # #
#
#  details of r version
#
# # #

R.version
R.version.string

# # #
#
#  set up environment
#
# # #

renv::restore()

# # #
# 
# show installed versions of packages
#
# # #

installed.packages()[, c("Package", "Version")]




