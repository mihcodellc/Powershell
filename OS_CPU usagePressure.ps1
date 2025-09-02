#program: CPU Pressure
#Author: Monktar Bello 
#Date:10/30/2023

# Set the threshold and duration
$threshold = 85  # Define the CPU usage threshold (in percentage)
$duration = 3   # Define the duration (in minutes)
$count = 0
$maxcount = 10 # find the $threshold x10 in $duration

# Initialize a timer
$timer = [System.Diagnostics.Stopwatch]::StartNew()

# Define an email configuration (replace with your email settings)
$smtpServer = "192.168.32.158"
$fromEmail = "server@mih.com"
$toEmail = "mbello@mih.com"
$subject = "High CPU Usage Alert"


# Monitor CPU usage
while ($timer.Elapsed.TotalMinutes -lt $duration) {
    #all cmd to get the counters ON CPU, Memory, Disk, Network, SQL Server are here "Check DBA issues from Windows OS.ps1"
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    if ($cpuUsage -ge $threshold) {
		$count = $count  + 1
    }

    # Sleep for a specified interval (e.g., 10 seconds)
    Start-Sleep -Seconds 5
}

$body = "DBA: High CPU usage detected $count in $duration minutes. Current CPU usage is above $threshold%."

if ($count -ge $maxcount) {
        Send-MailMessage -SmtpServer $smtpServer -From $fromEmail -To $toEmail -Subject $subject -Body $body
        
 }
