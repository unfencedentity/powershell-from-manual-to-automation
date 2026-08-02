<#
.SYNOPSIS
    High-ROI PowerShell function patterns.

.DESCRIPTION
    Provides safe, reusable examples of the most important
    PowerShell function patterns for live coding, interviews,
    infrastructure automation, and enterprise scripting.

.NOTES
    The examples are definitions only.
    Example invocations are commented out so dot-sourcing this
    file does not execute commands automatically.
#>

<#
MENTAL MODEL

Requirement
    -> Function name
    -> Inputs
    -> Processing
    -> Output
    -> Diagnostics
    -> Safety

DECISION MAP

Reusable behavior
    -> function Verb-Noun {}

Caller provides input
    -> param()

Several related output fields
    -> [PSCustomObject]@{}

Existing commands must be packaged
    -> wrap the tested pipeline in a function

Optional diagnostic information
    -> [CmdletBinding()] + Write-Verbose

Entire values arrive through the pipeline
    -> ValueFromPipeline + process {}

Properties arrive through the pipeline
    -> ValueFromPipelineByPropertyName + process {}

Initialization and finalization are required
    -> begin {} + process {} + end {}

The function changes system state
    -> SupportsShouldProcess + ShouldProcess()

Pipeline-only shorthand is explicitly required
    -> filter
#>


#region Pattern 1 - Simple function

function Show-AutomationMessage {       # Define reusable behavior with a Verb-Noun name
    "Automation is ready"               # Return one string through the success output stream
}

# Defining the function produces no output.
# Invoking the function executes its body.

# Show-AutomationMessage
# Show-AutomationMessage

#endregion


#region Pattern 2 - Function with one typed parameter

function ConvertTo-Minutes {            # Define a function that performs a conversion
    param(                               # Declare the function's public input
        [int]$Hours                     # Require Hours to be treated as an integer
    )

    $Hours * 60                         # Return the calculated number of minutes
}

# $minutes = ConvertTo-Minutes -Hours 3
# $minutes
# $minutes.GetType().Name

#endregion


#region Pattern 3 - Multiple typed parameters and a default value

function New-ResourceName {             # Define reusable resource-naming behavior
    param(                               # Declare all required inputs
        [string]$Application,            # Accept the application identifier
        [string]$Environment,            # Accept the environment identifier
        [string]$Region,                 # Accept the region identifier
        [int]$Instance = 1               # Accept an instance number; default to 1
    )

    "vm-$Application-$Environment-$Region-$Instance"
                                        # Return one generated resource name
}

# New-ResourceName `
#     -Application "core" `
#     -Environment "dev" `
#     -Region "deu"

# New-ResourceName `
#     -Application "api" `
#     -Environment "prod" `
#     -Region "deu" `
#     -Instance 2

#endregion


#region Pattern 4 - Function returning a structured object

function New-ServerReport {             # Define a function that returns structured data
    param(                               # Declare the values required to build the report
        [string]$Name,                   # Accept the server name
        [string]$Environment,            # Accept the server environment
        [string]$Status                  # Accept the server status
    )

    [PSCustomObject]@{                   # Create and return one custom PowerShell object
        Name        = $Name              # Expose the Name property
        Environment = $Environment       # Expose the Environment property
        Status      = $Status            # Expose the Status property
    }
}

# $server = New-ServerReport `
#     -Name "vm-core-dev-deu-1" `
#     -Environment "dev" `
#     -Status "Running"

# $server
# $server.Name
# $server.Status
# $server | Get-Member

#endregion


#region Pattern 5 - Function wrapping a tested pipeline

function Get-RunningServiceReport {     # Package reusable service-report logic
    param(                               # Declare the caller-controlled input
        [string]$Name = "*"              # Search all services when Name is omitted
    )

    Get-Service -Name $Name |            # Retrieve services matching the supplied name
        Where-Object Status -eq "Running" |
                                        # Keep only services whose Status is Running
        Sort-Object DisplayName |        # Sort the surviving objects by DisplayName
        Select-Object Name, DisplayName, Status
                                        # Return objects containing only these properties
}

# $services = Get-RunningServiceReport
# $services = Get-RunningServiceReport -Name "Win*"
# $services
# $services.Count
# $services | Get-Member

#endregion


#region Pattern 6 - Advanced function with verbose diagnostics

function Get-DeploymentStatus {         # Define a read-only deployment-report function
    [CmdletBinding()]                   # Enable advanced behavior and common parameters

    param(                               # Declare the function parameters
        [string]$Name = "core-api"       # Accept a name; default to core-api
    )

    Write-Verbose "Checking deployment '$Name'."
                                        # Write optional diagnostics to the Verbose stream

    [PSCustomObject]@{                   # Return reusable structured data
        Name      = $Name                # Expose the deployment name
        Status    = "Ready"              # Expose the current simulated status
        CheckedAt = Get-Date             # Expose the time of the status check
    }
}

# $deployment = Get-DeploymentStatus
# $deployment = Get-DeploymentStatus -Name "payments-api" -Verbose
# $deployment
# $deployment.Count

#endregion


#region Pattern 7 - Pipeline input by value

function Add-ResourceGroupPrefix {      # Define a transformation for complete input values
    [CmdletBinding()]                   # Make the function behave like an advanced cmdlet

    param(                               # Declare the pipeline-aware parameter
        [Parameter(                     # Add metadata to the ResourceGroup parameter
            Mandatory = $true,           # Require a value for this parameter
            ValueFromPipeline = $true    # Bind each complete pipeline value to this parameter
        )]
        [string]$ResourceGroup           # Store the current pipeline value as a string
    )

    process {                            # Run once for every value received from the pipeline
        "rg-$ResourceGroup"              # Return the current value with the rg- prefix
    }
}

# "core", "network", "security" |
#     Add-ResourceGroupPrefix

# $resourceGroups = "core", "network", "security" |
#     Add-ResourceGroupPrefix

# $resourceGroups

#endregion


#region Pattern 8 - Pipeline input by property name

function Get-ServiceStatus {            # Define a service-status lookup function
    [CmdletBinding()]                   # Enable advanced function behavior

    param(                               # Declare the pipeline-aware parameter
        [Parameter(                     # Add parameter-binding metadata
            Mandatory = $true,           # Require a service name
            ValueFromPipelineByPropertyName = $true
                                        # Bind from a matching object property
        )]
        [Alias("ServiceName")]           # Also accept a property named ServiceName
        [string]$Name                    # Bind from a Name property by default
    )

    process {                            # Run once for each object received from the pipeline
        Get-Service -Name $Name |        # Retrieve the service identified by the bound property
            Select-Object Name, DisplayName, Status
                                        # Return only the required service properties
    }
}

# Pipeline binding using a property named Name:

# [PSCustomObject]@{
#     Name = "Spooler"
# } | Get-ServiceStatus

# Pipeline binding using the ServiceName alias:

# [PSCustomObject]@{
#     ServiceName = "Spooler"
# } | Get-ServiceStatus

#endregion


#region Pattern 9 - Begin, process, and end lifecycle blocks

function ConvertTo-NormalizedResourceName {
                                        # Define a multi-stage pipeline function
    [CmdletBinding()]                   # Enable common parameters such as -Verbose

    param(                               # Declare the pipeline-aware input
        [Parameter(                     # Add parameter metadata
            Mandatory = $true,           # Require a resource name
            ValueFromPipeline = $true    # Accept each complete pipeline value
        )]
        [string]$Name                    # Store the current incoming name
    )

    begin {                              # Run once before the first pipeline object
        $processedCount = 0              # Initialize function-local state
        Write-Verbose "Starting normalization."
                                        # Report optional initialization information
    }

    process {                            # Run once for each pipeline object
        $processedCount++                # Count the current input object

        $normalizedName =                # Store the transformed name
            $Name.Trim().ToLowerInvariant()
                                        # Remove surrounding spaces and convert to lowercase

        [PSCustomObject]@{               # Return one structured object per input value
            OriginalName   = $Name       # Preserve the original input
            NormalizedName = $normalizedName
                                        # Expose the normalized value
        }
    }

    end {                                # Run once after the final pipeline object
        Write-Verbose "Processed $processedCount resource names."
                                        # Report optional completion information
    }
}

# $normalizedNames = `
#     " Core-API ", " NETWORK-HUB ", "Data-Store" |
#     ConvertTo-NormalizedResourceName -Verbose

# $normalizedNames

#endregion


#region Pattern 10 - Advanced function with ShouldProcess safety

function Set-DeploymentState {          # Define behavior that represents a state change
    [CmdletBinding(                     # Enable advanced cmdlet behavior
        SupportsShouldProcess = $true    # Enable the -WhatIf and -Confirm parameters
    )]

    param(                               # Declare the target and desired state
        [Parameter(Mandatory = $true)]   # Require the deployment name
        [string]$Name,                   # Store the target deployment name

        [Parameter(Mandatory = $true)]   # Require the desired deployment state
        [string]$State                   # Store the desired state
    )

    $action = "Set deployment state to '$State'"
                                        # Describe the proposed operation

    if ($PSCmdlet.ShouldProcess(         # Ask PowerShell whether execution should continue
        $Name,                           # Identify the target of the proposed operation
        $action                          # Identify the proposed action
    )) {
        [PSCustomObject]@{               # Return a safe simulated result
            Name      = $Name            # Expose the target deployment
            State     = $State           # Expose the requested state
            Changed   = $false           # Confirm that this example changed nothing real
            Simulated = $true            # Mark the result as a simulation
        }

        # A real state-changing command would be placed here.
        # This reference function intentionally changes nothing.
    }
}

# Safe preview; the protected block does not run:

# Set-DeploymentState `
#     -Name "core-api" `
#     -State "Ready" `
#     -WhatIf

# Interactive confirmation:

# Set-DeploymentState `
#     -Name "core-api" `
#     -State "Ready" `
#     -Confirm

#endregion


#region Pattern 11 - Filter function

<#
A filter is an official PowerShell function type designed for pipeline data.

All statements in a filter behave like statements in a process block.
The current pipeline object is available through $_.

This syntax is valid, but an advanced function with an explicit process
block is usually clearer and has higher interview and enterprise ROI.
#>

filter Get-RunningService {            # Define a filter for pipeline processing
    if ($_.Status -eq "Running") {      # Inspect the Status of the current object
        $_                              # Return the current object when it matches
    }
}

# Get-Service |
#     Get-RunningService |
#     Sort-Object DisplayName |
#     Select-Object Name, DisplayName, Status

#endregion


<#
HIGH-ROI SUMMARY

Simple reusable behavior:
    function Verb-Noun {
        # Logic
    }

Caller-provided input:
    param(
        [type]$Parameter
    )

Structured output:
    [PSCustomObject]@{
        Property = $Value
    }

Advanced behavior:
    [CmdletBinding()]

Optional diagnostics:
    Write-Verbose "Message"

Pipeline input by value:
    [Parameter(ValueFromPipeline = $true)]

Pipeline input by property name:
    [Parameter(ValueFromPipelineByPropertyName = $true)]

One execution per pipeline object:
    process {
        # Logic
    }

Initialization:
    begin {
        # Runs once before pipeline processing
    }

Finalization:
    end {
        # Runs once after pipeline processing
    }

Safe state changes:
    [CmdletBinding(SupportsShouldProcess = $true)]

    if ($PSCmdlet.ShouldProcess($Target, $Action)) {
        # State-changing operation
    }

DISCOVERY COMMANDS

Get-Command FunctionName
Get-Command FunctionName -Syntax
(Get-Command FunctionName).Definition
Get-Help FunctionName
Get-Help FunctionName -Full
Get-Verb
$result | Get-Member
$result.GetType().Name

LIVE-CODING QUESTIONS

1. What is the function name?
2. What inputs does it receive?
3. Are the inputs direct parameters or pipeline input?
4. Which command retrieves the original data?
5. What filtering or sorting is required?
6. Should the output be one value or a structured object?
7. Does the function need optional diagnostics?
8. Does the function change system state?
9. How will I invoke and verify it?

DO NOT ADD FEATURES WITHOUT A REQUIREMENT

No optional diagnostics:
    -> no Write-Verbose requirement

No advanced behavior:
    -> CmdletBinding may not be necessary

No pipeline input:
    -> no ValueFromPipeline
    -> no process block required

No system modification:
    -> no SupportsShouldProcess

One simple returned value:
    -> no PSCustomObject required

Several related fields:
    -> use PSCustomObject or Select-Object
#>
