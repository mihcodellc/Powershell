$Server = "localhost"
$Database = "DBA"

$Counters = @(
    '\Processor(*)\% Processor Time',

    '\Memory\Available MBytes',
    '\Memory\Page Faults/sec',
    '\Paging File(_Total)\% Usage',

    '\PhysicalDisk(*)\Current Disk Queue Length',
    '\PhysicalDisk(*)\Disk Reads/sec',
    '\PhysicalDisk(*)\Disk Writes/sec',
    '\PhysicalDisk(*)\Avg. Disk sec/Read',
    '\PhysicalDisk(*)\Avg. Disk sec/Write',

    '\Network Interface(*)\Bytes Sent/sec',
    '\Network Interface(*)\Bytes Received/sec',

    '\SQLServer:Buffer Manager\Buffer cache hit ratio',
    '\SQLServer:Buffer Manager\Page Life Expectancy',

    '\SQLServer:SQL Statistics\Batch Requests/sec',
    '\SQLServer:SQL Statistics\SQL Compilations/sec'
)

$Connection = New-Object System.Data.SqlClient.SqlConnection
$Connection.ConnectionString = "Server=$Server;Database=$Database;Integrated Security=True;"
$Connection.Open()

foreach ($Counter in $Counters)
{
    Write-Host "Collecting $Counter"

    $Result = Get-Counter $Counter

    foreach ($Sample in $Result.CounterSamples)
    {
        $Cmd = $Connection.CreateCommand()

        $Cmd.CommandText = @"
INSERT INTO dbo.PerformanceCounters
(
    ComputerName,
    ObjectName,
    CounterName,
    CounterValue
)
VALUES
(
    @ComputerName,
    @ObjectName,
    @CounterName,
    @CounterValue
)
"@

        
        $null = $Cmd.Parameters.Add("@ComputerName",[System.Data.SqlDbType]::NVarChar,128)
        $null = $Cmd.Parameters.Add("@ObjectName",[System.Data.SqlDbType]::NVarChar,128)
        $null = $Cmd.Parameters.Add("@CounterName",[System.Data.SqlDbType]::NVarChar,128)
        $null = $Cmd.Parameters.Add("@CounterValue",[System.Data.SqlDbType]::Float)

        
        $Cmd.Parameters["@ComputerName"].Value = $env:COMPUTERNAME
        $Cmd.Parameters["@ObjectName"].Value = $Sample.Path.Split('\')[2].Split('(')[0]
        $Cmd.Parameters["@CounterName"].Value = $Sample.Path.Split('\')[-1]
        $Cmd.Parameters["@CounterValue"].Value = [double]$Sample.CookedValue

        $Cmd.ExecuteNonQuery() | Out-Null
    }
}

$Connection.Close()

Write-Host ""
Write-Host "Performance counters successfully saved."