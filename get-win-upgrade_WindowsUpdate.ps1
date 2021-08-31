$PathToFile = "c:\Users\Administrator\ps_scripts\get-winupd.log"

date >> $PathToFile; 
Get-WindowsUpdate -install -acceptall -autoreboot >> $PathToFile