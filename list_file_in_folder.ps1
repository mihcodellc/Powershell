 #copy file create during last $numdays days
 get-childitem "G:\xfer\MyDB\LOG" | Sort-Object LastWriteTime | #where LastWriteTime -gt ($myDate).Date.addDays($numdays) |  
 #get-childitem -recurse -filter $search | where CreationTime.Date -gt ($myDate).Date.addDays($numdays) |  
 ForEach-Object {
    Write-Host "RESTORE LOG MyDB FROM DISK = '$($_.FullName)' WITH NORECOVERY"
    #Copy-item $_.FullName -Destination $destina -force
	# Log the progress to a file
	#"$_.FullName copied" | Out-File -Append -FilePath $logFile
 }
