 # foreach ($f in Get-Service -Name 'MSSQLSERVER', 'SQLSERVERAGENT') {
    # Stop-Service -force $f -ErrorAction SilentlyContinue
# }

 # Start-Sleep -Seconds 10

 # foreach ($f in Get-Service -Name 'MSSQLSERVER', 'SQLSERVERAGENT') {
    # Start-Service $f
# }

# get SQL Server services' name
$f = Get-Service -Name 'MSSQLSERVER', 'SQLSERVERAGENT'
# Stop SQL Server services
foreach ($s in $f) {
    Write-Host 'Stopping service ...'  $s
    Stop-Service -force $f -ErrorAction SilentlyContinue
}
## Wait for services to start
Start-Sleep -Seconds 10

# Start SQL Server services
foreach ($s in $f) {
    Write-Host 'Starting service ...'  $s
    Start-Service $f
}
# get the services
Get-Service -Name 'MSSQLSERVER', 'SQLSERVERAGENT'


## **** ForEach-Object VS foreach ****
# $_ is the varaible holding a DB name at a time
'db1', 'db2', 'db3' | ForEach-Object {  
   powershell.exe -File "D:\DBA\Maintenance\GetBackUpsRestorePerDB.ps1" B:\Rep1\Rep2\$_  \\sql-path\xfer\$_ FULL $_ Yes
 }
