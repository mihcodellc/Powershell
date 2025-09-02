# Write-Output 'Hello World!'

# $name = Read-Host -Prompt "Please enter your name"
# Write-Output "Congrats $name! Welcome to PowerShell to power your skills As DBA"
#param has to be at the begin of the file
#param seperate by comma
Param(
[Parameter(mandatory, HelpMessage = "I made your name as a requirement. Please, provide it.")] # use of parameter[] decorator
$d_name = "DefaultNameInthisProgram"
)

$date = Read-Host "What is today's date"
$name = Read-Host "Please enter your name"
Write-Host "Today's date is $date." 
# noted the different way to print on screen
Write-Output "Today is the day $name began their PowerShell programming journey." 
Write-Output "Today is the day `$name began their PowerShell programming journey." # not confused ' & `

Read-Host "What is today's date" 

#features for scripting in PowerShell
###- Variable
###- Functions
###- Flow Control
###- Loops
###- Error Handling
###- Expressions 


$d_date = get-date -format "yyyy-MM-dd"
Write-Output "$d_date is the day $d_name began their PowerShell programming journey." 