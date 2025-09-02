$root = '\\Aserver-sql-logship\xfer\'

cd $root

$when = Get-Date -format "yyyyMMdd"
$date = get-date

#make the filename with date part
$filename = 'ReadyForCopy' + $when + '.txt'

#create the file and write date time in it
New-Item $filename -ItemType File -force
add-content -Path .\$filename -Value $date

#$fullpath =$root + $filename


#$fileExist = Test-Path -Path $fullpath -PathType Leaf

#	if ($fileExist)
#	{
#		write-host "I found it"
#	}


# Specify the path to the file
$file = "C:\path\to\your\file.txt"

# Check if the file exists
if (Test-Path $file) {
    # File exists, so delete it
    Remove-Item $file
    Write-Host "File deleted: $file"
} else {
    Write-Host "File does not exist: $file"
}


