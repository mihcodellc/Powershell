Param(
  [string]$Path = './app',
  [string]$DestinationPath = './',
  [string]$backUpName = 'bakDotFile'
)
$date = Get-Date -format "yyyyMMddhhmmss"

$KeyPath = 'D:\DBA\maintenance\'
$logsuccess = $KeyPath+'Restore'+$Database+'success.log'

#clear any previous so we can address new error
$Error.Clear()
# BEGIN start-transcript 
# good thing about it: everything msg and errors go the specify file
Start-Transcript -Path $logsuccess 

#try{

   	$ServerName | Invoke-DbaQuery -File $RestoreFile -sqlCredential $Credential -verbose 
  	# Check for errors
  	# it didn't execute the remaining script when enter in "Start-Transcript"
	if ($Error.Count -gt 0) {
    		Write-Output "An error occurred during execution."
      		#send an email for instance
	}

   
 	Compress-Archive -Path $Path -CompressionLevel 'Fastest' -DestinationPath "$($DestinationPath + $backUpName + '-' + $date)"
	#make sure the file has been created
	$fileExist = Test-Path "$( $DestinationPath + $backUpName + '-' + $date).zip"
	if ($fileExist)
	{
		Write-Host "Created backup at $( $DestinationPath + $backUpName + '-' + $date).zip"
	}
	if (-Not $fileExist) {
		#the error look like powershell error
		##Throw or write-error
		write-error "Error: backup $($backUpName + '-' + $date).zip at $DestinationPath Failed"
	}



	#check 
	$age = read-host "Enter your age:" 	
	$name = read-host "Enter your name:" 

	#age compare
	if ($age -le 21){
		write-host "Too young. Have fun in real life." 
	}
	elseif ($age -gt 80){
		write-host "Too old. Your grand children need you dear elder."
	}
	else{
		write-host "Welcome Stranger"																																																																																																																																																														   
	}																																																																																																																																																															   

	#name compare
	if ($name -notlike 'Monktar'){
		write-host "Unfortunately, you are not expect here." 
		write-host $True
	}
	elseif ($name -match 'Monktar'){
		write-host "Welcome dear lovely Spouse Bello!!!"
		write-host $False
	}
#} catch { # catch [System.IO.IOException] will catch only this type of exception. the current used catch all
    #	write-host "something went wrong. Please contact the developer."
    #Everything you wanted to know about exceptions
    #https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.3
    # one way to write
    # Write-Output "Could not find" 2>&1 >> .\belloerror.log
    # one way to write
    "One", "Two", "Three", "Four" | Set-Content -Path G:\DBA\belloerror.log;
    #essential
    Write-Output "Ran into an issue: $($PSItem.ToString())" >> .\belloerror.log
    #additional
    $PSItem.InvocationInfo | Format-List MyCommand, ScriptLineNumber >> .\belloerror.log # or use * after format-list
#} Finally {
#	write-output "Bye!!!"
#}

Stop-Transcript
# END start transcript


##short version and easy read
# start transcript > try check error > catch > Finally > end transcript
function Stop-ExistingTranscript {
    try {
        # Attempt to stop any existing transcript
        Stop-Transcript -ErrorAction Stop
    } catch {
        # If there's an error, it likely means no transcript is currently running
        Write-Host "No existing transcript to stop."
    }
}

# Call the function to stop any existing transcript
Stop-ExistingTranscript

Start-Transcript -Path $logsuccess 
$Error.Clear()

 try {
	#your commands 
	 if ($Error.Count -gt 0) {
	    $errorMessage = "Error: $($_.Exception.Message)"
	    $errorMessage | Out-File -Append -FilePath $logFile
	   }
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
 
