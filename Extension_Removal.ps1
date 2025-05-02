<#
.SYNOPSIS
Removes specified extensions from the force-install list for Chrome and Edge.

.DESCRIPTION
This script checks for specified browser extensions in the ExtensionInstallForcelist registry keys for 
Chrome and Edge. If found, the corresponding registry entries are removed. Useful for retiring or replacing extensions.

.EXAMPLE
.\Extension_Removal.ps1

.NOTES
Script Name: Extension_Removal.ps1
Author: John Marcum (PJM)  
Date: 05/02/2025 
Contact: https://x.com/MEM_MVP


Supported browsers:
- Google Chrome
- Microsoft Edge

.VERSION HISTORY

1.0 – 05/02/2025
- Initial public release.

Each extension is defined with:
    - Browser: "Chrome" or "Edge"
    - ExtensionId: Extension GUID
    - UpdateUrl: URL that matches the registry value format


########### LEGAL DISCLAIMER ###########
This script is provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement.
Use at your own risk. Thoroughly test before deploying in production environments.
#>


$Now = Get-Date -Format MM-dd-yyyy-HH-mm-ss
$logFile = "C:\Windows\Logs\Remove_Remediation-$Now.log"
Start-Transcript -Path $logFile


$extensionsToRemove = @(
    # Chrome
    @{ Browser = "Chrome"; ExtensionId = "hdokiejnpimakedhajhdlcegeplioahd"; UpdateUrl = "https://clients2.google.com/service/update2/crx" } # LastPass   

    # Edge
    @{ Browser = "Edge"; ExtensionId = "hdokiejnpimakedhajhdlcegeplioahd"; UpdateUrl = "https://edge.microsoft.com/extensionwebstorebase/v1/crx" } # LastPass
 
)

foreach ($ext in $extensionsToRemove) {
    $browser = $ext.Browser
    $extensionId = $ext.ExtensionId
    $updateUrl = $ext.UpdateUrl
    $desiredValue = "$extensionId;$updateUrl"

    switch ($browser.ToLower()) {
        "chrome" { $regPath = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" }
        "edge" { $regPath = "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" }
        default {
            Write-Host "Unsupported browser: $browser"
            continue
        }
    }

    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path not found: $regPath"
        continue
    }

    $existingProps = Get-ItemProperty -Path $regPath
    foreach ($prop in $existingProps.PSObject.Properties) {
        if ($prop.Name -match '^\d+$' -and $prop.Value -eq $desiredValue) {
            Remove-ItemProperty -Path $regPath -Name $prop.Name -Force
            Write-Host "Removed [$browser]: $desiredValue from $regPath ($($prop.Name))"
        }
    }
}
Stop-Transcript