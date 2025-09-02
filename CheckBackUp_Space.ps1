#created by Monktar Bello 3/19/2024

#https://www.sharepointdiary.com/2020/01/read-write-encrypted-password-file-in-powershell-script.html#:~:text=How%20to%20use%20an%20Encrypted%20Password%20File%20to,from%20the%20file%20and%20use%20it%20in%20scripts.
#store password encrypted in file
$KeyPath = 'script folder'

$Username = 'asuser'

$CredFile = $KeyPath+'auser.cred'

$DriveLetter = "O:"

$SharePath   = "bachup folder shared"

$SharePath2   = "another backup folder shared"

$SubFolder   = "sqlprimary"

$db1path = "???" # build on $DriveLetter
$db2path = "???" # build on $DriveLetter
$db3path = "???" # build on $DriveLetter

$host2 = "***********************Name of Host****************************************"


$lastfull = 7
$lastdiff = 1

#Get encrypted password from the file
$SecureString = Get-Content $CredFile | ConvertTo-SecureString # Unlike a secure string, an encrypted standard string can be saved in a file for later use
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString


# Retrieve the NetworkCredential object from the PSCredential object
$networkCredential = $Credential.GetNetworkCredential()

#Get encrypted password from the file
$pass = $networkCredential.Password


$date = Get-Date
$dateYesterday = $date.Date.AddDays(-1)
$date



#mount the shared drive
#New-PSDrive -Name "O" -PSProvider "FileSystem" -Root $SharePath -Credential $Credential -Scope Global #-persist to make available for other process
NET USE $DriveLetter $SharePath /u:$Username $pass
 

#list diff file
write-host 'list diff files ***************'
get-childitem -path (Join-Path $DriveLetter $SubFolder) *diff*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastdiff) | sort-object name -descending |
select-object Name, 
@{Name = 'FileSizeInMB'; Expression = {($_.Length / 1024/1024).ToString("#.##")}} , 
lastwritetime | Format-Table


# list Full files
write-host 'list Full files***************'
get-childitem -path (Join-Path $DriveLetter $SubFolder) *FULL*_16.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastfull) | sort-object name -descending |
select-object Name, 
@{Name = 'FileSizeInGB'; Expression = {($_.Length / 1024/1024/1024).ToString("#.##")}} , 
lastwritetime | Format-Table

# # get the total size
# $diff_size = ((get-childitem -path O:\sqlprimary *diff*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastdiff) |
# Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##")

# $full_size = ((get-childitem -path O:\sqlprimary *FULL*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastfull) |
# Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##") 

# write-host "Last Full: $full_size GB`nLast Diff: $diff_size GB "

# write-host "****************************"

write-host "************!!!for each db, estimate full/diff so that we can compare on source and destination!!!************"

$db1path, $db2path, $db3path | ForEach-Object {
	
	$current_dir = $_
	
# get the total size
$diff_size = ((get-childitem -path $current_dir *diff*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastdiff) |
Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##")

$full_size = ((get-childitem -path $current_dir *FULL*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastfull) |
Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##") 

write-host "$current_dir : Last Full: $full_size GB *** Last Diff: $diff_size GB "

write-host "****************************"
}



#disk space
$AvailableFreeSpace = (([System.IO.DriveInfo]::GetDrives() | where name -eq 'O:\').AvailableFreeSpace/1024/1024/1024).ToString("#####.##")
$TotalSize = (([System.IO.DriveInfo]::GetDrives() | where name -eq 'O:\').TotalSize/1024/1024/1024).ToString("#####.##")


write-host "Disk Info "$DriveLetter"\********`nFree**: $AvailableFreeSpace GB on Total Size**: $TotalSize GB `n"



NET USE $DriveLetter /delete
#Remove-PSDrive -Name O -Force



write-host $host2
write-host $host2
write-host $host2


NET USE $DriveLetter $SharePath2 
 

"O:\" | ForEach-Object {
	
	$current_dir = $_
	
# get the total size
$diff_size = ((get-childitem -path $current_dir *diff*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastdiff) |
Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##")

$full_size = ((get-childitem -path $current_dir *FULL*.bak -recurse | where-object lastwritetime -gt $date.AddDays(-$lastfull) |
Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##") 

$log_size = ((get-childitem -path $current_dir *.trn -recurse | where-object lastwritetime -gt $date.AddDays(-$lastfull) |
Measure-Object -Property Length -Sum).Sum/ 1024/1024/1024).ToString("#####.##")

write-host "$current_dir : Last Full: $full_size GB *** Last Diff: $diff_size GB *** Log size: $log_size GB"

write-host "****************************"
}

#disk space
$AvailableFreeSpace = (([System.IO.DriveInfo]::GetDrives() | where name -eq 'O:\').AvailableFreeSpace/1024/1024/1024).ToString("#####.##")
$TotalSize = (([System.IO.DriveInfo]::GetDrives() | where name -eq 'O:\').TotalSize/1024/1024/1024).ToString("#####.##")


write-host "Disk Info "$DriveLetter"\********`nFree**: $AvailableFreeSpace GB on Total Size**: $TotalSize GB `n"




NET USE $DriveLetter /delete
#Remove-PSDrive -Name O -Force

