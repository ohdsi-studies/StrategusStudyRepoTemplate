config <- config::get()

# open this inside your strategus project or set the directory
# using setwd('location to strategus directory')
ProtocolGenerator::generateProtocol(
  jsonLocation =   file.path(config$projectRootFolder, "inst", config$studySpecificationFileName),
  webAPI = config$webApiUrl, 
  outputLocation = '../extras', 
  outputName = 'protocol.html', 
  intermediateDir = tempdir()
)