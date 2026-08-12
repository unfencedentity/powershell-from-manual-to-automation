<#
.SYNOPSIS
    Solutions for Chapter 08: Parameters.

.DESCRIPTION
    Demonstrates parameter declarations, binding, types, conversion,
    optional and mandatory input, defaults, validation, aliases,
    PSBoundParameters, splatting, discovery, pipeline binding, and
    enterprise interface design.

.NOTES
    All examples are read-only or simulated. Invalid test invocations are
    commented out so the complete file can run without expected binding errors.
#>

# Exercise 1: Distinguish parameters from arguments

function Get-Greeting {
    param(
        [string]$Name
    )

    $Message = "Hello, $Name"
    $Message
}

Get-Greeting -Name "Ana"
Get-Greeting "Mihai"

# Name is the parameter. "Ana" and "Mihai" are arguments supplied during
# separate invocations. $Name is the parameter variable, and $Message is an
# internal function variable.


# Exercise 2: Compare named and positional binding

function Get-PersonalGreeting {
    param(
        [string]$Greeting,
        [string]$Name
    )

    "$Greeting, $Name"
}

Get-PersonalGreeting -Name "Ana" -Greeting "Howdy"
Get-PersonalGreeting "Hello" "Mihai"
Get-PersonalGreeting "Mihai" "Hello"

# Named binding matches arguments by parameter name, so argument order does
# not matter. Positional binding matches arguments by declared position, so
# reversing positional arguments changes which value each parameter receives.


# Exercise 3: Observe integer conversion

function ConvertTo-Minutes {
    param(
        [int]$Hours
    )

    $Hours * 60
}

ConvertTo-Minutes -Hours 3
ConvertTo-Minutes -Hours "3"

# Expected binding error: "three" cannot be converted to System.Int32.
# Uncomment to observe the error.

# ConvertTo-Minutes -Hours "three"

# The integer 3 is accepted directly. The numeric string "3" is converted to
# System.Int32 during parameter binding. Conversion failure occurs before the
# function body executes.


# Exercise 4: Accept explicit Boolean input

function Show-FeatureState {
    param(
        [bool]$Enabled
    )

    $Enabled
}

$enabledResult = Show-FeatureState -Enabled $true
$disabledResult = Show-FeatureState -Enabled $false

$enabledResult
$disabledResult
$enabledResult.GetType().FullName

# A Boolean parameter requires the caller to supply an explicit $true or
# $false argument. The returned type is System.Boolean.


# Exercise 5: Use a switch parameter

function Get-ServiceSelectionMode {
    param(
        [switch]$IncludeStopped
    )

    if ($IncludeStopped) {
        "All services"
    }
    else {
        "Running services only"
    }
}

Get-ServiceSelectionMode
Get-ServiceSelectionMode -IncludeStopped

# A Boolean parameter receives an explicit value. A switch is normally false
# when absent and true when present, making it suitable for optional behavior.


# Exercise 6: Use an optional parameter with a default value

function New-ResourceName {
    param(
        [string]$Application,
        [string]$Environment,
        [int]$Instance = 1
    )

    "vm-$Application-$Environment-$Instance"
}

New-ResourceName `
    -Application "core" `
    -Environment "dev"

New-ResourceName `
    -Application "core" `
    -Environment "dev" `
    -Instance 2


# Exercise 7: Require mandatory input

function Get-DeploymentTarget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Application,

        [Parameter(Mandatory = $true)]
        [string]$Environment
    )

    [PSCustomObject]@{
        Application = $Application
        Environment = $Environment
        Target      = "$Application-$Environment"
    }
}

Get-DeploymentTarget `
    -Application "core" `
    -Environment "test"

Get-Command Get-DeploymentTarget -Syntax


# Exercise 8: Accept a string collection

function Get-EnvironmentReport {
    param(
        [string[]]$Environment
    )

    foreach ($currentEnvironment in $Environment) {
        [PSCustomObject]@{
            Environment       = $currentEnvironment
            ResourceGroupName = "rg-core-$currentEnvironment-weu"
        }
    }
}

Get-EnvironmentReport -Environment "prod"

$environmentReport = Get-EnvironmentReport `
    -Environment "dev", "test", "prod"

$environmentReport
$environmentReport.Count


# Exercise 9: Validate a deployment request

function New-DeploymentRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Application,

        [Parameter(Mandatory = $true)]
        [ValidateSet("dev", "test", "prod")]
        [string]$Environment,

        [ValidateRange(1, 10)]
        [int]$Instance = 1,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("^rg-[a-z0-9-]+$")]
        [string]$ResourceGroupName
    )

    [PSCustomObject]@{
        Application       = $Application
        Environment       = $Environment
        Instance          = $Instance
        ResourceGroupName = $ResourceGroupName
    }
}

New-DeploymentRequest `
    -Application "core" `
    -Environment "prod" `
    -Instance 2 `
    -ResourceGroupName "rg-core-prod-weu"

# Expected validation errors; uncomment one invocation at a time.

# New-DeploymentRequest `
#     -Application "" `
#     -Environment "prod" `
#     -ResourceGroupName "rg-core-prod-weu"

# New-DeploymentRequest `
#     -Application "core" `
#     -Environment "staging" `
#     -ResourceGroupName "rg-core-staging-weu"

# New-DeploymentRequest `
#     -Application "core" `
#     -Environment "prod" `
#     -Instance 11 `
#     -ResourceGroupName "rg-core-prod-weu"

# New-DeploymentRequest `
#     -Application "core" `
#     -Environment "prod" `
#     -ResourceGroupName "core_prod"


# Exercise 10: Add a parameter alias

function Get-ServiceLookupRequest {
    param(
        [Alias("ServiceName")]
        [string]$Name
    )

    [PSCustomObject]@{
        Name = $Name
    }
}

Get-ServiceLookupRequest -Name "Spooler"
Get-ServiceLookupRequest -ServiceName "WinRM"


# Exercise 11: Inspect explicitly bound parameters

function Get-ReportRequest {
    param(
        [string]$Name = "*",
        [switch]$IncludeStopped
    )

    [PSCustomObject]@{
        Name                      = $Name
        IncludeStopped            = $IncludeStopped.IsPresent
        NameWasSupplied            = $PSBoundParameters.ContainsKey("Name")
        IncludeStoppedWasSupplied  = $PSBoundParameters.ContainsKey(
            "IncludeStopped"
        )
        BoundParameterCount       = $PSBoundParameters.Count
    }
}

Get-ReportRequest
Get-ReportRequest -Name "Win*" -IncludeStopped


# Exercise 12: Use named parameter splatting

$DeploymentParameters = @{
    Application       = "core"
    Environment       = "prod"
    Instance          = 2
    ResourceGroupName = "rg-core-prod-weu"
}

New-DeploymentRequest @DeploymentParameters

# $DeploymentParameters returns one hashtable object. @DeploymentParameters
# splats its keys and values as named parameters and arguments.


# Exercise 13: Discover parameter syntax

Get-Command Get-Service -Syntax
Get-Help Get-Service -Parameter Name
Get-Help Get-Service -Examples

# The Name parameter accepts String[], which means one or several strings.
# Square brackets around the syntax element indicate that it is optional in
# that parameter set. Get-Help with -Parameter isolates parameter details;
# Get-Help with -Examples displays example invocations.


# Exercise 14: Reinforce pipeline parameter binding

function Add-ResourceGroupPrefix {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]$ResourceGroup
    )

    process {
        "rg-$ResourceGroup"
    }
}

"core", "network", "security" |
    Add-ResourceGroupPrefix

function Resolve-ServiceName {
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
        [PSCustomObject]@{
            Name = $Name
        }
    }
}

[PSCustomObject]@{
    Name = "Spooler"
} | Resolve-ServiceName

[PSCustomObject]@{
    ServiceName = "WinRM"
} | Resolve-ServiceName


# Exercise 15: Design an enterprise automation interface

function New-AzureAutomationContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [ValidateSet("dev", "test", "prod")]
        [string]$Environment,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("^rg-[a-z0-9-]+$")]
        [string]$ResourceGroupName,

        [switch]$IncludeDetails
    )

    [PSCustomObject]@{
        Authentication    = "OIDC"
        TenantId          = $TenantId
        SubscriptionId    = $SubscriptionId
        Environment       = $Environment
        ResourceGroupName = $ResourceGroupName
        IncludeDetails    = $IncludeDetails.IsPresent
        GeneratedAt       = Get-Date
    }
}

$AzureContextParameters = @{
    TenantId          = "00000000-0000-0000-0000-000000000000"
    SubscriptionId    = "11111111-1111-1111-1111-111111111111"
    Environment       = "prod"
    ResourceGroupName = "rg-core-prod-weu"
    IncludeDetails    = $true
}

$azureContext = New-AzureAutomationContext @AzureContextParameters

$azureContext
$azureContext.GetType().FullName
$azureContext | Get-Member
$azureContext.GeneratedAt.GetType().FullName

# This function receives and returns targeting context only. It does not
# perform authentication, interactive login, or secret handling. A GitHub
# Actions workflow should continue using OIDC and Azure RBAC.
