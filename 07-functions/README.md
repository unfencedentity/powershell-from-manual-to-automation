# Functions

## Objective

Learn how to package reusable PowerShell logic into functions with clear names, predictable inputs, and reusable output.

This chapter focuses on the foundations required for live coding, infrastructure automation, and later advanced PowerShell topics.

## Why Functions Exist

Without functions, repeated logic must be copied every time it is needed.

Functions solve several engineering problems:

- repeated code;
- duplicated logic;
- unclear intent;
- inconsistent behavior;
- difficult testing;
- difficult maintenance;
- limited reuse.

A function gives a name to reusable behavior.

```powershell
function Show-Greeting {
    "Hello from PowerShell"
}
```

Defining the function does not run its body. It makes the function available in the current PowerShell session.

```powershell
Show-Greeting
```

Invoking the function executes the code inside its script block.

## Definition Versus Invocation

Function definition:

```powershell
function Show-Greeting {
    "Hello from PowerShell"
}
```

Function invocation:

```powershell
Show-Greeting
```

The definition creates the reusable command.

The invocation runs it.

The same function can be invoked multiple times:

```powershell
Show-Greeting
Show-Greeting
Show-Greeting
```

## Function Structure

A basic function contains:

```powershell
function Verb-Noun {
    param(
        # Parameters
    )

    # Reusable logic
}
```

The main parts are:

- `function` declares a function;
- `Verb-Noun` is the function name;
- `{ }` contains the executable code;
- `param()` declares the function interface;
- the function body contains the reusable logic.

## Verb-Noun Naming

PowerShell functions should follow the `Verb-Noun` convention.

Examples:

```powershell
Get-ServiceReport
New-VirtualMachineName
Test-AzureContext
Set-DeploymentState
```

The verb describes the operation.

The noun describes the resource or concept affected by the operation.

Use approved PowerShell verbs when possible:

```powershell
Get-Verb
```

Clear naming makes functions easier to discover, understand, and reuse.

## Parameters

Parameters allow callers to provide input to a function.

```powershell
function Get-DoubledNumber {
    param(
        [int]$Number
    )

    $Number * 2
}
```

Invocation:

```powershell
Get-DoubledNumber -Number 10
```

Output:

```text
20
```

In this example:

- `-Number` is the public parameter used by the caller;
- `10` is the argument supplied by the caller;
- `$Number` is the variable used inside the function;
- `[int]` specifies that the value should be an integer.

Chapter 08 covers parameters in greater depth.

## Parameter Flow

Consider this function:

```powershell
function Get-ServiceReport {
    param(
        [string]$Name = "*"
    )

    Get-Service -Name $Name
}
```

Invocation:

```powershell
Get-ServiceReport -Name "Win*"
```

The value flows through the function as follows:

```text
"Win*"
  → function parameter -Name
  → variable $Name
  → Get-Service parameter -Name
  → matching Windows services
```

The two `-Name` parameters belong to different commands:

- the first belongs to `Get-ServiceReport`;
- the second belongs to `Get-Service`.

The function receives the value and passes it to the underlying command.

## Default Parameter Values

A parameter can have a default value:

```powershell
param(
    [string]$Name = "*"
)
```

The caller can omit the parameter:

```powershell
Get-ServiceReport
```

PowerShell then uses `"*"` as the value.

The caller can override the default:

```powershell
Get-ServiceReport -Name "Win*"
```

## Function Output

PowerShell sends uncaptured output from a function to the success output stream.

```powershell
function Get-Numbers {
    10
    20
    30
}
```

Capture the output:

```powershell
$result = Get-Numbers
```

Inspect it:

```powershell
$result
$result.Count
$result[0]
$result[1]
$result[2]
```

Because the function produced three values, `$result` contains a collection with three elements.

## Returning Objects

Functions should usually return objects rather than preformatted text.

String output:

```powershell
"vm-core-dev-weu-1"
```

Structured object output:

```powershell
[PSCustomObject]@{
    Name        = "vm-core-dev-weu-1"
    Application = "core"
    Environment = "dev"
    Region      = "weu"
    Instance    = 1
}
```

Structured output can be:

- filtered;
- sorted;
- selected;
- grouped;
- exported;
- converted to JSON;
- passed through pipelines;
- consumed by other automation.

Example:

```powershell
$result.Name
$result.Environment
$result.Region
```

## PSCustomObject Versus Hashtable

A hashtable stores key-value pairs:

```powershell
$configuration = @{
    Environment = "dev"
    Region      = "weu"
}
```

A custom object exposes structured properties:

```powershell
$result = [PSCustomObject]@{
    Environment = "dev"
    Region      = "weu"
}
```

The syntax `@{ }` creates the key-value structure.

The cast `[PSCustomObject]` converts that structure into a custom PowerShell object.

```powershell
$result.Environment
$result.Region
```

A hashtable is not the same thing as a custom object, even though a hashtable is used to construct the custom object.

## Functions and Pipelines

A function can wrap an existing pipeline:

```powershell
function Get-ServiceReport {
    param(
        [string]$Name = "*"
    )

    Get-Service -Name $Name |
        Where-Object Status -eq "Running" |
        Sort-Object DisplayName |
        Select-Object Name, DisplayName, Status
}
```

This function:

1. gets matching services;
2. keeps only running services;
3. sorts them by display name;
4. returns selected properties.

Invocation:

```powershell
Get-ServiceReport -Name "Win*"
```

The function does not replace the underlying commands.

It packages tested commands behind a reusable interface.

## Accepting Pipeline Input

Functions can accept values from the pipeline.

```powershell
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
```

Invocation:

```powershell
"core", "network", "security" |
    Add-ResourceGroupPrefix
```

Output:

```text
rg-core
rg-network
rg-security
```

`ValueFromPipeline = $true` allows each incoming pipeline value to bind to `$ResourceGroup`.

The `process` block runs once for every incoming pipeline value.

## Advanced Functions

This line enables advanced function behavior:

```powershell
[CmdletBinding()]
```

An advanced function receives common PowerShell parameters such as:

- `-Verbose`;
- `-Debug`;
- `-ErrorAction`;
- `-WarningAction`.

Example:

```powershell
function Get-DeploymentStatus {
    [CmdletBinding()]
    param()

    Write-Verbose "Checking deployment..."

    [PSCustomObject]@{
        Name   = "core-api"
        Status = "Ready"
    }
}
```

Normal invocation:

```powershell
Get-DeploymentStatus
```

Verbose invocation:

```powershell
Get-DeploymentStatus -Verbose
```

## Verbose Output

`Write-Verbose` provides optional diagnostic information.

```powershell
Write-Verbose "Checking deployment..."
```

The verbose message is hidden by default.

It becomes visible when the caller uses `-Verbose`:

```powershell
Get-DeploymentStatus -Verbose
```

Verbose messages do not become part of the function's normal success output.

This is useful because diagnostic information should not contaminate the objects returned to the pipeline.

## Write-Host Versus Reusable Output

`Write-Host` displays information directly to the user interface.

```powershell
Write-Host "Deployment completed."
```

It should not be used as the primary output of a function when another command needs to capture and process the result.

Reusable output:

```powershell
[PSCustomObject]@{
    Name   = "core-api"
    Status = "Ready"
}
```

Display-only output:

```powershell
Write-Host "Deployment completed."
```

Interview distinction:

- displaying information is intended for a human;
- returning data is intended for PowerShell, pipelines, tests, and other automation.

## Accidental Output

Every uncaptured expression can become part of a function's output.

```powershell
function Get-DeploymentStatus {
    "Checking deployment..."

    [PSCustomObject]@{
        Name   = "core-api"
        Status = "Ready"
    }
}
```

Capture the result:

```powershell
$result = Get-DeploymentStatus
```

`$result` now contains two elements:

1. the string;
2. the custom object.

This can break downstream automation.

Use `Write-Verbose` for optional diagnostic messages:

```powershell
Write-Verbose "Checking deployment..."
```

## Function Scope

Variables created inside a function normally belong to the function's local scope.

```powershell
function Test-FunctionScope {
    $insideMessage = "Created inside the function"

    $insideMessage
}
```

Invoke the function:

```powershell
Test-FunctionScope
```

The value is returned as output, but the local variable does not remain available outside the function:

```powershell
$insideMessage
```

The function can return a value without exposing its internal local variable.

This separation reduces unintended changes to external state.

## Discovering Functions

Find the function:

```powershell
Get-Command Get-ServiceReport
```

Inspect its syntax:

```powershell
Get-Command Get-ServiceReport -Syntax
```

Inspect its definition:

```powershell
(Get-Command Get-ServiceReport).Definition
```

Read help when available:

```powershell
Get-Help Get-ServiceReport
```

Use command completion:

```powershell
Get-ServiceReport -<Ctrl+Space>
```

Discovery tools reduce the need to memorize every command and parameter.

## Inspecting Output

Capture function output:

```powershell
$result = Get-ServiceReport -Name "Win*"
```

Count returned objects:

```powershell
$result.Count
```

Inspect one object:

```powershell
$result[0]
```

Inspect its type:

```powershell
$result[0].GetType().Name
```

Discover properties and methods:

```powershell
$result | Get-Member
```

Use the discovered properties:

```powershell
$result.Name
$result.DisplayName
$result.Status
```

`Get-Member` helps answer:

- What type of object did I receive?
- Which properties can I read?
- Which methods can I invoke?
- Which property can I filter or sort by?

## Methods and Empty Parentheses

A method is behavior exposed by an object.

```powershell
$result.GetType()
```

`GetType` is a method.

The parentheses invoke the method.

Empty parentheses mean that the method receives zero arguments.

```powershell
$result.GetType().Name
```

This:

1. invokes `GetType()`;
2. receives a type object;
3. reads its `Name` property.

`param()` and `[CmdletBinding()]` also use parentheses, but they are PowerShell language constructs rather than object methods.

## Safe Change Simulation

Advanced functions can support PowerShell's safety mechanism:

```powershell
[CmdletBinding(SupportsShouldProcess = $true)]
```

This enables support for:

- `-WhatIf`;
- `-Confirm`.

The function must still call:

```powershell
$PSCmdlet.ShouldProcess()
```

Example:

```powershell
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
```

Safe test:

```powershell
Set-DeploymentState `
    -Name "core-api" `
    -State "Ready" `
    -WhatIf
```

`SupportsShouldProcess` advertises and enables the safety mechanism.

`ShouldProcess()` uses the mechanism at the exact point where the change would occur.

`-WhatIf` describes the proposed action without executing the protected block.

## Real Engineering Applications

Functions are useful for reusable engineering tasks such as:

- checking Windows service status;
- generating process and system reports;
- validating input;
- creating Azure resource names;
- checking the active Azure context;
- wrapping repeatable infrastructure logic;
- querying REST APIs;
- creating deployment reports;
- safely simulating resource changes;
- building reusable automation modules.

Example Azure naming function:

```powershell
function New-VirtualMachineName {
    param(
        [string]$Application,
        [string]$Environment,
        [string]$Region,
        [int]$Instance
    )

    "vm-$Application-$Environment-$Region-$Instance"
}
```

This creates one predictable naming interface for every caller.

## Building a Function During Live Coding

A reliable approach is:

1. identify the required behavior;
2. identify the inputs;
3. identify the expected output;
4. find the underlying PowerShell command;
5. test the command independently;
6. add filtering, sorting, and selection incrementally;
7. wrap the tested logic in a function;
8. add parameters;
9. invoke the function;
10. inspect the output.

Do not try to invent the entire function at once.

Example progression:

```powershell
Get-Service
```

```powershell
Get-Service |
    Where-Object Status -eq "Running"
```

```powershell
Get-Service |
    Where-Object Status -eq "Running" |
    Sort-Object DisplayName
```

```powershell
Get-Service |
    Where-Object Status -eq "Running" |
    Sort-Object DisplayName |
    Select-Object Name, DisplayName, Status
```

Only after the pipeline works should it be wrapped in a function.

## Common Mistakes

### Defining but not invoking

```powershell
function Show-Greeting {
    "Hello"
}
```

The function exists, but its body has not run.

Invoke it:

```powershell
Show-Greeting
```

### Confusing a parameter with a variable

```powershell
Get-ServiceReport -Name "Win*"
```

`-Name` is the parameter.

`"Win*"` is the argument.

Inside the function, the argument is available through `$Name`.

### Calling the wrong underlying command

A process report must use:

```powershell
Get-Process
```

It should not use:

```powershell
Get-Service
```

Correct syntax does not guarantee correct behavior.

### Filtering for the wrong value

A stopped service report requires:

```powershell
Where-Object Status -eq "Stopped"
```

Using `"Running"` produces valid PowerShell output, but it does not satisfy the requirement.

### Inspecting a stale variable

After invoking a function, capture its current output:

```powershell
$result = Get-StoppedServiceReport
```

Otherwise, `$result` may still contain output from an earlier command.

### Producing diagnostic text as normal output

Avoid:

```powershell
"Checking deployment..."
```

Prefer:

```powershell
Write-Verbose "Checking deployment..."
```

### Formatting inside reusable logic

Avoid returning only formatted text.

Return objects and allow the caller to choose how to display or export them.

## Interview Questions

### What problem do functions solve?

Functions package reusable behavior behind a clear name and predictable interface. They reduce duplication and make automation easier to test, maintain, and reuse.

### What is the difference between defining and invoking a function?

Defining a function registers its name and body in the current session. Invoking the function executes its body.

### What are a function's inputs and outputs?

Parameters define its public inputs. Values written to the success output stream become its outputs.

### Why should a function return objects?

Objects preserve structured properties and can be filtered, sorted, selected, exported, tested, and passed to other commands.

### What does `Get-Member` do?

It displays the type, properties, and methods of objects received through the pipeline.

### What is accidental output?

Any uncaptured value written to the success stream becomes part of the function's returned output, even when it was intended only as a status message.

### What does `Write-Verbose` provide?

It provides optional diagnostic information that appears when the caller uses `-Verbose`, without contaminating normal success output.

### What does `SupportsShouldProcess` do?

It enables the function to participate in PowerShell's change-safety mechanism, including `-WhatIf` and `-Confirm`. The function must use `$PSCmdlet.ShouldProcess()` around the operation that would make the change.

### How would this function be used in enterprise automation?

It could provide a standardized interface for reporting, validation, naming, context checking, deployment logic, or safe infrastructure changes across multiple scripts and workflows.

## Live-Coding Checklist

Before finishing a function, verify:

- Does the function use a clear `Verb-Noun` name?
- What inputs does it accept?
- Are the parameters used by the function body?
- Does the underlying command match the requirement?
- Is filtering based on the correct property and value?
- Is sorting in the correct direction?
- Does the function return reusable objects?
- Is diagnostic output separated from normal output?
- Does the function work with default input?
- Does it work with explicit input?
- Can the result be captured and inspected?
- Is any simulated change protected by `ShouldProcess()`?

## Exercises

The exercise file includes practice for:

1. defining and invoking a function;
2. using a typed parameter;
3. returning a structured object;
4. wrapping a service-report pipeline;
5. building a process report;
6. accepting pipeline input;
7. separating verbose messages from output;
8. safely simulating a change with `-WhatIf`.

## Key Takeaway

A function is a named, reusable unit of behavior with predictable inputs and outputs.

The most important mental model is:

```text
Input
  → function parameters
  → reusable logic
  → structured output
  → pipeline or caller
```

Write and test the underlying logic first.

Then package that working logic into a function.
