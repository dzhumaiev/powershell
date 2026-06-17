# --- CONFIGURATION ---
$DiscordWebhookUrl = "https://discord.com/api/webhooks/xxxxx/yyyyyy-enter-here-the-webhook-discord-link"
# ---------------------

function Send-DiscordNotification {
    param (
        [string]$Message,
        [string]$Color = "65280" # Default Green (Success). Use "16711680" for Red (Error)
    )
    
    $Body = @{
        embeds = @(
            @{
                title       = "Server Maintenance Script"
                description = $Message
                color       = $Color
                timestamp   = (Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz")
            }
        )
    } | ConvertTo-Json -Depth 4

    try {
        Invoke-RestMethod -Uri $DiscordWebhookUrl -Method Post -Body $Body -ContentType 'application/json' -ErrorAction Stop
    } catch {
        Write-Warning "Failed to send Discord notification: $_"
    }
}

try {
    Write-Host "Starting cleanup operations..." -ForegroundColor Cyan

    # 1. Clean Adobe from Installer
    Write-Host "Cleaning Adobe installers..."
    $AdobeInstallers = (ls -File C:\Windows\Installer\ | ?{((Get-AuthenticodeSignature $_.FullName).SignerCertificate.Subject) -like "*adobe*"})
    
    $AdobeOrigFile = @()
    Get-WmiObject -Class Win32_Product | ?{$_.Name -like "*adobe*"} | %{
        $AdobeOrigFile += @($_.LocalPackage -replace ".*\\",'')
    }

    if ($AdobeInstallers) {
        $AdobeInstallers | rm -Force -Exclude $AdobeOrigFile -ErrorAction Stop
    }

    # 2. Clean SoftwareDistribution\Download
    Write-Host "Cleaning SoftwareDistribution Download folder..."
    ls 'C:\Windows\SoftwareDistribution\Download' | ?{$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | rm -Force -Recurse -ErrorAction Stop

    # 3. Clean WinSxS
    Write-Host "Analyzing and cleaning WinSxS Component Store..."
    $DismEXE = (Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore)
    if (($DismEXE | sls 'Component Store Cleanup Recommended : Yes')) {
        Dism.exe /Online /Cleanup-Image /StartComponentCleanup -ErrorAction Stop
    }

    # If everything completes without throwing an error
    Send-DiscordNotification -Message "✅ **Success:** Cleanup script completed successfully on $(hostname)." -Color "65280"
    Write-Host "Script finished successfully!" -ForegroundColor Green

} catch {
    # If any command with -ErrorAction Stop fails, catch it here
    $ErrorMessage = $_.Exception.Message
    Send-DiscordNotification -Message "❌ **Error:** Cleanup script failed on $(hostname).`n`n**Details:**`n`$ErrorMessage" -Color "16711680"
    Write-Error "Script failed: $ErrorMessage"
}
