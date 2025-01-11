# # #
#
# A script to init the R environment (renv)
#
# # #

# # #
# 
# clear the existing environment variables
#
# # #

rm(list = ls())

# # #
#
#  details of r version
#
# # #

R.version
R.version.string

# # #
#
# bootstrap installing tools
#
# # #

if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
if (packageVersion("devtools") != "2.4.5") {
  devtools::install_version("devtools", version = "2.4.5", repos = "https://cran.r-project.org")
}
devtools::install_version("usethis", version = "3.1.0")

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




