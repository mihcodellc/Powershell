# DBSUPPORT-5648
# "Elastic_cube_check_2.ps1": check if failed, build it; if a dashboard passes a threshold of days or minutes (based on its schedule on sisense), it builds it
# only between $startTime am and $endTime pm
# source: "C:\DBA\Scripts\Elastic_cube_check_2.ps1"
#create 9/15/2026 by Monktar Bello
# run example: .\Elastic_cube_check_2.ps1 "MEDRX CashARC Deposit_Receipt_ReceiptDetail - PROD" "CashARC Zeropay Receipt Remittance"
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Cube1,

    [int]$days_old = 2,
	[int]$Minutes_old = 140 # shoulb rebuild every 2 hours, wait 2hours 20min then rebuild
)


#

$startTime = [TimeSpan]::FromHours(11)
$endTime   = [TimeSpan]::FromHours(20)

$now = Get-Date

if ($now.TimeOfDay -lt $startTime -or $now.TimeOfDay -ge $endTime) {
    Write-Host "Elastic_cube_check_2 is allowed between $startTime AM and $endTime PM. Exiting."
    exit
}



# Access Sisense Prism folder
Set-Location "C:\Program Files\Sisense\Prism"

# Build list of cubes
$cubes = @($Cube1)


foreach ($cubeName in $cubes) {

    Write-Host ""
    Write-Host "=============================================="
    Write-Host "Checking cube: $cubeName"
    Write-Host "=============================================="

    # Get cube information
    $info = .\psm ecube info name="$cubeName" 2>&1

    # Get LastBuildSucceeded
    $lastBuildSucceededText = $info |
        Select-String "LastBuildSucceeded:" |
        ForEach-Object {
            ($_ -split ":", 2)[1].Trim()
        }

    # Get LastFullBuildTime
    $lastFullBuildTimeText = $info |
        Select-String "LastFullBuildTime:" |
        ForEach-Object {
            ($_ -split ":", 2)[1].Trim()
        }

    # Validate information was returned
    if (-not $lastBuildSucceededText -or -not $lastFullBuildTimeText) {
        Write-Host "Unable to retrieve build i$difference_days -lt $days_oldnformation for: $cubeName"
        continue
    }

    $lastBuildSucceeded = [bool]::Parse($lastBuildSucceededText)
    $lastFullBuildTime = [datetime]::Parse($lastFullBuildTimeText)

    # Calculate age of last full build
    $difference_days = ((Get-Date) - $lastFullBuildTime).TotalDays
	$difference_Minutes = ((Get-Date) - $lastFullBuildTime).TotalMinutes

    Write-Host "LastBuildSucceeded : $lastBuildSucceeded"
    Write-Host "LastFullBuildTime  : $lastFullBuildTime"
    Write-Host "Difference days    : $([math]::Round($difference_days, 2))"
	Write-Host "Days old threshold : $days_old"
	Write-Host "Difference Minutes    : $([math]::Round($difference_Minutes, 2))"    
	Write-Host "Minutes old threshold : $Minutes_old"

    # Build if:
    # 1. Last build failed
    # OR
    # 2. Build is more than 1 day old AND less than days_old
	# OR
	# 3. it has been Minutes_old scince the last success Build  
    if (
        (-not $lastBuildSucceeded) -or
        (
            $difference_days -lt $days_old -and
            $difference_days -gt 1 -and
            $lastBuildSucceeded
        ) -or
		( $Minutes_old -lt $difference_Minutes -and $lastBuildSucceeded )
    ) {

        Write-Host ""
        Write-Host "BUILD REQUIRED: $cubeName"

        .\psm ecube build name="$cubeName" mode=restart serverAddress=localhost

    }
    else {

        Write-Host ""
        Write-Host "No build required: $cubeName"
		#.\psm ecube info name="$cubeName"
    }
}


# return to scripts folder
Set-Location "C:\DBA\Scripts"

