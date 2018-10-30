$version = '4.31'
$file = "HP_Fortify_SCA_and_Apps_$($version)_windows_x64.exe"
$msiLink = "$($Server_URL)/$($version)/HP_Fortify_SCA_and_Apps_$($version)_windows_x64.exe"
$licenseLink="$($Server_URL)/fortify.license"
$optionsFile = "HP_Fortify_SCA_and_Apps_$($version)_windows_x64.exe.options"
$exePath = "c:\Program Files\HP_Fortify\HP_Fortify_SCA_and_Apps_$($version)\bin\sourceanalyzer.exe"
$licenseFilename="fortify.license"

Function Download_File ($uri, $localPath){
    add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
            return true;
        }
}
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12

    write-host "Downloading file FireFox MSI $uri to  $env:TEMP\$localPath"
    Invoke-WebRequest -uri $uri -OutFile "$env:TEMP\$localPath" -TimeoutSec 3600
    write-host "Downlod complete"
}

Function InstallFortifyClient {
    Set-Content -Path "$env:TEMP\$optionsFile" -Value "fortify_license_path=$env:TEMP\$licenseFilename" -Force
    Start-Process -FilePath "$env:TEMP\$file" -ArgumentList "--mode unattended" -Wait
}

Function UpdateFortiFy {
    "Update FortiFy ...."
    Start-Process -FilePath "fortifyupdate.cmd" -WorkingDirectory "c:\Program Files\HP_Fortify\HP_Fortify_SCA_and_Apps_$($version)\bin" -Wait
}

Function InstallMvnPlugin {
    "Install mvn plugin...."
    Start-Process -FilePath "mvn" -ArgumentList "clean install package"  -WorkingDirectory "c:\Program Files\HP_Fortify\HP_Fortify_SCA_and_Apps_$($version)\Samples\advanced\maven-plugin" -Wait
}

if(Test-Path $exePath) {
    "Fortify scan client already installed"
    UpdateFortiFy
    InstallMvnPlugin
    exit 0
} else {
    "file not found: $exePath"
    $downloadPath = "$env:TEMP\$file"
    $size = 0
    if(Test-Path $downloadPath) {
        $size = ((Get-Item $downloadPath).LENGTH/1MB)
    }

    write-host "file size is $size"
    if ($size -lt 543) {
        write-host "Downloading as files are not complete or not exist"
        Download_File $licenseLink $licenseFilename
        Download_File $msiLink $file
    }

    write-host "Installing Fortifyscan client...."
    InstallFortifyClient
    UpdateFortiFy
    InstallMvnPlugin
}

exit 0
