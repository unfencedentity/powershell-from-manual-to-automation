<#
.SYNOPSIS
    Solutions for Chapter 07: Functions.

.DESCRIPTION
    Demonstrates function definition, invocation, parameters,
    structured output, pipeline binding, lifecycle blocks,
    verbose output, and safe change simulation.
#>

# Exercise 1: Define and invoke a function

function Show-Greeting {
    "Hello from PowerShell"
}

Show-Greeting
Show-Greeting


# Exercise 2: Add a typed parameter

function Get-DoubledNumber {
    param(
        [int]$Number
    )

    $Number * 2
}

Get-DoubledNumber -Number 10


# Exercise 3: Return a structured object

function New-VirtualMachineName {
    param(
        [string]$Application,
        [string]$Environment,
        [string]$Region,
        [int]$Instance
    )

    $virtualMachineName = "vm-$Application-$Environment-$Region-$Instance"

    [PSCustomObject]@{
        Name        = $virtualMachineName
        Application = $Application
        Environment = $Environment
        Region      = $Region
        Instance    = $Instance
    }
}

$virtualMachine = New-VirtualMachineName `
    -Application "core" `
    -Environment "dev" `
    -Region "weu" `
    -Instance 1

$virtualMachine
$virtualMachine.Name


# Exercise 4: Wrap reusable service logic

function Get-ServiceReport {
    param(
        [string]$Name = "*"
    )

    Get-Service -Name $Name |
        Where-Object Status -eq "Running" |
        Sort-Object DisplayName |
        Select-Object Name, DisplayName, Status
}

$serviceReport = Get-ServiceReport -Name "Win*"

$serviceReport
$serviceReport.Count
$serviceReport | Get-Member


# Exercise 5: Build a process report

function Get-ProcessReport {
    param(
        [string]$Name = "*"
    )

    Get-Process -Name $Name |
        Sort-Object CPU -Descending |
        Select-Object -First 5 Name, Id, CPU
}

$processReport = Get-ProcessReport

$processReport
$processReport.Count


# Exercise 6: Accept pipeline input

function Add-ResourceGroupPrefix {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$ResourceGroup
    )

    process {
        "rg-$ResourceGroup"
    }
}

$resourceGroupNames = "core", "network", "security" |
    Add-ResourceGroupPrefix

$resourceGroupNames


# Exercise 7: Separate diagnostic messages from output

function Get-DeploymentStatus {
    [CmdletBinding()]
    param()

    Write-Verbose "Checking deployment..."

    [PSCustomObject]@{
        Name   = "core-api"
        Status = "Ready"
    }
}

$deploymentStatus = Get-DeploymentStatus

$deploymentStatus
$deploymentStatus.Count
$deploymentStatus.GetType().Name

$deploymentStatus = Get-DeploymentStatus -Verbose

$deploymentStatus
$deploymentStatus.Count


# Exercise 8: Accept pipeline input by property name

function Get-ServiceStatus {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("ServiceName")]
        [string]$Name
    )

    process {
        Get-Service -Name $Name |
            Select-Object Name, DisplayName, Status
    }
}

[PSCustomObject]@{
    Name = "Spooler"
} | Get-ServiceStatus

[PSCustomObject]@{
    ServiceName = "Spooler"
} | Get-ServiceStatus


# Exercise 9: Use begin, process, and end

function ConvertTo-NormalizedResourceName {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]$Name
    )

    begin {
        $processedCount = 0
        Write-Verbose "Starting normalization."
    }

    process {
        $processedCount++
        $normalizedName = $Name.Trim().ToLowerInvariant()

        [PSCustomObject]@{
            OriginalName   = $Name
            NormalizedName = $normalizedName
        }
    }

    end {
        Write-Verbose "Processed $processedCount resource names."
    }
}

$normalizedNames = " Core-API ", " NETWORK-HUB ", "Data-Store" |
    ConvertTo-NormalizedResourceName -Verbose

$normalizedNames


# Exercise 10: Safely simulate a change

function Set-DeploymentState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Name,
        [string]$State
    )

    if ($PSCmdlet.ShouldProcess(
        $Name,
        "Set deployment state to '$State'"
    )) {
        "Deployment '$Name' state was set to '$State'."
    }
}

Set-DeploymentState `
    -Name "core-api" `
    -State "Ready" `
    -WhatIf
