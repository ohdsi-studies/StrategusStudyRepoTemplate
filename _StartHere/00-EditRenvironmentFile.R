# # #
#
# script to edit the .Renviron file
# Add the following lines to the .Renviron file:
#
# (See https://ohdsi.github.io/DatabaseOnSpark/developer-how-tos_gen_dev.html for how to generate the GITHUB_PAT)
#
# _JAVA_OPTIONS='-Xmx4g'
# GITHUB_PAT='MY_GITHUB_PAT'
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

if (!requireNamespace("usethis", quietly = TRUE) || packageVersion("usethis") != "3.1.0") {
  options(replace.readline = function(prompt) "Y") # This won't work for install.packages
  install.packages("usethis", ask = FALSE)
  options(replace.readline = function(prompt) NULL)
}

# # #
#
# edit the Renviron file
#
# # #

library(usethis)
edit_r_environ()

