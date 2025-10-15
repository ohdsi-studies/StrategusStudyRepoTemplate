config <- config::get()

# Don't make changes below this line -------------------------------------------

connection <- OhdsiSharing::sftpConnect(config$sftpKeyFileName, config$sftpUserName)
OhdsiSharing::sftpCd(connection, config$sftpRemote)
files <- OhdsiSharing::sftpLs()$fileName
OhdsiSharing::sftpGetFiles(connection, files, config$sftpDownloadFolder)
OhdsiSharing::sftpDisconnect(connection)
