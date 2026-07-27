##load to chatGPT if can't make sense of it

# https://www.mssqltips.com/sqlservertip/5114/sql-server-performance-troubleshooting-system-health-checklist/

# guidelines for Expert combined to microsoft docs but track your own environment

| Performance Counter        | Good                        | Warning      | Critical         |
| -------------------------- | --------------------------- | ------------ | ---------------- |
| CPU % Processor Time       | < 70% average               | 70–85%       | > 85% sustained  |
| Available Memory           | > 20% free RAM              | 10–20%       | < 10%            |
| Page Life Expectancy (PLE) | Stable/high                 | Sudden drops | Persistently low |
| Buffer Cache Hit Ratio     | > 95%                       | 90–95%       | < 90%            |
| SQL Compilations/sec       | < 10% of Batch Requests/sec | Higher       | Very high        |
| Batch Requests/sec         | Workload-dependent          | —            | —                |
| Avg. Disk sec/Read         | < 10 ms                     | 10–20 ms     | > 20 ms          |
| Avg. Disk sec/Write        | < 10 ms                     | 10–20 ms     | > 20 ms          |
| Disk Queue Length          | < number of spindles        | Moderate     | Sustained high   |
| Processor Queue Length     | < 2 per logical CPU         | Moderate     | Sustained high   |
| SQL Lock Waits/sec         | Near zero                   | Increasing   | Sustained high   |

# log with log_instance_perf.ps1

write-host "**************CPU************"
Get-Counter '\Processor(*)\% Processor Time'


write-host "**************Memory************"

 Get-Counter '\Memory\Available MBytes'
 Get-Counter '\Memory\Page Faults/sec'
 Get-Counter '\Paging File(_Total)\% Usage'
 
 
 write-host "**************IO************"
Get-Counter '\PhysicalDisk(*)\Current Disk Queue Length'

Get-Counter '\PhysicalDisk(*)\Disk Reads/sec'

Get-Counter '\PhysicalDisk(*)\Disk Writes/sec'

Get-Counter '\PhysicalDisk(*)\Avg. Disk sec/Read'

Get-Counter '\PhysicalDisk(*)\Avg. Disk sec/Write'


 write-host "**************Network************"
 
 Get-Counter '\Network Interface(*)\Bytes Sent/sec'

 Get-Counter '\Network Interface(*)\Bytes Received/sec'
 
 
  write-host "**************Server************"
Get-Counter '\SQLServer:Buffer Manager\Buffer cache hit ratio'

Get-Counter '\SQLServer:Buffer Manager\Page Life Expectancy'

Get-Counter '\SQLServer:SQL Statistics\Batch Requests/sec'

Get-Counter '\SQLServer:SQL Statistics\SQL Compilations/sec'
