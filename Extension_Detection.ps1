<#
.SYNOPSIS
Checks if required browser extensions are configured in the force-install registry key.

.DESCRIPTION
This script verifies that specified browser extensions are present in the ExtensionInstallForcelist registry path
for Google Chrome and Microsoft Edge. If any are missing, the script returns a non-zero exit code, which triggers remediation.

.EXAMPLE
.\Extension_Detection.ps1

.NOTES
Script Name: Extension_Detection.ps1
Author: John Marcum (PJM)  
Date: 05/02/2025 
Contact: https://x.com/MEM_MVP

.VERSION HISTORY
1.0 – 05/02/2025
- Initial public release.

Supported browsers:
- Google Chrome
- Microsoft Edge

Expected format for each entry:
    "<Browser>|<ExtensionId>;<UpdateUrl>"

Examples:
    "Chrome|hdokiejnpimakedhajhdlcegeplioahd;https://clients2.google.com/service/update2/crx"         # LastPass (Chrome)
    "Chrome|ljdobmomdgdljniojadhoplhkpialdid;https://clients2.google.com/service/update2/crx"         # Graph X-Ray (Chrome)
    "Edge|hdokiejnpimakedhajhdlcegeplioahd;https://edge.microsoft.com/extensionwebstorebase/v1/crx"  # LastPass (Edge)
    "Edge|ljdobmomdgdljniojadhoplhkpialdid;https://edge.microsoft.com/extensionwebstorebase/v1/crx"  # Graph X-Ray (Edge)

########### LEGAL DISCLAIMER ###########
This script is provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement.
Use at your own risk. Thoroughly test before deploying in production environments.

#>

$Now = Get-Date -Format MM-dd-yyyy-HH-mm-ss
$logFile = "C:\Windows\Logs\LastPass_Extension_Detection-$Now.log"
Start-Transcript -Path $logFile


# Define the extension(S)
$required = @(
    "Chrome|hdokiejnpimakedhajhdlcegeplioahd;https://clients2.google.com/service/update2/crx", # LastPass    
    "Edge|hdokiejnpimakedhajhdlcegeplioahd;https://edge.microsoft.com/extensionwebstorebase/v1/crx" # LastPass    
)

$missing = @()

foreach ($entry in $required) {
    $parts = $entry -split "\|"
    $browser = $parts[0]
    $val = $parts[1]

    switch ($browser.ToLower()) {
        "chrome" { $reg = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" }
        "edge" { $reg = "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" }
        default { continue }
    }

    if (-not (Test-Path $reg)) {
        $missing += "${browser}: registry key missing"
        continue
    }

    $props = Get-ItemProperty -Path $reg | Select-Object -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
    if ($props.PSObject.Properties.Value -notcontains $val) {
        $missing += "${browser}: ${val} not found"
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing extensions:`n$($missing -join "`n")"
    Stop-Transcript
    exit 1
}
else {
    Write-Host 'All good'
    Stop-Transcript
    Exit 0
}

