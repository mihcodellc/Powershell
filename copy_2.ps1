 
 $source = 'X:\'
 $destina = 'G:\'

 #$myDate = Get-Date # Get-Date -format "yyyymmdd"
 $myDate = Get-Date -format "yyyymmdd_hhmmss"
 
 $log_msg = "G:\error_CopyBetweenDrive"+$myDate+".txt"
 
 
 # Ensure destination and log folder exist
if (-not (Test-Path $destina)) { New-Item -Path $destina -ItemType Directory -Force | Out-Null }
  

 #bak file create during last 4 days
 $files = Get-ChildItem -Path $source -Recurse -Filter "*FULL*.bak" |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-4) } # | ForEach-Object { Copy-item $_.FullName -Destination $destina }
	
 if ($files.Count -eq 0) {
    Write-Host "No matching files found in $source. Nothing to copy."
}
else {
	 "found for copy." | Out-File $log_msg
	 
 foreach ($file in $files) {
        $destFile = Join-Path $destina $file.Name
		Write-Host $destFile
		
	
		# Copy file
        Copy-Item -Path $file.FullName -Destination $destFile -Force
		#compare file
		$srcSize  = (Get-Item $file.FullName).Length
        $dstSize  = (Get-Item $destFile).Length
		

		if ($srcSize -eq $dstSize) {
					"Copied successfully: "+$file.Name+" deleting source." | Out-File  -append $log_msg
					Remove-Item -Path $file.FullName -Force
				}		
		 else {
			$file.Name+" did not copy correctly. Skipping delete." | Out-File  -append $log_msg
			
        }		 
 
  }

}
 #exit
 
 
 
