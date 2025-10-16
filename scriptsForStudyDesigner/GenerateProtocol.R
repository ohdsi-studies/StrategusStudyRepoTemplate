config <- config::get()

# open this inside your strategus project or set the directory
# using setwd('location to strategus directory')
ProtocolGenerator::generateProtocol(
  jsonLocation = file.path("inst", "sampleStudy", "sampleStudyAnalysisSpecification.json"),
  webAPI = config$webApiUrl, 
  outputLocation = '../extras', 
  outputName = 'protocol.html', 
  intermediateDir = tempdir()
)