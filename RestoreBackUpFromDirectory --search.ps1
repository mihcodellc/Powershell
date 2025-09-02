#created by Monktar Bello 2/17/2023
#description: create restore sql file which also used the SQL email profil to report the outcome to Dba
#			  the destination server name is not parameterize intentionally as it replace the existing dabase.
#			  It can't be use on production server ONLY test server
#			  it get the list of files looking at $numdays
#			  It does closed all connections to the DBs 
#			  Two (2) files are created as logs: $logFile & $logsuccess
#			  You also need dbatools to use it

Param(
[Parameter(mandatory, HelpMessage = "Type of backup FULL, DIFF, LOG")] # use of parameter[] decorator
[string]$backup_Type = "FULL",
[Parameter(mandatory, HelpMessage = "Database name")]
[string]$database = "MyDB",
[Parameter(mandatory, HelpMessage = "Path to destination of database name")] # use of parameter[] decorator
$destina = ''
[Parameter(mandatory, HelpMessage = "Type the name of the server")] # use of parameter[] decorator
$ServerName = "AnInstance_name"																							  
) 

$ServerName_Fallback = "AnInstance_name2"								   

#https://www.sharepointdiary.com/2020/01/read-write-encrypted-password-file-in-powershell-script.html#:~:text=How%20to%20use%20an%20Encrypted%20Password%20File%20to,from%20the%20file%20and%20use%20it%20in%20scripts.
#store password encrypted in file
$KeyPath = 'D:\DBA\maintenance\'

$Username = 'Alogin' #sql login not windows

$CredFile = $KeyPath+'LogShipLogin.cred'

 #restore.sql path
 $RestoreFile = $KeyPath+'restore_'+$database+'.sql'
 
 
##ATTENTION TO SERVER DESTINATION AT THIS SECTION
#EXECUTE THE CONTENT OF THE FILE  $RESTOREFILE

#store password encrypted in file: it is OS specific. one created on os1 won't work on os2
##$Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
##$Credential.Password | ConvertFrom-SecureString | Out-File $CredFile -Force

#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString # Unlike a secure string, an encrypted standard string can be saved in a file for later use
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString


 #$source = $destina
 $search = ''
 
$source = 'D:\xfer\'+$database 
 cd G:
 cd $source

  $myDate = Get-Date # Get-Date -format "yyyymmdd"


$logFile = $KeyPath+'RestoreBackUpFromDirectory.log'

$logsuccess = $KeyPath+'Restore'+$Database+'success.log'


# Log the progress to a file
"$myDate" | Out-File -Append -FilePath $logFile

 
 #Remove-Item -Path $destina+'*.bak' -Recurse -Force 
 #start-sleep -Seconds 5


 #set search based of type of backup
 if ($backup_Type -in @('FULL','DIFF')){

    $search = '*'+$backup_Type+'*.bak'

    if ($backup_Type -eq 'FULL'){
        $numdays = -6
    }
    else{
        $numdays = -1
    }
 }
 
 if ($backup_Type -eq 'LOG') {

    $search = '*.trn'

    $numdays = 0
 }

 $script = "Use master `nGo`n
 DECLARE @dbid INT, @KillStatement char(30), @SysProcId smallint, @DB char(50) = '"+$Database+"'
--define the targeted database 
SELECT @dbid = dbid FROM sys.sysdatabases WHERE name = @DB 
IF EXISTS (SELECT spid FROM sys.sysprocesses WHERE dbid = @dbid)
  BEGIN
    SELECT spid, hostname, loginame, status, last_batch FROM sys.sysprocesses WHERE dbid = @dbid 
	USE master
    DECLARE SysProc CURSOR LOCAL FORWARD_ONLY DYNAMIC READ_ONLY FOR
    SELECT spid FROM master.dbo.sysprocesses WHERE dbid = @dbid
    OPEN SysProc
    FETCH NEXT FROM SysProc INTO @SysProcId
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @KillStatement = 'KILL ' + CAST(@SysProcId AS char(30))
        EXEC (@KillStatement)
        FETCH NEXT FROM SysProc INTO @SysProcId
    END 
END `n"+"RESTORE DATABASE ["+$Database+"] "+"FROM "

 #$script | Set-Content -Path $RestoreFile
 

 # Log the progress to a file
"Scripting the restoration starts for $database." | Out-File -Append -FilePath $logFile

 #bak file create during last 6 days
 #Write-Output $search
 get-childitem -recurse  $search |  % {$_.FullName} | out-file $RestoreFile -append -force

 get-childitem -recurse -filter $search | where LastWriteTime -gt ($myDate).Date.addDays($numdays) | sort-object name |
 ForEach-Object {
    $script = $script+"`nDISK = N'"+$_.FullName+"'," 

 }

	# Log the progress to a file
	"$_.FullName added to restoration script." | Out-File -Append -FilePath $logFile
	
 $ind = $script.Length
 $script = $script.Substring(0,$ind-1)

#default the following database's datafiles to different folder
 if ($Database -in "myDB2"){
	 $script = $script +" WITH MOVE '"+$Database+"' TO 'W:\MSSQL\Data\"+$Database+".mdf',
     MOVE '"+$Database+"_log' TO 'W:\MSSQL\tlog\"+$Database+"_log.ldf', 
	 "
 }else{
	 $script = $script +" WITH "
 }
 
#in no restore state so DBA can restore more files
 $script = $script +"  NORECOVERY, REPLACE,  STATS = 5`n "

<# block comment															
  ----------
 #>

WRITE-HOST $script | Out-File -FilePath $RestoreFile -force

 #write to the file the script to execute
 $script | Set-Content -Path $RestoreFile

 #add dbatools
 $Env:PSModulePath = $Env:PSModulePath+";S:\DBA\dbatools"
 
 #created trusted connection
 Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
   

 
 
 try {
 ##execute the content of the file  $RestoreFile
 $Error.Clear()
 Start-Transcript -Path $logsuccess 
  $ServerName | Invoke-DbaQuery -File $RestoreFile -sqlCredential $Credential -verbose 
  # Check for errors
  # it didn't execute the remaining script when enter in "Start-Transcript"
  # so sending failure and error message
if ($Error.Count -gt 0) {
    Write-Output "An error occurred during execution."
$script = " `n
DECLARE @ServerName VARCHAR(25);
DECLARE @Email_Body VARCHAR(400);
DECLARE @Email_subject VARCHAR(100);

DECLARE @dbid INT, @KillStatement char(30), @SysProcId smallint, @DB char(50) = '"+$Database+"'

SET @ServerName = CAST((SELECT SERVERPROPERTY('MachineName') AS [ServerName]) AS VARCHAR(25))
SET @Email_subject = 'Restore of SQL Full Backup of ' + @DB

SET @Email_Body = 'RESTORE DATABASE failed for '+ trim(@DB) +' on ' + @ServerName +'.'+char(10)+char(13)+'"+$Error+"';

EXEC msdb.dbo.sp_send_dbmail 
		   @body = @Email_Body
		  ,@body_format = 'TEXT'
		  ,@profile_name = N'DataServicesProfile'
		  ,@recipients = N'db_maintenance@mih.com'
		  ,@Subject = @Email_subject
		  ,@importance = 'High' 
"
	$ServerName_Fallback | Invoke-DbaQuery -Query $script -sqlCredential $Credential -verbose 	
    
} 

 Stop-Transcript
 }
catch { #catch applicable if Start-Transcript is not used 
    # Catch any errors and write them to a file
    $errorMessage = "Error: $($_.Exception.Message)"
    $errorMessage | Out-File -Append -FilePath $logFile
	# it didn't execute the remaining script when enter here
	# so sending failure and error message	
}



 #checksuccess.sql path
 $checksuccess = $KeyPath+'checksuccess'+$database+'.sql'
 
 #checksuccess.sql path
 $checksuccess_log = $KeyPath+'checksuccess'+$database+'.log'
 

# Search for a specific string in the file
$searchString = "RESTORE DATABASE successfully processed"
$matches = Select-String -Path $logsuccess -Pattern $searchString

$content = Get-Content -Path $logsuccess

 
$linefOund=""
$found="NO"

#get the  whole line for the email
if ($matches.Length -gt 0)
{
	$found="YES"
	$content | ForEach-Object {
		if ($_ -match $searchString) {
			$linefOund = $_
			#continue 
		}
	}
	
}

#send successs or failure email
 $script = " `n
DECLARE @ServerName VARCHAR(25);
DECLARE @Email_Body VARCHAR(200);
DECLARE @Email_subject VARCHAR(100);

DECLARE @dbid INT, @KillStatement char(30), @SysProcId smallint, @DB char(50) = '"+$Database+"'

SET @ServerName = CAST((SELECT SERVERPROPERTY('MachineName') AS [ServerName]) AS VARCHAR(25))
SET @Email_subject = 'Restore of SQL Full Backup of ' + @DB

IF  'YES' = '"+$found+"'
	SET @Email_Body = 'RESTORE DATABASE successfully processed '+ trim(@DB) +' on ' + @ServerName +'.'+char(10)+char(13)+'"+$linefOund+"';
ELSE
	SET @Email_Body = 'RESTORE DATABASE failed for '+ trim(@DB) +' on ' + @ServerName +'.'

EXEC msdb.dbo.sp_send_dbmail 
		   @body = @Email_Body
		  ,@body_format = 'TEXT'
		  ,@profile_name = N'DataServicesProfile'
		  ,@recipients = N'db_maintenance@mih.com'
		  ,@Subject = @Email_subject
		  ,@importance = 'High' 
"

								 

#write to the file the script to execute
 $script | Set-Content -Path $checksuccess
 

 try {
 $Error.Clear()
 ##execute the content of the file  $checksuccess
 Start-Transcript -Path $checksuccess_log 
  $ServerName | Invoke-DbaQuery -File $checksuccess -sqlCredential $Credential -verbose 
  
  if ($Error.Count -gt 0) {
    Write-Output "An error occurred during execution."
$script = " `n
DECLARE @ServerName VARCHAR(25);
DECLARE @Email_Body VARCHAR(400);
DECLARE @Email_subject VARCHAR(100);

DECLARE @dbid INT, @KillStatement char(30), @SysProcId smallint, @DB char(50) = '"+$Database+"'

SET @ServerName = CAST((SELECT SERVERPROPERTY('MachineName') AS [ServerName]) AS VARCHAR(25))
SET @Email_subject = 'Restore of SQL Full Backup of ' + @DB

SET @Email_Body = 'RESTORE DATABASE failed for '+ trim(@DB) +' on ' + @ServerName +'.'+char(10)+char(13)+'"+$Error+"';

EXEC msdb.dbo.sp_send_dbmail 
		   @body = @Email_Body
		  ,@body_format = 'TEXT'
		  ,@profile_name = N'DataServicesProfile'
		  ,@recipients = N'db_maintenance@mih.com'
		  ,@Subject = @Email_subject
		  ,@importance = 'High' 
"
	$ServerName_Fallback | Invoke-DbaQuery -Query $script -sqlCredential $Credential -verbose 	
    
} 
  
 Stop-Transcript
 }
catch {
    # Catch any errors and write them to a file
    $errorMessage = "Error: $($_.Exception.Message)"
    $errorMessage | Out-File -Append -FilePath $logFile
}


cd ~ 

