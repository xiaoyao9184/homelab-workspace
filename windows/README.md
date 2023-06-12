#

## config winrm

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://ghproxy.com/https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Upgrade-PowerShell.ps1"
$file = "$env:TEMP\Upgrade-PowerShell.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

&$file -Version 5.1 -Verbose

Set-ExecutionPolicy -ExecutionPolicy Restricted -Force
```


```powershell
Set-Service -Name "WinRM" -StartupType Automatic -Status Running
```



```powershell
winrm quickconfig
```

or just http


```powershell
$selector_set = @{
    Address = "*"
    Transport = "HTTP"
}

New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set
```

or signed certificate with https

```powershell
$n = Read-Host "Please enter your hostname"
$f = Read-Host "Please enter your CA file path"
$p = Read-Host "Please enter your CA file password" -AsSecureString

$cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$n"
$password = ConvertTo-SecureString -String "$p" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "$file" -Password $password

Write-Host "Copy Certificate Thumbprint for WinRM Instance: $cert.Thumbprint"
```

import it to Certificates snap-in, see [how](https://help.f-secure.com/product.html?business/radar/4.0/en/task_8772A6A76D994406B4809EB264EB51EE-4.0-en)

```powershell
$thumbprint = Read-Host "Paste Certificate Thumbprint"
$selector_set = @{
    Address = "*"
    Transport = "HTTPS"
}
$value_set = @{
    CertificateThumbprint = $thumbprint
}

New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set
```


```powershell
Enable-PSRemoting -Force
Enter-PSSession -ComputerName "127.0.0.1"
```


# test winrm


```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
```

```powershell
$n = Read-Host "Please enter your hostname"
Enter-PSSession -ComputerName "$n"
```

http test

```powershell
$n = Read-Host "Please enter your hostname"
$u = Read-Host "Please enter your username"
$p = Read-Host "Please enter your password" -AsSecureString
$p1 = ConvertFrom-SecureString $p -AsPlainText
winrs -r:http://${n}:5985/wsman -u:$u -p:$p1 ipconfig
```

```powershell
$n = Read-Host "Please enter your hostname"
$u = Read-Host "Please enter your username"
$p = Read-Host "Please enter your password" -AsSecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $u, $p

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName $n -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```

https

```powershell
$n = Read-Host "Please enter your hostname"
$u = Read-Host "Please enter your username"
$p = Read-Host "Please enter your password" -AsSecureString
$p1 = ConvertFrom-SecureString $p -AsPlainText
winrs -r:https://${n}:5986/wsman -u:$u -p:$p1 -ssl ipconfig
```

```powershell
$n = Read-Host "Please enter your hostname"
$u = Read-Host "Please enter your username"
$p = Read-Host "Please enter your password" -AsSecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $u, $p

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName $n -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```