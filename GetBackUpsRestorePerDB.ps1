#created by Monktar Bello 2/17/2023
#description: copy over type of backup and restore

Param(
[Parameter(mandatory, HelpMessage = "Path to source of database name")] # use of parameter[] decorator
$source = '',
[Parameter(mandatory, HelpMessage = "Path to destination of database name")] # use of parameter[] decorator
$destina = '',
[Parameter(mandatory, HelpMessage = "Type of backup FULL, DIFF, LOG")] # use of parameter[] decorator
$backup_Type = "FULL",
[Parameter(mandatory, HelpMessage = "Type the name of the database")] # use of parameter[] decorator
$db_name = "Test",
[Parameter(mandatory, HelpMessage = "Are you going to restore the database?")] # use of parameter[] decorator
$is_restored = "No",
[Parameter(mandatory, HelpMessage = "Type the name of the server")] # use of parameter[] decorator
$ServerName = "InstanceName"
) 
 $search = ''
 $numdays = 0
 #$source = 'local path'
 #$destina = 'local path'
 #$destina = 'shared path'
 
 #write-host $source
 #write-host $destina
 
 #write-host $source1
 #write-host $destina1
 
#https://www.sharepointdiary.com/2020/01/read-write-encrypted-password-file-in-powershell-script.html#:~:text=How%20to%20use%20an%20Encrypted%20Password%20File%20to,from%20the%20file%20and%20use%20it%20in%20scripts.
#store password encrypted in file
$KeyPath = 'S:\DBA\maintenance\'

$Username = 'mtiri-bj\user'

$CredFile = $KeyPath+'user.cred'

#store password encrypted in file: it is OS specific. one created on os1 won't work on os2
##$Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
##$Credential.Password | ConvertFrom-SecureString | Out-File $CredFile -Force

#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString # Unlike a secure string, an encrypted standard string can be saved in a file for later use
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString

#mount
#open directory on remote short term backup server
#NET USE B: \\mitit\backup /u:mih\mbello xxxxxxxxxxxxxxxxxxxx # caveat: it did mount c: drive when this is not shared
New-PSDrive -Name "B" -PSProvider "FileSystem" -Root $sharefolder -Credential $Credential -Scope Global #-persist to make available for other process
 
 
$logFile = $KeyPath+'GetBackUpsRestorePerDB.log'

$myDate = Get-Date # Get-Date -format "yyyymmdd"

# Log the progress to a file
"$myDate" | Out-File -Append -FilePath $logFile
 


 cd B:
 cd $source

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

 
  
 #WRITE-HOST /write-output $numdays

 #clean previous backups file
 $des1 = $destina+'\'+$search
 Remove-Item $des1
  
 #copy file create during last $numdays days
 get-childitem -recurse -filter $search | where LastWriteTime -gt ($myDate).Date.addDays($numdays) |  
 ForEach-Object {
 #   #Write-Host $_.FullName
    Copy-item $_.FullName -Destination $destina -force
	# Log the progress to a file
	"$_.FullName copied" | Out-File -Append -FilePath $logFile				 														   
 }


cd S:
cd S:\DBA\maintenance
 
#unmount
#NET USE B: /delete
Remove-PSDrive -Name B -Force

if ($is_restored -eq 'Yes') {
##restore from the localhost  S:\DBA\maintenance\RestoreBackUpFromDirectory.ps1
    # Log the progress to a file
	"$db_name will be restored. " | Out-File -Append -FilePath $logFile			 
	.\RestoreBackUpFromDirectory.ps1 $backup_Type $db_name $destina
 }


exit
	  


