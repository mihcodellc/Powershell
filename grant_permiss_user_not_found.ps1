#author: Monktar Bello 11/10/2023

# grant permission when user ca't be found on GUI with 
## option 1:  Set-Acl 

$mypath = "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL"

$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList @('MSSQL$SQLEXPRESS'), "FullControl", "Allow"

$NewAcl = Get-Acl -Path $mypath

$NewAcl.SetAccessRule($fileSystemAccessRule)

Set-Acl -Path $mypath -AclObject $NewAcl

##option 2: icacls
$username = @('MSSQL$SQLEXPRESS')

icacls 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL' /grant "$($username):(OI)(CI)F"
