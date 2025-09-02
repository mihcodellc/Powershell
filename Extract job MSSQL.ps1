[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null
$serverInstance = "Instance Name"
 
$server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $serverInstance
 
$jobs = $server.JobServer.Jobs 

$myDate = (Get-Date -format "yyyymmdd").ToString() 

#convert to char
#$val= [char]"1"
#Write-Host $val
 
if ($jobs -ne $null)
{
 foreach ($i in $jobs)
{
$jobName = $i.Name
$jobName = $jobName.Replace(":", "-")
$jobName = $jobName.Replace(" ", "_")
 
$FileName = "G:\MSSQL\Backup\DR\Jobs\JOB_" + $jobName + "_" + $myDate + ".sql"
Set-Location c:
$i.Script() | Out-File -filepath $FileName
}
}
