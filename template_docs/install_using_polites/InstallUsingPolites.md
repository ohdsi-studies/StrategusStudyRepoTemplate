Setup Environment Using Polites
=================

This guide will walk through how to setup your Windows environment using Polites. 
More information on using the Polites tools to setup your environment can be found at https://greshje.github.io/polites/quick-start.html. 

## Download the Polites YesInstaller
Download and run the YesPolitesInstaller executable file. 
Click <a href="https://www.dropbox.com/scl/fi/534uvoc8y2iuz91tcx0ah/YesPolitesInstaller-1.2.061.exe?rlkey=nseujjakkumfm4oesp3j8d3lz&dl=1">here</a> to download. 

Navigate to C:\_YES_POLITES\tools\r and run the RTools installer and the RStudio installer (R has already been installed by the YesPolites installer). <br/>
<img src="./img/r-installs.png" />
 
## Configure RStudio
Open RStudio.  When prompted to choose an R installation, use the browse option and then use:<br/> 
C:\\_YES_POLITES\\tools\\r\\R\\R-4.4.1\\bin\\R.exe <br/>
If not propted, select tools->Global Options->General->R version<br/>
<img src="./img/select-r-installation.png" width="500px" style="display: block; margin: 0 auto;"/>

## Fork and Clone the StrategusStudyRepoTemplate project
Fork the StrategusStudyRepoTemplate and create a new branch in your forked version. 
Clone your forked version and checkout the branch you created. 

## Generate your Github Personal Access Token (PAT)
In order to install the R packages required for this project, you will need a Github Personal Access Token (PAT).  <br/>
A token can be created at the following Github URL: </br>
https://github.com/settings/tokens<br/>

## Open RStudio as Admin and then Open the StrategusStudyRepoTemplate Project
Important: Open R as Admin. The following process will require the installation of many R packages.  Some of these installs will fail if you do not run as Admin.  <br/>
Start RStudio as Admin. Select File->Open Project and navigate to the StrategusStudyRepoTemplate.proj file in the StrategusStudyRepoTemplate project you just cloned and checked out.  

## Run the Setup Scripts
Run the scripts in the \_StartHere/init folder in order:
<ul>
	<li>
		<b>00-EditRenvironmentFile.R:</b>This script will let you edit your Renviron file. Add the lines shown in the comment at the top of this file to the Renviron file. After editing and saving this file, restart R (Session->Restart R).<br/>
		<b>Important: Don't forget to save the file before restarting R.</b><br/>
		<b>Important: Don't forget to restart R.</b>
	</li>
</ul>
