<#
Intune Remediation Script

This script ensures specified extensions are added to the ExtensionInstallForcelist
registry policy for Google Chrome and Microsoft Edge. It avoids duplicates and 
creates the registry keys if they do not exist.

Each extension is defined as a hashtable with:
    - Browser    : "Chrome" or "Edge"
    - ExtensionId: Chrome Web Store or Edge Add-ons ID
    - UpdateUrl  : URL used to fetch and install the extension

Example extension list:
    # Chrome
    @{ Browser = "Chrome"; ExtensionId = "hdokiejnpimakedhajhdlcegeplioahd"; UpdateUrl = "https://clients2.google.com/service/update2/crx" }  # LastPass
    @{ Browser = "Chrome"; ExtensionId = "ljdobmomdgdljniojadhoplhkpialdid"; UpdateUrl = "https://clients2.google.com/service/update2/crx" }  # Graph X-Ray

    # Edge
    @{ Browser = "Edge"; ExtensionId = "hdokiejnpimakedhajhdlcegeplioahd"; UpdateUrl = "https://edge.microsoft.com/extensionwebstorebase/v1/crx" }  # LastPass
    @{ Browser = "Edge"; ExtensionId = "ljdobmomdgdljniojadhoplhkpialdid"; UpdateUrl = "https://edge.microsoft.com/extensionwebstorebase/v1/crx" }  # Graph X-Ray

########### LEGAL DISCLAIMER ###########
This script is provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement.
Use at your own risk. Thoroughly test before deploying in production environments.

.NOTES
Author: John Marcum (PJM)  
Date: May 1, 2025
Contact: https://x.com/MEM_MVP

.VERSION HISTORY

1.0 – May 1, 2025
- Initial public release.
#>


$Now = Get-Date -Format MM-dd-yyyy-HH-mm-ss
$logFile = "C:\Windows\Logs\LastPass_Extension_Remediation-$Now.log"
Start-Transcript -Path $logFile

$extensions = @(
    # Chrome
    @{ Browser = "Chrome"; ExtensionId = "hdokiejnpimakedhajhdlcegeplioahd"; UpdateUrl = "https://clients2.google.com/service/update2/crx" } # LastPass  

    # Edge
    @{ Browser = "Edge"; ExtensionId = "hdokiejnpimakedhajhdlcegeplioahd"; UpdateUrl = "https://edge.microsoft.com/extensionwebstorebase/v1/crx" } # LastPass   
)

foreach ($ext in $extensions) {
    $browser = $ext.Browser
    $extensionId = $ext.ExtensionId
    $updateUrl = $ext.UpdateUrl

    switch ($browser.ToLower()) {
        "chrome" { $regPath = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" }
        "edge" { $regPath = "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" }
        default {
            Write-Host "Unsupported browser: $browser"
            continue
        }
    }

    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Host "Created registry key: $regPath"
    }

    $desiredValue = "$extensionId;$updateUrl"
    $existing = Get-ItemProperty -Path $regPath | Select-Object -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
    $existingValues = $existing.PSObject.Properties | ForEach-Object { $_.Value }

    if ($existingValues -contains $desiredValue) {
        Write-Host "Already present: $desiredValue"
        continue
    }

    $i = 1
    while ($existing.PSObject.Properties.Name -contains "$i") { $i++ }

    New-ItemProperty -Path $regPath -Name "$i" -Value $desiredValue -PropertyType String -Force | Out-Null
    Write-Host "Added [$browser]: $desiredValue as index $i"
}
Stop-Transcript
