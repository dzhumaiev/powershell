$PathToFile = "c:\Users\Administrator\ps_scripts\get-winupd.log"

date >> $PathToFile; 
Get-WUInstall -AcceptAll –AutoReboot >> $PathToFile