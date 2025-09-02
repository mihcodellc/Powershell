#Program:
#description create from G:\DBA\Scripts\job_History_Bleedoff.bat
#		to account for new tables in MyDB database 
#		get the list of tables with timestamp then 
#		export data old than x days and delete them
#		reorganize indexes on those tables
#created by monktar bello 
#Date: 3/22/2024

#https://www.sharepointdiary.com/2020/01/read-write-encrypted-password-file-in-powershell-script.html#:~:text=How%20to%20use%20an%20Encrypted%20Password%20File%20to,from%20the%20file%20and%20use%20it%20in%20scripts.
#store password encrypted in file
$KeyPath = 'G:\DBA\Scripts\Maintenance\'

$SavedDir= 'G:\MSSQL\Backup\'

$Username = 'mbello'

$CredFile = $KeyPath+'mbello.cred'

$ShrinkFile = $KeyPath+'shrinkdatabase.sql'

$ShrinkSQL = $KeyPath+'shrinkdatabase_query.sql'

$msg="Start "

#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString # Unlike a secure string, an encrypted standard string can be saved in a file for later use
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString

# Retrieve the NetworkCredential object from the PSCredential object
$networkCredential = $Credential.GetNetworkCredential()

#Get encrypted password from the file
$pass = $networkCredential.Password


$MyServerInstance = "mitiri\SQLEXPRESS"
$MyDB = "myDB"

$DayToSave = "7"

$date = Get-Date -Format "yyyyMMdd hh:mm:ss"
$dateAsSuffix = Get-Date -Format "yyyyMMddhhmmss"

$ListOfTablesTimeStamp = $KeyPath+'ListOfTablesTimeStamp.csv'

#add dbatools
 $Env:PSModulePath = $Env:PSModulePath+";G:\DBA\Scripts\dbatools"
  
 #created trusted connection
 Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

$logFile = $KeyPath+'SaveThenBleedOff.log'

$logsuccess = $KeyPath+'Restore'+$Database+'success.log'


$msg="Start " + $date 

$msg | Out-File -Append -FilePath $logFile


 try {
 ##execute the content of the file  $RestoreFile
 # get the tables to purge
  $MyServerInstance | Invoke-DbaQuery -Database $MyDB -Query 'SELECT DISTINCT OBJECT_NAME(object_id) FROM sys.columns WHERE name LIKE ''timestamp'' ORDER BY 1 '  | 
      export-csv -path $ListOfTablesTimeStamp -NoTypeInformation 
      
 # 
  Get-Content -Path $ListOfTablesTimeStamp | Select-Object -Skip 1 | ForEach-Object { 
   $destfile = $_ -replace '"', ''
   $aTable = $destfile 
   $destfile = $SavedDir+$destfile+'.rpt'
   
   
   
   #if file exists rename it
   if (Test-Path $destfile) {
	$dateAsSuffix = Get-Date -Format "yyyyMMddhhmmss"   
	$newName = $SavedDir+$aTable+'_'+$dateAsSuffix+'.rpt'
	   Rename-Item $destfile $newName
   }
   
    # save $DayToSave of the current to .rpt file
   $date + " saving " + $DayToSave +" days of "+ $aTable + " to " + $destfile + " file " | Out-File -Append -FilePath $logFile
   $myQuery = ' SELECT * FROM '+$aTable + ' where Timestamp < DATEADD(d,-' + $DayToSave +', getdate()) '    
   sqlcmd  -S aHostName\sqlexpress  -d $MyDB -U $Username -P $pass -Q $myQuery  >  $destfile

	# delete $DayToSave of the current to .rpt file 
	$date + " deleting all data but last " + $DayToSave +" days of data from "+ $aTable | Out-File -Append -FilePath $logFile
   $myQuery = 'SET QUOTED_IDENTIFIER ON; DELETE FROM '+$aTable + ' where Timestamp < DATEADD(d,-' + $DayToSave +', getdate()) '    
   sqlcmd  -S aHostName\sqlexpress  -d $MyDB -U $Username -P $pass  -Q $myQuery  >> $logFile

	#Delete space-wasting records sent by automated scripts: no longer valid
	#as APM_DynamicEvidence_DetailData & APM_DynamicEvidence_Detail don't exist anymore in aCompany DB

   #reorganize index on the the current table
   $date + " reorganizing indexes on " + $aTable | Out-File -Append -FilePath $logFile
   $myQuery = ' ALTER INDEX ALL ON '+$aTable + ' REORGANIZE ' 
   sqlcmd  -S aHostName\sqlexpress  -d $MyDB -U $Username -P $pass -Q $myQuery  >> $logFile
   
   
   if ($Error.Count -gt 0) {
    $errorMessage = "Error: $($_.Exception.Message)"
    $errorMessage | Out-File -Append -FilePath $logFile
   }

 }
  
     #shrink of some files set in shrinkdatabase.sql
   #$date + " shrink of  " | Out-File -Append -FilePath $logFile
   #sqlcmd  -S aHostName\sqlexpress  -d $MyDB -U $Username -P $pass -i $ShrinkSQL > $ShrinkFile
   #sqlcmd  -S aHostName\sqlexpress  -d $MyDB -U $Username -P $pass -i $ShrinkFile  >> $logFile
   #write-host $myQuery
   
   $MyDB, 'SolarWindsFlowStorage', 'SolarWindsOrionLog', 'aCompanyAdmin' | ForEach-Object {
        #Invoke-DbaQuery -SqlInstance $MyServerInstance -Database $_ -File $ShrinkSQL | Out-File -Append -FilePath $ShrinkFile 
        $MyServerInstance | Invoke-DbaQuery -Database $_ -File $ShrinkSQL | Out-File -FilePath $ShrinkFile$_
        #Get-Content -Path $ShrinkFile$_ | Add-Content -Path $ShrinkFile #-Value $content_temp
		$date + " shrink files in  " + $_ | Out-File -Append -FilePath $logFile
        $MyServerInstance | Invoke-DbaQuery -Database $_ -File $ShrinkFile$_  | out-file -append $logFile
         
   }
   
   #log table growth
   sqlcmd  -S aHostName\sqlexpress  -d $MyDB -U $Username -P $pass -i $TableGrowthSQL
   
   <#
   $result =  $MyServerInstance | Invoke-DbaQuery -Database $MyDB -File $ShrinkSQL  
   
   $MyServerInstance | Invoke-DbaQuery -Database $MyDB -File $ShrinkSQL | Out-File -FilePath $ShrinkFile 
   
   $content = Get-Content -Path $ShrinkFile

   $replacementString = ""
   $searchString = "Column"
   
    #replace every line having an instance
    $modifiedContent = $content | ForEach-Object {
        if ($_ -match $searchString) {
            $replacementText
        } else {
            $_
        }
    }

    # Write the modified content back to the file
    Set-Content -Path $ShrinkFile -Value $modifiedContent

    $MyServerInstance | Invoke-DbaQuery -Database $MyDB -File $ShrinkFile  | out-file -append $logFile   
	#>
	
 }
catch {
    # Catch any errors and write them to a file
    $errorMessage = "Error: $($_.Exception.Message)"
    $errorMessage | Out-File -Append -FilePath $logFile
     # Write the full error details to the transcript
    Write-Host "An error occurred: $($_.Exception.Message)"
    Write-Host "Error details: $($_ | Out-String)"

}


 Stop-Transcript
