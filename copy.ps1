#Get-ChildItem –Path "C:\Backups\back\" -Recurse -Filter *.txt |

#	Foreach-Object {

#		Copy-Item $_.FullName -Destination "C:\Backups\Destination\"

#	}

# $FullPath = $SourcePath + '\' + $filename

#Copy-Item -Path $FullPath -Destination "C:\Backups\Destination\" - Force
# !!!!************the path from management studio for xp_cmdshell will refer to SQL Instance
# https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-files-and-folders?view=powershell-7.2#copying-files-and-folders


 NET USE B: \\sharedfolder /u:domain\username password 
 
 $source = 'B:'
 #$destina = & 'G:\xfer\dbx Full\folder1'
 $destina = 'G:\'

 $myDate = Get-Date # Get-Date -format "yyyymmdd"

#be at the locaion of search
 cd B:
 cd $source
  
 #bak file create during last 6 days
 #get-childitem -Verbose -recurse -filter *tpcc_FULL*.bak | where LastWriteTime -gt ($myDate).Date.addDays(-6) |  % {$_.FullName}

 #bak file create during last 6 days
 get-childitem -recurse -filter *FULL*.bak | where LastWriteTime -gt ($myDate).Date.addDays(-6) |  
 ForEach-Object {
    Copy-item $_.FullName -Destination $destina
 }

# start-sleep -Seconds 5

#doing following to free the mapped drive so we can unlink it
cd g:
cd $destina

 NET USE B: /delete

 #exit
