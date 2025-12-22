#' Cross platform auth for WebApi
#' If your WebAPI does not use security, set authMethod = "none"
authWebApi <- function(config = config::get(), authMethod = "windows") {
  if (authMethod == "none") {
    return(NULL)
  }
  params <- list(
    baseUrl = config$webApiUrl,
    authMethod = authMethod
  )
  if (.Platform$OS.type != "windows" || authMethod != "windows") {
    params$webApiUsername <- Sys.info()['user']
    if (rstudioapi::isAvailable())
      params$webApiPassword <- rstudioapi::askForSecret("Enter your web api password")
    else
      params$webApiPassword <- getPass::getPass("Enter your web api password: ")
  }
  do.call(ROhdsiWebApi::authorizeWebApi, params)
}