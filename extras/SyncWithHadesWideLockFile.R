# NOTE: This script is used to sync the HADES-wide
# lock file that is published with the renv.lock
# file that is used in this project template.
# This file is not needed for study design or
# execution.
source("extras/RenvUtils.R")
hwlfUrl <- "https://raw.githubusercontent.com/OHDSI/Hades/refs/heads/main/hadesWideReleases/%s/renv.lock"
hwlfRelease <- "2024Q3"
hwlfUrl <- sprintf(hwlfUrl, hwlfRelease)
hwlfFileName <- sprintf("hwlf_%s.lock", hwlfRelease)
hwlfPath <- file.path("extras", hwlfFileName)

# Call the download.file() function, passing in the URL and file name/location as arguments
download.file(hwlfUrl, hwlfPath, mode = "wb")

# Compare the HADES-wide lock file with the current project lock file
dfComparison <- compareLockFiles(
  filename1 = hwlfPath,
  filename2 = "renv.lock"
)

# Sync?
syncLockFile(
  sourceOfTruthLockFileName = hwlfPath,
  targetLockFileName = "renv.lock"
)

# Validate
validateLockFile(
  filename = "renv.lock"
)

# Run this in case the activate script is updated
renv::upgrade()