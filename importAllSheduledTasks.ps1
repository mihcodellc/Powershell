# https://stackoverflow.com/questions/29978102/importing-scheduled-tasks-with-powershell-in-windows-2012-r2
$task_user="username"
$task_pass="password"
$schedule=new-object -ComObject ("Schedule.Service")
$schedule.Connect("server")
$folder=$schedule.GetFolder("\tasks")
$path="\\server\c$\temp\Tasks\"
Get-ChildItem $path -Filter "*.xml"| foreach {
$task_conf=Get-Item -Path $_.FullName
$taskname=$task_conf.Name
$task_xml=$task_conf.FullName
$task=$schedule.NewTask(0)
$task.XmlText=(Get-Content $task_xml).Replace('Task version="1.1" xmlns','Task version="1.2" xmlns')
$folder.RegisterTaskDefinition($taskname,$task,6,$task_user,$task_pass,1,$null)
} 