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




