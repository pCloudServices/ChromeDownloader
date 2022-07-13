# Script to install Google Chrome + Edit PSMConfigureAppLocker.xml + Run PSMConfigureAppLocker.xml

Start-BitsTransfer "https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi" $env:TEMP\GoogleChromeStandaloneEnterprise64.msi
$chromeinstaller = "$env:TEMP\GoogleChromeStandaloneEnterprise64.msi"
msiexec.exe /package $chromeinstaller

$logdate = Get-Date -Format yyyyMMdd
$logtime = Get-Date -Format HHmmss
$backupfile = "C:\Program Files (x86)\Cyberark\PSM\Hardening\PSMConfigureAppLocker-" + $logdate + "-" + $logtime + ".bkp"

$filePath = 'C:\Program Files (x86)\Cyberark\PSM\Hardening\PSMConfigureAppLocker.xml'
copy $filePath $backupfile
$tempFilePath = "$env:TEMP\$($filePath | Split-Path -Leaf)"
$find = @'
    <Application Name="GoogleChrome" Type="Exe" Path="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" Method="Publisher" />
'@
$replace = @'
    <Application Name="GoogleChrome" Type="Exe" Path="C:\Program Files\Google\Chrome\Application\chrome.exe" Method="Publisher" />
'@

$xmlcontent = (Get-Content -Path $filePath).Replace($find,$replace)
$find = @'
    End of Google Chrome process comment -->
'@
$replace = @'

'@

$xmlcontent = ($xmlcontent).Replace($find,$replace)
$find = @'
    <!-- If relevant, uncomment this part to allow Google Chrome webform based connection clients
'@
$replace = @'
    <!-- If relevant, uncomment this part to allow Google Chrome webform based connection clients    End of Google Chrome process comment -->
'@

($xmlcontent).Replace($find,$replace) | Add-Content -Path $tempFilePath

Remove-Item -Path $filePath
Move-Item -Path $tempFilePath -Destination $filePath

Set-Location "C:\Program Files (x86)\Cyberark\PSM\Hardening\"
.\PSMConfigureAppLocker.ps1
