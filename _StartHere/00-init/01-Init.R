# ----
#  set up environment
# ----

options(replace.readline = function(prompt) "Y")
renv::restore(confirm = FALSE)
options(replace.readline = function(prompt) NULL)

# ----
# Add libraries not included in the lock file
# ----

remotes::install_github("https://github.com/OHDSI/ROhdsiWebApi","v1.3.3", upgrade="never")
if (!requireNamespace("Eunomia", quietly = TRUE) || packageVersion("Eunomia") != "2.0.0") {
  options(replace.readline = function(prompt) "Y")
  remotes::install_version("Eunomia", version = '2.0.0', upgrade = "never")
  options(replace.readline = function(prompt) NULL)
}

# ----
# show installed versions of packages
# ----

installed.packages()[, c("Package", "Version")]




