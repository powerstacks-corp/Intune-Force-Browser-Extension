# Intune Browser Extension Management with Proactive Remediations

This repository contains PowerShell scripts for managing forced browser extensions in Google Chrome and Microsoft Edge using Microsoft Intune Proactive Remediations.

## Overview

Intune allows you to configure the `ExtensionInstallForcelist` policy to enforce browser extension installations. However, Intune does not support merging multiple configuration profiles that target the same setting. When multiple profiles are assigned, the result is a policy conflict, and it becomes unclear which extension list is applied.

These scripts provide a scalable alternative using Intune Proactive Remediations. They allow you to detect, enforce, and optionally remove specific browser extensions through PowerShell, without relying on configuration profiles.

## Contents

- `Detection.ps1` – Checks whether required extensions are present in the system registry. If any are missing, the script exits with a non-zero code.
- `Remediation.ps1` – Adds required extensions to the force-install list in the registry. Creates missing registry paths and avoids duplicates.
- `Remove-Extensions.ps1` – Optional script to remove specific extensions from the force-install list.

## Extension Format

Extensions are defined in the following format:

### Detection script
```powershell
"Chrome|<extensionId>;<updateUrl>"
