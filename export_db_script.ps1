
# https://docs.dbatools.io/Export-DbaScript
# https://docs.dbatools.io/New-DbaScriptingOption 
# # all Microsoft.SqlServer.Management.Smo.ScriptingOptions 
# https://learn.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.scriptingoptions?redirectedfrom=MSDN&view=sql-smo-160

#Note: don't split the 3rd line
#create export file for each options then compare. ScriptForCreateDrop only script Create in my environment
#connection's credentials are omited because the account running this is sysadmin in sql server
#Name all procedures separated by comma
#did get dupes from the script generated. the errors receive when run make sense.

# $options = New-DbaScriptingOption
# $options.ScriptDrops = $true
# #without $options # Get-DbaDbStoredProcedure -SqlInstance instanceName -Database DbName -Name <list all SPs with comma as seperator> | Export-DbaScript -FilePath G:\export.sql -Append
# #with $options #Get-DbaDbStoredProcedure -SqlInstance instanceName -Database DbName -Name <list all SPs with comma as seperator> | | Export-DbaScript -ScriptingOptionsObject $options -FilePath G:\export_drop.sql -Append

$options = New-DbaScriptingOption
$options.ScriptDrops = $true
Get-DbaDbStoredProcedure -SqlInstance MyInstance -Database MIHDB -Name sp1,sp2,.. | Export-DbaScript -ScriptingOptionsObject $options -FilePath G:\export_drop.sql -Append


# $options = New-DbaScriptingOption
# $options.ScriptForAlter = $true
# Get-DbaDbStoredProcedure -SqlInstance MyInstance -Database MIHDB -Name sp1,sp2,.. | Export-DbaScript -ScriptingOptionsObject $options -FilePath G:\export_alter.sql -Append


$options = New-DbaScriptingOption
$options.ScriptForCreateDrop = $true
Get-DbaDbStoredProcedure -SqlInstance MyInstance -Database MIHDB -Name sp1,sp2,.. | Export-DbaScript -ScriptingOptionsObject $options -FilePath G:\export_DropCreate.sql -Append

#replace mbello with the DBA login
$cred = Get-Credential mih\mbello
 
#Copy databases not in log shipping ie Maintenance, AcompanyAdmin  
# need domain user running sql engine, sqlagent - the sharedPath is used to backup then from there restore
# thus the use of the list of databases in the following command. ReportServer, ReportServerTempDB are not copied by "Copy-DbaDatabase"
Copy-DbaDatabase -Verbose -Source instance2 -SourceSqlCredential $cred  -Destination instance1 -DestinationSqlCredential $cred -Database  db1, db2 -backupRestore -SharedPath \\instance1\xfer  | out-file -FilePath C:\Users\mbello\Documents\copylogDatabases.txt
 
 
# migrate everything included Linked Servers except Databases, Logins, Jobs, user objects in systems databases, linked servers
#using this command, if some jobs to be copied are not excluded, unesessary jobs are created.
Start-DbaMigration -Verbose -Source instance2  -SourceSqlCredential $cred -Destination instance1  -DestinationSqlCredential $cred -Exclude Databases, Logins, AgentServer, SysDbUserObjects, LinkedServers  | out-file -FilePath C:\Users\mbello\Documents\copylogConfig.txt
 
# copy any new linked server, the active ones have been copied over
Copy-DbaLinkedServer -Source instance2 -Destination instance2-logship, instance1 -LinkedServer <NEW_LINKED_SERVER>
 
#copy logins: existing ones are drop and recreate
Copy-DbaLogin -Verbose -Source instance2 -SourceSqlCredential $cred  -Destination instance1 -DestinationSqlCredential $cred -Force | out-file -FilePath C:\Users\mbello\Documents\copylogLogin.txt
 
#existing jobs are drop and recreate
Copy-DbaAgentJob -Verbose -Source instance2 -SourceSqlCredential $cred  -Destination instance1 -DestinationSqlCredential $cred -Force | out-file -FilePath C:\Users\mbello\Documents\copylogJob.txt
  
#operator: skip if exists
Copy-DbaAgentOperator -Source instance2 -Destination instance1
 
#alerts: skip if exists
Copy-DbaAgentAlert -Source instance2 -Destination instance1

#user permission
#Get-DbaUserPermission -SqlInstance MSQLDB-DEV | Where-Object Member -eq 'mbello' | select-object Object, Type,Permission, State, Member | export-csv -path 'g:\UserPriv.csv'

#denied permission
#Get-DbaUserPermission -SqlInstance MSQLDB-DEV | Where-Object State -eq 'DENY' | export-csv -path 'g:\UserPriv.csv'

#user permission on DB
Get-DbaUserPermission -SqlInstance instance1 -Database db1 | Where-Object Member -eq 'mbello' | select-object Object, Type,Permission, State, Member | export-csv -path 'g:\UserPriv.csv'

