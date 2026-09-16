# DBSUPPORT-5648
'_PRECACHE_MEDRXCashARCDeposit_Receipt_ReceiptDetail-PROD','MEDRX CashARC Deposit_Receipt_ReceiptDetail - PROD', 'CashARC Zeropay Receipt Remittance' | ForEach-Object {

powershell.exe -File  "C:\DBA\Scripts\Elastic_cube_check_2.ps1" $_ 

 }
 
 #.\Elastic_cube_check_run.ps1
 #powershell.exe -File  "C:\DBA\Scripts\Elastic_cube_check_run.ps1"