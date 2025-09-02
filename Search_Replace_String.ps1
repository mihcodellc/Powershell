# Read the contents of a text file
#$filePath = "S:\DBA\Maintenance\RestoreMedRxsuccess.log"
$filePath = "G:\testBello.log"
$content = Get-Content -Path $filePath


# Search for a specific string in the file
#$searchString = "RESTORE DATABASE successfully processed"
$searchString = "Bello"
#$matches = Select-String -Path $filePath -Pattern $searchString

# Use Select-String to find the whole line containing the search string
$matches = Select-String -Path $filePath -Pattern $searchString



$linefOund=""

#finf one instance and exit
$content | ForEach-Object {
    if ($_ -match $searchString) {
        $linefOund = $_
        #write-host $linefOund
        #break
    }
}

write-host $linefOund + " hi here"

# Output the matching lines
foreach ($match in $matches) {
    Write-Output $match.Line
}

if ($matches.Length -gt 0)
{
    Write-Host "lenght: "$matches.Length
}



#count instances
$fileCount = 0
foreach ($line in $content) {
    $fileCount += ($line -split $searchString).Count - 1
}
write-host "I found " $fileCount " instances of " $searchString

#replace the searchString
# Replace the specific text
$replacementString = ""

if ($fileCount -gt 0)
{

    #replace every instance
    $modifiedContent = $content -replace $searchString, $replacementString
    # OR
    # replace every line with an instance
    # Iterate over each line and replace the line if it contains the search string
    <#  #comment a block
    $modifiedContent = $content | ForEach-Object {
        if ($_ -match $searchString) {
            $replacementText
        } else {
            $_
        }
    }
    #>




    # Write the modified content back to the file
    # $modifiedContent | Set-Content -Path $filePath
    # OR
    Set-Content -Path $filePath -Value $modifiedContent

    # Write the new content back to the file
    #$modifiedContent | Set-Content -Path $filePath
}
