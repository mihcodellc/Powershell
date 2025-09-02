#Powershell install - No match was found for the specified search criteria and module name 'dbatools'
#source: https://stackoverflow.com/questions/63385304/powershell-install-no-match-was-found-for-the-specified-search-criteria-and-mo


#1. close all app using powershell
#2. delete the installed version of dbatools
#3. install the lates version of dbatools


#4.Enable TLS 1.2:
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#5.Register the default PS Gallery Repo (may check Get-PSRepository | fl* just incase)
Register-PSRepository -Default

#6.Install-Module dbatools (check Find-Module before to validate)
Find-Module dbatools
Install-Module dbatools -Scope CurrentUser #Use -Force switch if an older version of dbatools exists.
