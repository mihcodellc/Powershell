
#excute sql files in a folder
cd G:\test\segments\

Get-ChildItem -Path 'G:\test\segments\' -Recurse -Filter *.sql |

	Foreach-Object {

		Write-Output $_.Name | out-file -filepath  "c:\log.txt" -append -force
        Invoke-sqlcmd -ServerInstance 'stage-server' -Database 'MyDB' -InputFile $_.Name 

	}

 
#remove copy list
 cd G:\
  
 #bak file create during last 6 days
 #get-childitem -Verbose -recurse -filter *tpcc_FULL*.bak | where LastWriteTime -gt ($myDate).Date.addDays(-6) |  % {$_.FullName}

 get-childitem -recurse -filter *.trn |  
 ForEach-Object {
    #Copy-item 
    write-host $_.FullName
    #Remove-Item $_.FullName 
 }
