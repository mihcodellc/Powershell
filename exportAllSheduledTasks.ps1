#https://powershelladministrator.com/2017/06/27/exporting-all-scheduled-tasks/
$LogFile = "D:\Data\Logging\ExportScheduledTasks.log"
$BackupPath = "D:\Data\Tasks"
$TaskFolders = (Get-ScheduledTask).TaskPath | Where { ($_ -notmatch "Microsoft") -and ($_ -notmatch "OfficeSoftware") } | Select -Unique
Start-Transcript -Path $LogFile
Write-Output "Start exporting of scheduled tasks."

If(Test-Path -Path $BackupPath)
{
Remove-Item -Path $BackupPath -Recurse -Force
}
md $BackupPath | Out-Null

Foreach ($TaskFolder in $TaskFolders)
{
Write-Output "Task folder: $TaskFolder"
If($TaskFolder -ne "\") { md $BackupPath$TaskFolder | Out-Null }
$Tasks = Get-ScheduledTask -TaskPath $TaskFolder -ErrorAction SilentlyContinue
Foreach ($Task in $Tasks)
{
$TaskName = $Task.TaskName
If(($TaskName -match "User_Feed_Synchronization") -or ($TaskName -match "Optimize Start Menu Cache Files"))
{
}
Else
{
$TaskInfo = Export-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder
$TaskInfo | Out-File "$BackupPath$TaskFolder$TaskName.xml"
Write-Output "Saved file $BackupPath$TaskFolder$TaskName.xml"
}
}
}

Write-Output "Exporting of scheduled tasks finished."
Stop-Transcript