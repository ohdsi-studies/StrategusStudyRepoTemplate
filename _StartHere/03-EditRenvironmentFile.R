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

library(usethis)
edit_r_environ()

