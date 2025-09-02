----determine version in powershell
--Get-DbaInstanceProperty -SqlInstance "Aname-DEV" -InstanceProperty BuildNumber,VersionString,BuildClrVersionString, Edition, ErrorLogPath
--select @@version

--Servicing models for SQL Server: https://learn.microsoft.com/en-us/troubleshoot/sql/releases/servicing-models-sql-server
--GDR: A GDR addresses an issue that has a broad customer impact, security implications, or both
--	 A GDR can have either an RTM baseline or a CU baseline. The number of GDRs is kept to a minimum.
--On-demand fixes (OD)
--CU:All the fixes, improvements, and feature enhancements since the release version of the product.SQL SERVER 2017 AND LATER

--If you're using CUs for your SQL Server instance, you can check whether there's a GDR available for a given CU by reviewing the Cumulative Update 
--or Security ID column for the corresponding version in the builds spreadsheet at https://aka.ms/sqlserverbuilds

--Issues to patching: https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/install/windows/sqlserver-patching-issues

--During installation, General Distribution Release (GDR) or CU31 may exclude each other depending if included what you are installing 
- You may have to install  GDR then CU if GDR package doesn't include the latest CU

 --***********use DBA Tools
 ## https://desertdba.com/how-i-applied-13-cumulative-updates-in-12-minutes/
 ##it will restart the physical box

 #you may have to update your local  https://sqlcollaborative.github.io/assets/dbatools-buildref-index.json

 last patches are here 
  https://learn.microsoft.com/en-us/troubleshoot/sql/releases/download-and-install-latest-updates
  or
  The Most Recent Updates for Microsoft SQL Server - SQLServerUpdates.com


$ServerName = "SQL-TEST001","SQL-TEST002" # remote servers won't work if Service Principal Names(SPN) for SQL Server is not set in Active Directory


$KeyPath = 'C:\DBA\'

$UserName = 'domain\mbello'

$CredFile = $KeyPath+'mbello.cred'

##store password encrypted in file: it is OS specific. one created on os1 won't work on os2
#$Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
#$Credential.Password | ConvertFrom-SecureString | Out-File $CredFile -Force

#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString # Unlike a secure string, an encrypted standard string can be saved in a file for later use
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString


#has to be shared folder accessable by all servers involved
$PathCU = '\\sql-test001\Sql_Backup\download'

##don't remane the download file
$VersionCU = 'SQLServer2017-KB5016884-x64'

Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true # it is set to true

#write-host "get build before" 
#Get-DbaInstanceProperty -SqlInstance "SQL-TEST001","SQL-TEST002"  -InstanceProperty BuildNumber, edition, ErrorLogPath 
Get-DbaInstanceProperty -SqlInstance "SQL-TEST001","SQL-TEST002"  -InstanceProperty BuildNumber # BuildNumber,VersionString,BuildClrVersionString, Edition, ErrorLogPath

#tested the update to CU31 - omit version will update to the lastest of files find in download folder
# can update different versions of sql server if CU is found in the downlad folder
#Update-DbaInstance -ComputerName $ServerName -Restart -Version CU31 -Path $PathCU -Credential $Credential -Confirm:$false -whatif 
#Update-DbaInstance -ComputerName $ServerName -Restart -Path $PathCU -Credential $Credential -Confirm:$false -whatif
Update-DbaInstance -ComputerName $ServerName -Restart -Path $PathCU -Credential $Credential -Confirm:$false -verbose | out-file sqlpatch.log -Force

#check SPN is set
#Test-DbaHostn -ComputerName 'SQL-TEST002' -Credential $Credential
#'SQL-TEST002' | Get-DbaInstanceProperty -SqlCredential $Credential

#write-host "get build after" 
Get-DbaInstanceProperty -SqlInstance "SQL-TEST001","SQL-TEST002"  -InstanceProperty BuildNumber #, edition, ErrorLogPath

--********* USE exe 
#Program 11/14/2023 
#****grant the priv to SQL Server service account
#****copy files from one server then patch this instance
# Author: Monktar Bello - DBA

clear
ipconfig
hostname

$directoryPath = "C:\DBA\SQL_Patches\"

# Check if the directory exists
if (-not (Test-Path -Path $directoryPath -PathType Container)) {
    # If not, create the directory
    New-Item -Path $directoryPath -ItemType Directory
    Write-Host "Directory created: $directoryPath"
} else {
    Write-Host "Directory already exists: $directoryPath"
}

cd \\xxx.xxx.xxx.xxx\SQL_Patches\SQL_2017

 #copy files needed
 Copy-item 'SQLServer2017-KB5029376-x64.exe' -Destination C:\DBA\SQL_Patches\
 Copy-item 'mssqlexpress_peACpmamy.ps1' -Destination C:\DBA\SQL_Patches\


#grant priv to sql service
$username = @('MSSQL$SQLEXPRESS')
icacls 'C:\Program Files\Microsoft SQL Server' /grant "$($username):(OI)(CI)F"

#get status on sql serverservice: BEFORE
Get-Service -Name '*sql*' | SELECT-OBJECT NAME, status

# Stop SQL Server services
Get-Service -Name 'MSSQL$SQLEXPRESS' | Stop-Service -Verbose

# run exe to patch
 Start-Process -FilePath "C:\DBA\SQL_Patches\SQLServer2017-KB5029376-x64.exe" -Verb RunAs -Wait

# Start SQL Server services
Get-Service -Name 'MSSQL$SQLEXPRESS' | Start-Service -Verbose

#get status on sql serverservice : AFTER
Get-Service -Name '*sql*' | SELECT-OBJECT NAME, status

