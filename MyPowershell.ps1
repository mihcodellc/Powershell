# powershell for admin & automate tasks

#Start-Process -FilePath "powershell" -Verb RunAs
Start-Process -FilePath "powershell" -Verb RunAs


#programming in powershell
https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-01?view=powershell-7.3

#installed Module
Get-InstalledModule

#path to module
Get-Module -Name dbatools | Select-Object -ExpandProperty Path

##use trust connection is futher below

#Available modules
get-module -listavailable

#install sql modules: SqlServer & SQLPS
#https://learn.microsoft.com/en-us/sql/powershell/download-sql-server-ps-module?view=sql-server-ver16
Install-Module -Name SqlServer -Scope CurrentUser
Install-Module dbatools -Scope CurrentUser

#if not installing copy to C:\Program Files\WindowsPowerShell\Modules from a computer where is installed 
#dbatools
#dbatools.library
#Import-Module -name dbatools


Names are partitioned into various namespaces
variables are stored on Variable:, 
environment variables are stored on Env:, 
functions are stored on Function:

$Count = 10
$Variable:Count # accesses variable Count in namespace Variable
$Env:Path # accesses environment variable Path in namespace Env
$v and $Variable:v are interchangeable

#use your own folder for DBATools if error refer to "Error Powershell install - No match was found.ps1"
#-1 Install-Module dbatools -Scope CurrentUser
#-2 Import-Module dbatools
#if above doesn't work then add the path to dbatools to powershell path
$Env:PSModulePath = $Env:PSModulePath+";S:\DBA\dbatools"
#install https://www.sqlshack.com/dbatools-powershell-module-for-sql-server/


$cred = Get-Credential mydomain\mbello

$PSVersionTable # PowerShell Version

Update-Help -UICulture en-US -Verbose #just english's help
# "Get-Command", "help", "get-help", "| Get-Member"
# search command based the verb-noun naming standard for cmdlets
Get-Command -Noun a-noun*
Get-Command -Verb a-verb*
Get-Command -Verb a-verb* -Noun a-noun*

Get-Command -ParameterType 'a type' # type get from the output of Get-Member
									#learn more about 'a type' ex: String, Process 

# help 'cmd name' -Examples #more readable, paginate
	Get-Help -Name 'cmd name' # with or without the '
	Get-Help cmd_name -Examples # or Full, Detailed, Online, Parameter
	Get-Help cmd_name -Full #it might not be applicable for a command or not available 
							#in powershell,
    Get-Help cmd_name -online	
    cmd_name-? # work for .bat for help

# Get-Member at the end of the command
help 'cmd name' | Get-Member

ls --list
ls  | select-object name | out-file -append G:\myback.txt # list the name of files then addthen to a file
cls -- clear

# choose the ouput onlist or table: Format-Table or Format-List
Get-Process chrome | Format-List # or Format-Table

# you can build your own cmdlets in .NET Core or PowerShell

# 5 types of cmds: cmdlets, functions, scripts, aliases, and executables

Get-Member # pour afficher tous les proprietes !!! attention a ne pas utiliser une option avant Get-member autrement tous les proprietes ne s'afficheront pas

Get-Process chrome | Get-Member #can add the header as below 
Get-Process chrome | Get-Member -name to*
Get-Process chrome | Get-Member -MemberType to*
Get-Process chrome | Format-List -Property p* # property name starting with p*
Get-Process chrome | Select-object <property1>, <property2> #'Select-object' to choose the property correct name
Get-Process chrome | sort-object -unique -descending -property <property1>, <property2>

#process run form SQL for instance or  by another  user
#===== PowerShell Processes (WMI) =====
Get-WmiObject Win32_Process -Filter "Name='powershell.exe'" |    Select-Object ProcessId, CommandLine, Status
#===== PowerShell Processes (CIM) ====="
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |  Select-Object ProcessId, CommandLine, Status
#===== Current Session History with PID =====
Get-History | Select-Object @{Name='PID';Expression={$pid}}, Id, CommandLine

#kill identified process
Stop-Process -Id 14340 -Force


#excute win dos / cmd as admin
powershell -command "start-Process cmd -verb runas"

#filtering left means to filter something as early as possible in a statement
Get-Process | Where-Object CPU -gt 1000 | Sort-Object CPU -Descending | Select-Object -First 3 
get-childitem -path "c:\Backup" -recurse -filter *DIFF*.bak | Where-Object LastWriteTime -gt '2022-04-10' # LastWriteTime is in byte so divide it by 1024 to convert to next level
get-childitem -path "c:\Backup" -recurse -filter *log* | Where-Object {$_.LastWriteTime -gt '2022-04-05' -and $_.LastWriteTime -lt '2022-04-11'} | select-object length, name #interval or  more than one condition, use $_. and {} OR chain |

#filter and export csv - recurse ie sub folders
get-childitem -path "c:\Backup" -recurse -filter *FULL*.bak | Where-Object LastWriteTime -gt '2022-04-05' | where-object LastWriteTime -lt '2022-04-11' | select-object length, name | export-csv -path 'c:\findBak.csv'


#List files in folder - Send output and create a file:  4>&1 ie verbose stream #4 To sucesss Stream #1
#	list of # streams and options here: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1
"ws-netmon\SQLEXPRESS" | Invoke-DbaQuery -File "G:\DBA\Scripts\job_Backup_Full.sql" -Database MyDB -SqlCredential $Credential -verbose 4>&1 | out-file -append G:\DBA\Scripts\job_Backup_Full.log

Get-Process | Out-File -FilePath .\Process.txt
Get-Content -Path .\Process.txt
get-childItem -depth 2 -filter *.mdf | out-file size_mdf_08312022.txt # sub dir level 2

#fullName and Name -better use $_... instead of property's or column's name
 get-childitem -depth 2 -filter *diff_20230124*.bak  | % {$_.Name} # filename
 get-childitem -depth 2 -filter *diff_20230124*.bak  | % {$_.FullName} # fullpat h+ name
 
 #count Measure-Object
  get-childitem -depth 2 -filter *diff_20230124*.bak  | Measure-Object -Line -Character

$fileList = Get-ChildItem -Path C:\MyFolder
$count = ($fileList | Measure-Object).Count
Write-Host "Number of files in the folder: $count"

or 
#just count
 Get-ChildItem -Path C:\MyFolder | Measure-Object

 
 #add to a file after create the query $script --  output ie out-file didn't work for this purpose
 $script | Set-Content -Path $RestoreFile
"One", "Two", "Three", "Four" | Set-Content -Path C:\Temp\tmp.txt
Get-Content C:\Temp\tmp.txt | Measure-Object -Character -Line -Word

#full path without the name of the file
$absPath = Split-Path -Path $_.FullName #full path without the name of the file
#index, length
$ind = $absPath.IndexOf('SQLEXPRESS\') + 'SQLEXPRESS\'.Length
 # extract, substring
 $des1 = $destina+$absPath.Substring($ind)+'\'
 
  #“`n” to add a new line in string output.
Write-Host "This text have one newline `nin it."
  
 #format the date 
 $myDate = Get-Date #  Get-Date -format "yyyymmdd"
 #get file written previous (-1) day but top 1 ie First 10
 get-childitem -recurse -filter *.bak | where LastWriteTime -gt ($myDate).Date.addDays(-1) | select Name -First 10

#append output to existing file; recurse for sub folder 
get-childItem -recurse -filter *.ldf | out-file .\size08312022.txt -append -force
#Add the contents of a specified file to another file
$From = Get-Content -Path .\CopyFromFile.txt
Add-Content -Path .\CopyToFile.txt -Value $From
Get-Content -Path .\CopyToFile.txt

#formatting right means to format something as late as possible in the statement.
#to not loose property or method you care about

#Policies(7): AllSigned, Bypass, Default, Restricted, RemoteSigned, Unrestricted, undefined
Get-ExecutionPolicy -List
Get-ExecutionPolicy -scope currentuser

Set-ExecutionPolicy -ExecutionPolicy AllSigned -scope currentuser

#create a file .ps1. it is compiled into abstract syntax tree (AST)
#compiled and interpreted approaches ie check AST then interpret .ps1
# azure shell uses: touch file1 file2 -- code file1 -- mv oldFilename newFileName
#write-host, read-host, write-output, write-error, throw
#once execute, crtl+z doesn't work
New-Item HelloWorld.ps1 -ItemType File #create folder -ItemType Directory
./HelloWorld.ps1 
#exec 1 para
./HelloWorld.ps1 -d_name "Monktar"
#exec 2 parameters
.\RestoreBackUpFromDirectory.ps1 param1 param2

# other ways to execute
# .\HelloWorld.ps1
# . .\HelloWorld.ps1
# & ".\psinstallagent.ps1"
# & "$PSScriptRoot\HelloWorld.ps1"
# powershell -file "C:\download\HelloWorld.ps1" Install,Interactive
# powershell.exe -File "D:\DBA\Maintenance\GetBackUpsRestorePerDB.ps1" B:\Rep1\Rep2\$_  \\sql-path\xfer\$_ FULL $_ Yes

#execute bat file
cmd.exe /c 'test-01.bat'
Start-Process -FilePath 'c:\bello\test-02.bat' -NoNewWindow

#windows task scheduler
powershell.exe -File "d:\myscript.ps1" 
#no need to add the full path of powershell - Program/script: powershell.exe --- add arguments: -File "d:\myscript.ps1"
powershell.exe -File "D:\GetBackUpsRestore.ps1" FULL #FULL a parameter for .ps1
##doc for powershell.exe https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1
same goes for .bat, to run ps1 from batch ie command shell
powershell.exe -File "d:\myscript.ps1" 
exit 0

## run in tsql for SQL Agent Job
declare @svrName varchar(255)
declare @sql varchar(400)
--by default it will take the current server name, we can the set the server name as well
set @svrName = @@SERVERNAME
set @sql = 'powershell.exe -File "S:\DBA\Maintenance\Restore_last_Full_Back.ps1"'
EXEC xp_cmdshell @sql

#store password encrypted in file
$KeyPath = 'G:\maintenance\'
$Username = 'mitiri\mbello'
$CredFile = $KeyPath+'mbello.cred'
#store password encrypted in file: it is OS specific. one created on os1 won't work on os2
$Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
$Credential.Password | ConvertFrom-SecureString | Out-File $CredFile -Force


#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString # Unlike a secure string, an encrypted standard string can be saved in a file for later use
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString

# Retrieve the NetworkCredential object from the PSCredential object
$networkCredential = $Credential.GetNetworkCredential()

#Get encrypted password from the file
$pass = $networkCredential.Password

#mount
#NET USE B: \\sql-backups.mitiri.com\backup /u:mitiri\mbello xxxxxxxxxxxxxxxxxxxx # caveat: I happened it mounts the C: drive when this is NOT shared
#preferred the version above to assess the shared drive size
New-PSDrive -Name "B" -PSProvider "FileSystem" -Root "\\sql-backups.mitiri.com\backup" -Credential $Credential -Scope Global
cd B:\
ls | select FullName
#pause
start-sleep -Seconds 10
#unmount
#NET USE B: /delete
Remove-PSDrive -Name B -Force

#delete file, folder
Remove-Item -path  d:\bello -Recurse -Force
$destina = 'D:\DBA\'
Remove-Item -Path $destina+'*.bak' -Recurse -Force 
#pause
start-sleep -Seconds 5


#***run script on remote server
# Replace 'RemoteServer' with the actual remote server name or IP address
$remoteServer = 'mitiristore.com' #172.16.5.49
# Specify the script block to execute on the remote server
$scriptBlock = {
    # Your script code goes here
    # For example, running a script file
    & 'C:\DBA\myscript.ps1'
}
# Use Invoke-Command with credentials
Invoke-Command -ComputerName $remoteServer -ScriptBlock $scriptBlock -Credential $Credential


#debug/tracin execution of .ps1 file
Set-PSDebug -Trace 1

#profile in powershell
$profile | Select-object * 

# '*.trn' files in folder  and all subdirectories that are more than 48 hours old will be removed
Remove-DbaBackup -Path 'C:\MSSQL\SQL Backup\' -BackupFileExtension trn -RetentionPeriod 48h -WhatIf

# Get date/time for last known backups of databases.
Get-DbaLastBackup -SqlInstance ServerA\sql987 | Select-Object * | Out-Gridview

# allows administrators to regain access to SQL Servers in the event that passwords or access was lost.
Reset-DbaAdmin -SqlInstance sqlserver\sqlexpress -Login sqladmin -Force

# connect to sql server 
# using SQL Server PowerShell (sqlps) exists as a (1) utility and (2) as a PS module - exit by accessing a drive c:
# get-command -module sqlps

#execute a script file more at https://docs.dbatools.io/Invoke-DbaQuery.html
"InstanceName\SQLEXPRESS" | Invoke-DbaQuery -File "D:\DBA\OlaDiff.sql"
cd G:
cd G:\DBA\
#run another 
.\\CopyOverBackUps.ps1 DIFF
exit

#Runs, execute the sql commands stored in rebuild.sql against the instances "server1", "server1\nordwind" and "server2" and output/out-file verbose
#   4>&1 ie verbose stream #4 To sucesss Stream #1 without it verbose won't be in the file
#   list of # streams and options here: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1
C:\> "server1", "server1\nordwind", "server2" | Invoke-DbaQuery -File "C:\scripts\sql\rebuild.sql" -Database MyDB -verbose 4>&1 | out-file -append G:\DBA\Scripts\job_Backup_Full.log

#Runs, execute the sql query 'SELECT foo FROM bar' against the instance 'server\instance'
Invoke-DbaQuery -SqlInstance server\instance -Query 'SELECT foo FROM bar'
Invoke-DbaQuery -SqlInstance . -Query 'SELECT * FROM users WHERE Givenname = @name' -SqlParameter @{ Name = "Maria" }

##########begin script out object SP, Tables .... from server #####################
# https://docs.dbatools.io/Export-DbaScript
# https://docs.dbatools.io/New-DbaScriptingOption 
# # all Microsoft.SqlServer.Management.Smo.ScriptingOptions 
# https://learn.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.scriptingoptions?redirectedfrom=MSDN&view=sql-smo-160

#1. install dbatools for my user: Install-Module dbatools -Scope CurrentUser
#2. Import-Module dbatools
#3. replace sps' list for parameter name in export_db_script.ps1
#4. if needed, replace the out file destination and name

$options = New-DbaScriptingOption
$options.ScriptDrops = $true
Get-DbaDbStoredProcedure -SqlInstance MyinstanceName -Database DbName -Name <list all SPs with comma as seperator> | Export-DbaScript -ScriptingOptionsObject $options -FilePath G:\export_drop.sql -Append

##########end script out object SP, Tables .... from server #####################

#using dbatools
$sqlcred = Get-Credential sqladmin
Connect-DbaInstance -SqlInstance sql2014 -SqlCredential $wincred # with alternative win cred
$server = Connect-DbaInstance -SqlInstance sql2014 -SqlCredential $sqlcred -ApplicationIntent ReadOnly # with SQL Login

#use trust connection
#you will have to create a custom connection using Connect-DbaInstance to deal with non-standard configurations or connection string settings.
#option1 with -TrustServerCertificate
$cred=get-credential mbello
$sqlCn = Connect-DbaInstance -SqlInstance MyInstanceName -SqlCredential $cred -TrustServerCertificate
Invoke-DbaQuery -SqlInstance $sqlCn ...
#option2 with sql.connection.trustcert
#A second option that takes affects for all commands is setting it at the configuration level for the module.
Get-DbatoolsConfig -FullName sql.connection.trustcert # should see the value set to false
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true # it is set to true

#login valid but default db not available -> login failed
# with dbatools in powershell
$wincred = Get-Credential mbello
$sqlCn = Connect-DbaInstance -SqlInstance MyInstanceName -SqlCredential $wincred -Database master -TrustServerCertificate
Invoke-DbaQuery -SqlInstance $sqlCn -Query "ALTER LOGIN [mbello] WITH DEFAULT_DATABASE = master"

# SQL Server services on a computer
Restart-DbaService -ComputerName sql1,sql2 -InstanceName MSSQLSERVER
Stop-DbaService -ComputerName sqlserver2014a

# Start SQL Server services
Get-Service -Name 'MSSQLSERVER', 'SQLSERVERAGENT' | Start-Service
# Wait for services to start
Start-Sleep -Seconds 10
# Stop SQL Server services
Get-Service -Name 'MSSQLSERVER', 'SQLSERVERAGENT' | Stop-Service


# full database backup on the databases HR and Finance - Path or BackupDirectory
Backup-DbaDatabase -SqlInstance Server1 -Path C:\temp -Database HR, Finance -Type Full
Backup-DbaDatabase -Verbose -SqlInstance Server1 -BackupDirectory C:\temp -Database WideWorldImporters -Type Full -FileCount 16 -CopyOnly

# Export/Copy/move instance all except dbs in above
Export-DbaInstance -Verbose -SqlInstance Server1 -Exclude Databases -Path C:\dbatools\migration_log\


# master key, cetificate
Backup-DbaDbMasterKey -SqlInstance server1\sql2016
Backup-DbaDbCertificate -SqlInstance Server1 -Path \\Server1\Certificates
# Restores the DatabaseTDE certificate to Server1 and uses the MasterKey to encrypt the private key.
Restore-DbaDbCertificate -SqlInstance Server1 -Path \\Server1\Certificates\DatabaseTDE.cer -DecryptionPassword (Get-Credential usernamedoesntmatter).Password


#test my last full backup for MyDB1, attempts to restore it, then perfoAcompany a DBCC CHECKDB
Get-DbaDbBackupHistory -SqlInstance SqlInstance2014a -Database db1, db2 -Since '2016-07-01 10:47:00'
Test-DbaLastBackup -SqlInstance sql2016, sql2017 # all dbs
Test-DbaLastBackup -SqlInstance sql2016, sql2017 -NoCheck -NoDrop # all dbs but less tested
Test-DbaLastBackup -SqlInstance sql2016 -Database MyDB1, MyDB1

# Restores a SQL Server Database from a set of backup files
# Restore-DbaDatabase -SqlInstance server1\instance1 -Path \\server2\backups
$RestoreTime = Get-Date('11:19 23/12/2016')
Restore-DbaDatabase -SqlInstance server1\instance1 -Path \\server2\backups -MaintenanceSolutionBackup -DestinationDataDirectory c:\restores -RestoreTime $RestoreTime -OutputScriptOnly

# https://dbatools.io/commands
# Clear-DbaWaitStatistics, Get-DbaWaitingTask, Get-DbaWaitResource, Export-DbaUser
# Export-DbaInstance




#search in winddows event logs or GUI eventvwr.msc
#Get-WinEvent: Gets events from event logs and event tracing log files on local and remote computers.
#https://woshub.com/search-windows-event-logs-powershell/#:~:text=Querying%20Windows%20Event%20Logs%20with%20PowerShell%201%20Get-WinEvent%3A,4%20Get%20Event%20Logs%20from%20Remote%20Computers%20
$EndDate = (Get-Date) - (New-TimeSpan -Hour 21 )
$StartDate = (Get-Date) - (New-TimeSpan -Hour 20 )

Get-WinEvent Application,System | Where-Object {($_.LevelDisplayName -eq "Error" -or $_.LevelDisplay
Name -eq "Warning") -and ($_.TimeCreated -ge $StartDate -and $_.TimeCreated -le $endDate ) -and $_.Providername -eq "MSS
QLSERVER"} | select-object -expandProperty message # -expandProperty to avoid truncate string, get the whole text

Get-WinEvent -ListLog * | where-object logname -notlike microsoft* | select-object logname

#search login error on OS level
$date = (get-date).adddays(-2)
Get-WinEvent -FilterHashtable @{logname='security'; StartTime=$Date; data='mbello'} | where {$_.KeyWordsDisplayNames -eq "{Audit Failure}"} | fl


#Error handling with verbose of powershell is doing: Start-Transcript/Stop-Transcript
$KeyPath = 'C:\DBA\'
$Username = 'mitiri\mbello'
$CredFile = $KeyPath+'mbello.cred'

$logFile = $KeyPath+'Myscript.log'

#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString -key $key
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString
#add dbatools
$Env:PSModulePath = $Env:PSModulePath+";S:\DBA\dbatools"
#created trusted connection
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
 
try {
 ##execute the content of the file  $RestoreFile
 Start-Transcript -Path $logFile # the magic happens here writing what powershell is doing
  "InstanceName" | Invoke-DbaQuery -File "C:\myscript.sql" -SqlCredential $Credential -verbose
 Stop-Transcript
 }
catch {
    # Catch any errors and write them to a file
    $errorMessage = "Error: $($_.Exception.Message)"
    $errorMessage | Out-File -Append -FilePath $logFile
}



#run ps with dbatools as sql
#1 in ps file "Restore_last_Full_Back.ps1"
$logFile = 'S:\DBA\Maintenance\Myscript.log'

$Env:PSModulePath = $Env:PSModulePath+";S:\DBA\dbatools"
#created trusted connection
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

try {
 ##execute the content of the file  $RestoreFile
 Start-Transcript -Path $logFile # the magic happens here writing what powershell is doing
  "InstanceName" | Invoke-DbaQuery -File "S:\DBA\Maintenance\myscript.sql"  -verbose
 Stop-Transcript
 }
catch {
    # Catch any errors and write them to a file
    $errorMessage = "Error: $($_.Exception.Message)"
    $errorMessage | Out-File -Append -FilePath $logFile
}
#2 in management studio or as job
declare @svrName varchar(255)
declare @sql varchar(400)
--by default it will take the current server name, we can the set the server name as well
set @svrName = @@SERVERNAME
set @sql = 'powershell.exe -File "S:\DBA\Maintenance\Restore_last_Full_Back.ps1"'
EXEC xp_cmdshell @sql


#get the hostname knowing IP address
[System.Net.Dns]::GetHostEntry("8.8.8.8").HostName


