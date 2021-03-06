﻿#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
#

<#
  .SYNOPSIS
 Use this cmdlet to install CNTK 

 .DESCRIPTION
 The script will download and install the CNTK prerequisites and Anaconda environment

 It will analyse your machine and will determine which components are required. 
 The required components will be downloaded and cached.
 Repeated operation of this script will reuse already downloaded components.

 - If required VS2012 Runtime and VS2013 Runtime will be installed
 - If required MSMPI will be installed
 - Git will be installed if required
 - CNTK source will be downloaded from Git and copied into [c:\repos\cntk]
 - Anaconda3 will be installed into [<AnacondaBasePath>]
 - A CNTK-PY34 environment will be created in [<AnacondaBasePath>\envs]
 - CNTK will be installed into the CNTK-PY34 environment

 .PARAMETER AnacondaBasePath
 This is an optional parameter and can be used to specify an already installed Anaconda3 installation.
 By default a version of Anaconda3 will be installed into [C:\local\Anaconda3-4.1.1-Windows-x86_64]

 .PARAMETER Execute
 This is an optional parameter. Without setting this switch, no changes to the machine setup/installation will be performed

 .PARAMETER ForceWheelUpdate
 Will uninstall an existing CNTK wheel and install a new wheel

 .PARAMETER RepoTag
 Optional parameter to specify a specific tag to check-out in the CNTK-repo

.EXAMPLE
 .\installer.ps1
 
 Run the installer and see what operations would be performed
.EXAMPLE
 .\installer.ps1 -Execute
 
 Run the installer and perform the installation operations
.EXAMPLE
 .\installer.ps1 -Execute -ForceWheelUpdate
 
 Run the installer and install CNTKv2 on the machine. Force a CNTK whl Update in the CNTK-Anaconda install
#>

[CmdletBinding()]
Param(
    [parameter(Mandatory=$false)]
    [string] $AnacondaBasePath = "C:\local\Anaconda3-4.1.1-Windows-x86_64",
    [parameter(Mandatory=$false)]
    [switch] $Execute,
    [parameter(Mandatory=$false)]
    [switch] $ForceWheelUpdate,
    [parameter(Mandatory=$false)]
    [string] $RepoTag="v2.alpha4"
)

$MyDir = Split-Path $MyInvocation.MyCommand.Definition
$cntkRootDir = split-path $MyDir | split-path

$roboCopyCmd    = "C:\Windows\System32\robocopy.exe"
$localCache     = "$MyDir\InstallCache"

# Get the current script's directory and Dot-source the a file with common Powershell script function 
# residing in the the current script's directory
. "$MyDir\_operations"
. "$MyDir\_verify"
. "$MyDir\_download"
. "$MyDir\_info"
. "$MyDir\_action"

Function main
{
    try {
        if (-not (DisplayStart)) {
            Write-Host 
            Write-Host " ... Quitting ... "
            Write-Host
            return
        }

        if(-not (Test-Path -Path $localCache)) {
            new-item -Path $localcache -ItemType Container | Out-Null
        }

        $global:operationList  = @()
        if (VerifyOperations) {

            DownloadOperations

            ActionOperations

            DisplayEnd
        }
    }
    catch {
        $currentTime = Get-Date
        Write-Host "Exception caught - function main / failure - End time [$currentTime]"
        Write-Host ($Error[0]).Exception
    }
}

main

exit 0
