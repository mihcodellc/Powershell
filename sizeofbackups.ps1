#created by Monktar Bello 12/03/2024

#https://www.sharepointdiary.com/2020/01/read-write-encrypted-password-file-in-powershell-script.html#:~:text=How%20to%20use%20an%20Encrypted%20Password%20File%20to,from%20the%20file%20and%20use%20it%20in%20scripts.
#store password encrypted in file
$KeyPath = 'G:\DBA\powershell\'

$Username = 'ACompany-AHost\sqlLoginAdmin'

$CredFile = $KeyPath+'sqlLoginAdmin.cred'

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

$lastfull = 7
$lastdiff = 1

#mount the shared drive
#New-PSDrive -Name "O" -PSProvider "FileSystem" -Root "\\sql-backups.ACompany-AHost.com\backup" -Credential $Credential -Scope Global #-persist to make available for other process
NET USE O: \\sql-backups.ACompany-AHost.com\backup /u:$Username $pass
 


write-host "****************************"

#disk space
$AvailableFreeSpace = (([System.IO.DriveInfo]::GetDrives() | where name -eq 'O:\').AvailableFreeSpace/1024/1024/1024).ToString("#####.##")
$TotalSize = (([System.IO.DriveInfo]::GetDrives() | where name -eq 'O:\').TotalSize/1024/1024/1024).ToString("#####.##")


write-host "Short term server sql-backups   Info********`nFree**: $AvailableFreeSpace GB on Total Size**: $TotalSize GB `n"


write-host "*****************Current - Size per server, database on short term server ***************** `n"
"O:\sqlprimary\AHost-SQL", "O:\sqlprimary\STAGE-SQL", "O:\sqlprimary\AHost-SQL002" | ForEach-Object {

	$current_dir = $_
	
# Calculate total size of all files in the directory (including subdirectories)
$totalSize = (Get-ChildItem -Path $current_dir -Recurse -File | Measure-Object -Property Length -Sum).Sum

# Convert to MB and display the total size
Write-Output ("Total size of '{0}' is {1:N2} MB `n" -f $current_dir, ($totalSize / 1MB))
}



write-host "*****************Last week - Size per server, database on short term server ***************** `n"
"O:\sqlprimary\AHost-SQL", "O:\sqlprimary\STAGE-SQL", "O:\sqlprimary\AHost-SQL002" | ForEach-Object {

	$current_dir = $_
	
# Calculate total size of all files in the directory (including subdirectories)
$totalSize = (Get-ChildItem -Path $current_dir -Recurse -File | where-object lastwritetime -gt $date.AddDays(-7) | Measure-Object -Property Length -Sum).Sum

# Convert to MB and display the total size
Write-Output ("Total size of '{0}' is {1:N2} MB" -f $current_dir, ($totalSize / 1MB))
}

"O:\sqlprimary\AHost-SQL", "O:\sqlprimary\STAGE-SQL", "O:\sqlprimary\AHost-SQL002" | ForEach-Object {

	$current_dir = $_
	
Get-ChildItem -Path $current_dir -Directory | ForEach-Object {
    $folderPath = $_.FullName
    $folderSize = (Get-ChildItem -Path $folderPath -Recurse -File | where-object lastwritetime -gt $date.AddDays(-7) | Measure-Object -Property Length -Sum).Sum
    [PSCustomObject]@{
        FolderName = $_.Name
        FolderPath = $folderPath
        SizeMB     = "{0:N2}" -f ($folderSize / 1MB)  # Convert size to MB
    }
} | Sort-Object SizeMB -Descending | Format-Table -AutoSize




}





NET USE O: /delete
#Remove-PSDrive -Name O -Force


