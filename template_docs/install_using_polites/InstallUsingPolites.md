Setup Environment Using Polites
=================

This guide will walk through how to setup your Windows environment using Polites. 
More information on using the Polites tools to setup your environment can be found at https://greshje.github.io/polites/quick-start.html. 

## Download the Polites YesInstaller
Download and run the YesPolitesInstaller executable file:<br/>
https://www.dropbox.com/scl/fi/534uvoc8y2iuz91tcx0ah/YesPolitesInstaller-1.2.061.exe?rlkey=nseujjakkumfm4oesp3j8d3lz&dl=1. <br/>

Navigate to C:\_YES_POLITES\tools\r and run the RTools installer and the RStudio installer (R has already been installed by the YesPolites installer). <br/><br/>
 
## Configure RStudio
Open RStudio.  When prompted to choose an R installation, use the browse option and then use C:\\_YES_POLITES\\tools\\r\\R\\R-4.4.1\\bin\\R.exe<br/>

## Fork and Clone the StrategusStudyRepoTemplate project
TODO:Finish this thought

Clone and checkout your new fork and branch

## Generate your Github Personal Access Token (PAT)

## Open StrategusStudyRepoTemplate Project in RStudio
Important: Open R as Admin. The following process will require the installation of many R packages.  Some of these installs will fail if you do not run as Admin.  <br/>
Start RStudio as Admin. Select File->Open Project and navigate to the StrategusStudyRepoTemplate.proj file in the StrategusStudyRepoTemplate project you just cloned and checked out.  

## Run the three setup Scripts
Don't forget to restart after the script that edits the .Renviron file.  
