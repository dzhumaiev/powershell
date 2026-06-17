# Clean Adobe from Installer
$AdobeInstallers = (ls -File C:\Windows\Installer\ | ?{((Get-AuthenticodeSignature $_.FullName).SignerCertificate.Subject) -like "*adobe*"})
Get-WmiObject -Class Win32_Product | ?{$_.Name -like "*adobe*"} | %{
    $AdobeOrigFile += @($_.LocalPackage -replace ".*\\",'')
}

$AdobeInstallers | rm -Force -Exclude $AdobeOrigFile 2>$null

# Clean SoftwareDistribution\Download
ls 'C:\Windows\SoftwareDistribution\Download' | ?{$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | rm -Force -Recurse 2>$null

# Clean WinSxS
$DismEXE = (Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore)
if (($DismEXE | sls 'Component Store Cleanup Recommended : Yes')) {
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup
}

