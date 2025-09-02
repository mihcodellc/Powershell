the process of copy and restore has

1. a script to copy from short-backup server to current test server: GetBackUpsRestorePerDB.ps1
2. a script to restore a DB from the files copied with the previous script: RestoreBackUpFromDirectory.ps1
3. a script as entry point for the 2 previous scripts; it loops through specified databases: CopyDBs_selected_Restore.ps1

scripts 1,2 are using a credential encrypted in a file: 'alogin.cred' : Encrypt_Credential.ps1
an OS task has been created to run the entry point every sunday at 12:03 PM: DBA_CopyAndRestore

# several  calls of GetBackUpsRestorePerDB ie one by line for each dbs didn't work
#1#.\GetBackUpsRestorePerDB.ps1 B:\sqlprimary\pathMain\db1 \\sql-path\xfer\db1 FULL db1 No
#2#.\GetBackUpsRestorePerDB.ps1 B:\sqlprimary\pathMain\db2 \\sql-path\xfer\db2 FULL db2 Yes


# $_ is the varaible holding a DB name at a time
'db1', 'db2', 'db3' | ForEach-Object {  
   powershell.exe -File "D:\DBA\Maintenance\GetBackUpsRestorePerDB.ps1" B:\Rep1\Rep2\$_  \\sql-path\xfer\$_ FULL $_ Yes  AnInstanceName
 }

# same as above. diff are the loop and database variable
#$Db = 'db1', 'db2', 'db3'
#foreach ($s in $Db) {
#    Write-Host 'Start DB copy...'  $s
#    .\GetBackUpsRestorePerDB.ps1 B:\Rep1\Rep2\$s \\sql-path\xfer\$s FULL $s  Yes 	
#}
