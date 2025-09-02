#********************************** Disk pressure
# https://docs.microsoft.com/en-us/azure-stack/hci/manage/diskspd-overview
# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/dn894707(v=ws.11)
# go to "Step 3: Run DiskSpd trial runs, and tune DiskSpd parameters" in above link to see action,meaning, how to decide
# in powershell:  .\DiskSpd.exe /? #from its folder
# in bat file, put : 
# 	rem warm up 300 run for 30s
#	diskspd.exe -c100G -t24 -si64K -b64K -w70 -d600 -W300 -L -o12 -D -h u:\bello\testfile.dat > 64KB_Concurent_Write_24Threads_12OutstandingIO.txt
# more infos below
# https://www.altaro.com/hyper-v/storage-performance-baseline-diskspd/


.\diskspd.exe /? - for  display usage information
# -W<seconds>           warm up time - duration of the test before measurements start [default=5s]
# -D<milliseconds>      Capture IOPs statistics in intervals of <milliseconds>; [default=1000, 1 second].
# -d<seconds>           duration (in seconds) to run test [default=10s]
# -L                    measure latency statistics
# -o<count>             number of outstanding I/O requests per target per thread
# -c<size>[K|M|G|b]     create files of the given size.
# -t<count>             number of threads per target (conflicts with -F)
# -w<percentage>        percentage of write requests (-w and -w0 are equivalent and result in a read-only workload).
#                        absence of this switch indicates 100% reads
# -h or -Suw           u -disable software caching, w -enable writethrough (no hardware write caching)
# -i<count>             number of IOs per burst;
# -s[i]<size>[K|M|G|b]  sequential stride size, offset between subsequent I/O operations


# customize this found on 2nd link above
1..24 | ForEach-Object {
   $param = "-o$_"
   $result = g:\bello\diskspd.exe -w90 -d60 -W30 -si64K -b64K -t24 $param -h -L -Z1M -c100G v:\bello\testfile.dat
   foreach ($line in $result) {if ($line -like "total:*") { $total=$line; break } }
   foreach ($line in $result) {if ($line -like "avg.*") { $avg=$line; break } }
   $mbps = $total.Split("|")[2].Trim()
   $iops = $total.Split("|")[3].Trim()
   $latency = $total.Split("|")[4].Trim()
   $cpu = $avg.Split("|")[1].Trim()
   "Param $param, $iops iops, $mbps MB/sec, $latency ms, $cpu CPU"
} | Out-File -FilePath .\benchmark.txt


./diskspd.exe -r -t24 -b128K -d30 -L -o8 -w0 -D -h w:\perf-disk\testfile.dat > 128KB_Random_Read_24Threads_8OutstandingIO-w.txt


# measure IO on each drive 6/16/2023 as summary 
# random , 8 outstanding I/Os per thread, block 128K,  100% Write, 24Threads per file for 30seconds
# File have been created ahead
#128K random
'd','u' | ForEach-Object {
   $param = "$_"+':\perf-disk\testfile.dat' #for each drive
   $result = C:\perf-test\diskspd\x86\diskspd.exe -r -t24 -b128K -d30 -L -o8 -w0 -D -h $param
   foreach ($line in $result) {if ($line -like "total:*") { $total=$line; break } }
   foreach ($line in $result) {if ($line -like "avg.*") { $avg=$line; break } }
   $mbps = $total.Split("|")[2].Trim()
   $iops = $total.Split("|")[3].Trim()
   $latency = $total.Split("|")[4].Trim()
   $cpu = $avg.Split("|")[1].Trim()
   "Param $param, $iops iops, $mbps MB/sec, $latency ms, $cpu CPU"
} | Out-File -FilePath .\Bello_128KB_Random_Read_24Threads_8OutstandingIO-w.txt -append -force

