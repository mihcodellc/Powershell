#created by Monktar Bello 2/17/2023
#description: generate encrypt file for a credential
# 			  this is specific to the machine where it is used
 
#https://www.sharepointdiary.com/2020/01/read-write-encrypted-password-file-in-powershell-script.html#:~:text=How%20to%20use%20an%20Encrypted%20Password%20File%20to,from%20the%20file%20and%20use%20it%20in%20scripts.
#store password encrypted in file
$KeyPath = 'S:\DBA\maintenance\'

$Username = 'rms-asp\sqlsvc01'

$CredFile = $KeyPath+'sqlsvc01.cred'

#store password encrypted in file: it is OS specific. one created on os1 won't work on os2
$Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
$Credential.Password | ConvertFrom-SecureString | Out-File $CredFile -Force

