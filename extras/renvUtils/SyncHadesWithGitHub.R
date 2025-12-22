# ----------------------------------------------------------------
# NOTE: THIS SCRIPT IS ONLY FOR THE MAINTENANCE OF THE PROJECT
# TEMPLATE AND SHOULD NOT BE USED FOR THE DESIGN OR EXECUTION
# OF A STUDY
# ----------------------------------------------------------------
# This script will check the renv.lock file in the project root
# to find all HADES packages then check GitHub for the latest
# version of that package. It will also check to see if the
# latest version of the package is on CRAN.
#
# The final step in this script will then update the renv.lock
# file to use the latest versions of all HADES packages
# ----------------------------------------------------------------
source("extras/RenvUtils.R")

# Function to get the latest tag for a GitHub repository
getLatestTag <- function(organization, repo) {
  # Construct the URL for the tags API
  url <- paste0("https://api.github.com/repos/", organization, "/", repo, "/git/refs/tags")
  
  # Make the GET request
  response <- httr::GET(url)
  
  # Check if the request was successful
  if (httr::status_code(response) == 200) {
    # Parse the JSON response
    tags <- jsonlite::fromJSON(httr::content(response, as = "text"))
    
    # Extract the tag names
    tag_names <- tags$ref
    tag_names <- gsub("refs/tags/v", "", tag_names)
    latest_tag <- NA
    
    if (length(tag_names > 0)) {
      # Get the latest tag by parsing to find the largest value
      semverPattern <- "^\\d+\\.\\d+\\.\\d+(?:-[0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)?(?:\\+[0-9A-Za-z-]+)?$"
      for (i in seq_along(tag_names)) {
        curTag <- tag_names[i]
        if (grepl(semverPattern, curTag)) {
          curTagVersion <- tryCatch({
            semver::parse_version(curTag)
          }, error = function(e) {
            # Ignore the error and return NULL
            NULL
          })
          # Edge case - if the first tag (curTag) is valid and the latest_tag is NA
          # then this is our starting point
          if (is.na(latest_tag) && !is.null(curTagVersion)) {
            latest_tag <- curTag
            next
          }
          latestTagVersion <- tryCatch({
            semver::parse_version(latest_tag)
          }, error = function(e) {
            # Ignore the error and return NULL
            NULL
          }) 
          if (!is.null(curTagVersion) && !is.null(latestTagVersion)) {
            if (is.na(latest_tag) || (curTagVersion > latestTagVersion)) {
              latest_tag <- curTag
            }
          }
        } else {
          # Probably a malformed tag - for now ignore but this
          # warning may be helpful where needed
          # rlang::warn(paste0("Package: [", repo, "] - version number: ", curTag, " could not be parsed. Please inspect manually as it may require an upgrade."))
        }
      }
      
    }

    return(latest_tag)
  } else {
    stop("Failed to fetch tags: ", status_code(response))
  }
}

# Function to check if a package is on CRAN
isCranVersionAvailable <- function(packageName, version) {
  # Get the list of available packages from CRAN
  available_packages <- available.packages()
  
  # Check if the package is in the list
  if (packageName %in% available_packages[, "Package"]) {
    # Get the version of the package from the available packages
    available_version <- available_packages[available_packages[, "Package"] == packageName, "Version"]
    
    # Check if the specified version is available
    return(version %in% available_version)
  } else {
    return(FALSE)  # Package not available in CRAN
  }
}

# Taken from https://github.com/OHDSI/Hades/blob/main/R/Packages.R to get the packages
packageListUrl <- "https://raw.githubusercontent.com/OHDSI/Hades/main/extras/packages.csv"
hadesPackageList <- read.table(packageListUrl, sep = ",", header = TRUE)

# Filter the hadesPackageList to those packages that are currently in the renv.lock
# of this project
lf <- lockFileToDataFrame(lf = renv::lockfile_read("renv.lock"))
hadesPackageListFiltered <- hadesPackageList |> dplyr::filter(name %in% lf$Name)


version <- c()
onCran <- c()
for (i in seq_len(nrow(hadesPackageListFiltered))) {
  curPkg <- hadesPackageListFiltered[i,]
  rlang::inform(curPkg$name)
  pkgVersion <- getLatestTag(
    organization = curPkg$organization,
    repo = curPkg$name
  )
  isOnCran <- isCranVersionAvailable(
    packageName = curPkg$name,
    version = pkgVersion
  )
  version <- c(version, pkgVersion)
  onCran <- c(onCran, isOnCran)
}

hadesPackageListFiltered <- cbind(
  hadesPackageListFiltered,
  version,
  onCran
)

#View(hadesPackageListFiltered)

# Update the renv.lock file in the template using the latest HADES package
# versions
pkg <- list()
cranPackages <- hadesPackageListFiltered |>
  dplyr::filter(onCran==TRUE)
for (i in seq_len(nrow(cranPackages))) {
  curPkg <- cranPackages[i,]
  pkg <- append(
    pkg,
    list(
      list(
        Package = curPkg$name,
        Version = curPkg$version,
        Source = "Repository",
        Repository = "CRAN"
      )
    )
  )
}
renv::record(pkg)

pkg <- list()
githubPackages <- hadesPackageListFiltered |>
  dplyr::filter(onCran == FALSE)
for (i in seq_len(nrow(githubPackages))) {
  curPkg <- githubPackages[i,]
  pkg <- append(
    pkg,
    list(
      paste0(curPkg$organization, "/", curPkg$name, "@v", curPkg$version)
    )
  )
}
renv::record(pkg)
