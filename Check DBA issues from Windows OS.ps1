
#https://www.mssqltips.com/sqlservertip/5114/sql-server-performance-troubleshooting-system-health-checklist/

#combine with "SQL Server 2017 Query Performance Tuning Troubleshoot and Optimize 5th ed.pdf"


#overview usage: execute just: Get-Counter # check options available with :  get-help get-counter -Examples

#*********CPU

Get-Counter '\Processor(*)\% Processor Time'


#*********Memory
Get-Counter '\Memory\Available MBytes'

Get-Counter '\Memory\Page Faults/sec'

Get-Counter '\Paging File(_Total)\% Usage'


#**********IO
Get-Counter '\PhysicalDisk(*)\Current Disk Queue Length'

Get-Counter '\PhysicalDisk(*)\Disk Reads/sec'

Get-Counter '\PhysicalDisk(*)\Disk Writes/sec'

Get-Counter '\PhysicalDisk(*)\Avg. Disk sec/Read'

Get-Counter '\PhysicalDisk(*)\Avg. Disk sec/Write'



#**********IO
Get-Counter '\Network Interface(*)\Bytes Sent/sec'

Get-Counter '\Network Interface(*)\Bytes Received/sec'


#**********Disk Space
Get-Counter '\LogicalDisk(*)\% Free Space'


#**********SQL Server
Get-Counter '\SQLServer:Buffer Manager\Buffer cache hit ratio'

Get-Counter '\SQLServer:Buffer Manager\Page Life Expectancy'

Get-Counter '\SQLServer:SQL Statistics\Batch Requests/sec'

Get-Counter '\SQLServer:SQL Statistics\SQL Compilations/sec'