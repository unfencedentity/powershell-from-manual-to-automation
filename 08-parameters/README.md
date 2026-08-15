# Chapter 08 — Parameters

## Objective

Learn how to design predictable PowerShell interfaces that receive, convert, validate, and expose caller input without requiring changes to internal implementation logic.

The objective is not to memorize parameter attributes. It is to translate requirements into clear inputs that can be consumed by humans, scripts, CI/CD workflows, GitHub Actions, and enterprise automation.

By the end of this chapter, you should be able to:

- distinguish parameters from arguments;
- declare function and script parameters with `param()`;
- use named and positional binding intentionally;
- select appropriate parameter types;
- explain type conversion and conversion failures;
- design optional and mandatory parameters;
- define sensible default values;
- choose between `[bool]` and `[switch]`;
- distinguish a scalar parameter from a collection parameter;
- validate input before processing begins;
- define parameter aliases;
- inspect explicitly supplied parameters with `$PSBoundParameters`;
- invoke commands with splatting;
- read command syntax and parameter help;
- explain basic parameter sets and pipeline binding;
- design an interface from an English requirement.

## Why parameters exist

Without parameters, input is hardcoded inside implementation logic:

```powershell
function Get-Greeting {
    "Hello, Ana"
}
```

Changing the name requires editing the function.

Parameters separate caller input from implementation:

```powershell
function Get-Greeting {
    param(
        [string]$Name
    )

    "Hello, $Name"
}
```

The same function can now be reused:

```powershell
Get-Greeting -Name "Ana"
Get-Greeting -Name "Mihai"
```

Parameters create a public contract:

```text
caller chooses input
        ↓
parameter interface receives input
        ↓
implementation processes input
        ↓
function returns reusable output
```

## Requirement-to-code method

Translate every requirement in this order:

```text
Requirement
  → command or function name
  → caller inputs
  → parameter names
  → parameter types
  → mandatory or optional
  → default values
  → validation
  → processing
  → structured output
  → safety
  → verification
```

Example requirement:

> Generate a virtual machine name for an application and environment. Use instance 1 when the caller does not provide an instance number.

Extracted design:

```text
Function name  → New-VirtualMachineName
Application    → string, mandatory
Environment    → string, mandatory, validated
Instance       → integer, optional, default 1
Output         → generated name and input fields
Safety         → read-only operation
Verification   → inspect the returned object
```

## Parameter versus argument

Consider:

```powershell
Get-Greeting -Name "Ana"
```

The parts are:

```text
Get-Greeting → command
Name         → parameter name
-Name        → parameter token used during invocation
"Ana"        → argument supplied by the caller
$Name        → parameter variable inside the function
```

A parameter defines an available input. An argument is a value supplied for that input during one invocation.

## The param block

`param()` declares a public input interface:

```powershell
function Get-Greeting {
    param(
        [string]$Name
    )

    "Hello, $Name"
}
```

Mental model:

```text
param()          → declares the parameter list
[string]         → declares the expected type
$Name            → stores the bound value
function body    → uses the parameter variable
```

For a function, the `param()` block belongs inside the function.

A script can also expose parameters at the beginning of the file:

```powershell
param(
    [string]$Environment
)

"Environment: $Environment"
```

Invocation:

```powershell
./deploy.ps1 -Environment "prod"
```

## Named and positional binding

Named invocation identifies the destination parameter explicitly:

```powershell
Get-Greeting -Name "Ana"
```

Conceptually:

```text
-Name "Ana" → $Name = "Ana"
```

Positional invocation omits the parameter name:

```powershell
Get-Greeting "Mihai"
```

PowerShell binds the first positional argument to the first positional parameter.

With several parameters:

```powershell
function Get-PersonalGreeting {
    param(
        [string]$Greeting,
        [string]$Name
    )

    "$Greeting, $Name"
}
```

Named arguments can be written in either order:

```powershell
Get-PersonalGreeting -Name "Ana" -Greeting "Hello"
```

Positional arguments depend on declared order:

```powershell
Get-PersonalGreeting "Hello" "Ana"
```

Named parameters are generally clearer for scripts, reviews, logs, and enterprise automation.

## Parameter variables and internal variables

A parameter variable receives caller input:

```powershell
$Name
```

An internal variable stores an implementation value:

```powershell
$message = "Hello, $Name"
```

These roles are different:

```text
$Name    → public input received through the interface
$message → internal implementation detail
```

Function-local variables do not automatically become variables in the caller's scope. The caller receives values written to the success output stream.

## Parameter types

Parameter types communicate intent and give the function a predictable internal value.

High-value types include:

```powershell
[string]
[int]
[bool]
[switch]
[string[]]
[object]
```

### String

Use `[string]` for one text value:

```powershell
param(
    [string]$Name
)
```

Common examples include service names, environments, regions, tenant identifiers, subscription identifiers, and resource group names.

### Integer

Use `[int]` for a whole number:

```powershell
param(
    [int]$Hours
)
```

Examples include instance numbers, retry counts, limits, and time intervals measured as whole units.

### Boolean

Use `[bool]` when the caller should supply an explicit Boolean value:

```powershell
param(
    [bool]$Enabled
)
```

Invocation:

```powershell
Show-FeatureState -Enabled $true
Show-FeatureState -Enabled $false
```

### Switch

Use `[switch]` when the presence of an option should enable behavior:

```powershell
param(
    [switch]$IncludeStopped
)
```

Invocation:

```powershell
Get-ServiceReport
Get-ServiceReport -IncludeStopped
```

Mental model:

```text
switch absent  → IsPresent is False
switch present → IsPresent is True
```

The parameter variable is a `System.Management.Automation.SwitchParameter`. Its `IsPresent` property is a `System.Boolean`.

### String array

Use `[string[]]` when the caller may provide several text values:

```powershell
param(
    [string[]]$Environment
)
```

Invocation:

```powershell
Get-EnvironmentReport -Environment "dev", "test", "prod"
```

### Object

Use `[object]` only when the interface genuinely needs to accept values of different or unknown types:

```powershell
param(
    [object]$InputObject
)
```

Prefer a more specific type when the requirement permits one. Specific types communicate intent and detect incompatible input earlier.

## Type conversion

PowerShell attempts type conversion during parameter binding.

```powershell
function ConvertTo-Minutes {
    param(
        [int]$Hours
    )

    $Hours * 60
}
```

An integer is accepted directly:

```powershell
ConvertTo-Minutes -Hours 3
```

A compatible numeric string is converted:

```powershell
ConvertTo-Minutes -Hours "3"
```

An incompatible string produces a binding error:

```powershell
ConvertTo-Minutes -Hours "three"
```

Flow:

```text
caller argument
  → locate parameter
  → attempt conversion
  → conversion succeeds: execute function body
  → conversion fails: report binding error; do not execute body
```

Typed parameters are not a replacement for all validation. A value can have the correct type while still being unacceptable for the requirement.

## Optional parameters

Parameters are optional by default:

```powershell
param(
    [string]$Name
)
```

If the caller omits `Name`, the function still runs. The resulting value depends on the type and any assigned default.

Optional does not mean unimportant. It means the function has defined behavior when the caller omits the input.

## Default values

A default value provides predictable behavior when an optional argument is omitted:

```powershell
param(
    [int]$Instance = 1
)
```

Caller accepts the default:

```powershell
New-ResourceName -Application "core" -Environment "dev"
```

Caller overrides it:

```powershell
New-ResourceName -Application "core" -Environment "dev" -Instance 2
```

Use a default only when the requirement defines a safe and unsurprising value.

## Mandatory parameters

Use the `Parameter` attribute when the caller must supply a value:

```powershell
param(
    [Parameter(Mandatory)]
    [string]$Name
)
```

Mental model:

```text
param()                 → parameter list
[Parameter(Mandatory)] → binding behavior
[string]                → type
$Name                   → parameter variable
```

If a mandatory argument is missing, an interactive session may prompt for it. Non-interactive automation should always supply mandatory values explicitly.

## The Parameter attribute

`[Parameter()]` configures an individual parameter:

```powershell
[Parameter(
    Mandatory,
    ValueFromPipeline
)]
```

It is separate from the type declaration:

```text
[Parameter()] → binding metadata
[string]      → type metadata
$Name         → value storage
```

Boolean attribute properties such as `Mandatory`, `ValueFromPipeline`, and
`SupportsShouldProcess` are true when written without an assigned value:

```powershell
[Parameter(Mandatory, ValueFromPipeline)]
```

This concise form is supported in PowerShell 3.0 and later. Use an explicit
value when setting a property to false or when a Boolean value comes from a
variable.

Using `[Parameter()]` makes the function advanced. An additional empty
`[CmdletBinding()]` is therefore unnecessary. Use `[CmdletBinding()]` when the
function needs function-level configuration such as `SupportsShouldProcess`,
`DefaultParameterSetName`, or `PositionalBinding`.

## Single values versus collections

Use `[string]` for one value:

```powershell
[string]$Environment
```

Use `[string[]]` for several values:

```powershell
[string[]]$Environment
```

One array argument is not the same as several pipeline input objects:

```powershell
Get-EnvironmentReport -Environment "dev", "test", "prod"
```

The function receives one array argument.

```powershell
"dev", "test", "prod" | Add-ResourceGroupPrefix
```

The pipeline enumerates the collection and sends separate input objects. A pipeline-aware `process` block runs once per incoming object.

## Validation attributes

Validation rejects unacceptable input before the main function logic runs.

### ValidateSet

Restrict input to known values:

```powershell
[ValidateSet("dev", "test", "prod")]
[string]$Environment
```

Use it for small, stable sets such as approved environment names.

### ValidateRange

Restrict numeric input to a range:

```powershell
[ValidateRange(1, 10)]
[int]$Instance
```

### ValidatePattern

Require text to match a regular expression:

```powershell
[ValidatePattern("^rg-[a-z0-9-]+$")]
[string]$ResourceGroupName
```

### ValidateNotNullOrWhiteSpace

Reject `$null`, empty strings, and strings containing only whitespace:

```powershell
[ValidateNotNullOrWhiteSpace()]
[string]$Application
```

Validation should represent a real requirement. Avoid adding arbitrary restrictions that the caller did not request.

## Parameter aliases

An alias allows another name to identify the same parameter:

```powershell
param(
    [Alias("ServiceName")]
    [string]$Name
)
```

Both invocations bind to `$Name`:

```powershell
Get-ServiceLookupRequest -Name "Spooler"
Get-ServiceLookupRequest -ServiceName "Spooler"
```

Aliases can support familiar terminology and property-name pipeline binding. Use them intentionally; too many names can make an interface harder to discover.

## PSBoundParameters

`$PSBoundParameters` is an automatic dictionary containing parameters explicitly supplied by the caller.

```powershell
function Get-ReportRequest {
    param(
        [string]$Name = "*",
        [switch]$IncludeStopped
    )

    $PSBoundParameters.ContainsKey("Name")
}
```

Compare:

```powershell
Get-ReportRequest
Get-ReportRequest -Name "Win*"
```

In both cases `$Name` has a value, but only the second invocation contains `Name` in `$PSBoundParameters`.

Use `$PSBoundParameters` when logic must distinguish an explicit caller choice from a default value.

## Splatting

Splatting passes a dictionary of named arguments to a command:

```powershell
$parameters = @{
    Application       = "core"
    Environment       = "prod"
    Instance          = 2
    ResourceGroupName = "rg-core-prod-weu"
}

New-DeploymentRequest @parameters
```

Distinguish:

```text
$parameters  → normal variable reference
@parameters  → splat the dictionary as named parameters
```

Splatting improves readability when an invocation contains many named parameters and makes conditional parameter construction easier.

## Parameter discovery

Do not rely only on memory.

Read syntax:

```powershell
Get-Command Get-Service -Syntax
```

Read one parameter:

```powershell
Get-Help Get-Service -Parameter Name
```

Read examples:

```powershell
Get-Help Get-Service -Examples
```

Inspect objects:

```powershell
Get-Service | Get-Member
```

Use command completion:

```text
Ctrl+Space
```

## Reading command syntax

PowerShell syntax uses conventions:

```text
[-Name <String[]>]
```

General interpretation:

```text
square brackets → optional syntax element
-Name           → parameter name
<String[]>      → expected argument type; array of strings
```

Do not confuse syntax brackets with the brackets used for a PowerShell type declaration.

Several syntax lines often indicate parameter sets. A parameter set is an allowed combination of parameters for one command.

This chapter focuses on recognizing parameter sets conceptually. Advanced parameter-set implementation belongs in Chapter 15 — Advanced Functions.

## Pipeline parameter binding

### By value

`ValueFromPipeline` binds the complete incoming object:

```powershell
param(
    [Parameter(ValueFromPipeline)]
    [string]$ResourceGroup
)
```

### By property name

`ValueFromPipelineByPropertyName` binds a matching property value:

```powershell
param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias("ServiceName")]
    [string]$Name
)
```

Mental model:

```text
ValueFromPipeline
→ bind the complete incoming value

ValueFromPipelineByPropertyName
→ find a matching property or alias
→ bind that property value
```

Pipeline-aware functions normally perform per-object work in `process`.

## Script and CI/CD interfaces

Parameters make context explicit for non-interactive automation:

```powershell
param(
    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$SubscriptionId,

    [ValidateSet("dev", "test", "prod")]
    [string]$Environment
)
```

Context model:

```text
Authentication → Who am I?
Context        → Which tenant and subscription am I targeting?
Authorization  → What does Azure RBAC allow me to do?
```

For GitHub Actions in `cloud-org-infra`, the authentication flow remains:

```text
GitHub workflow
  → OIDC token
  → Entra federated credential
  → service principal
  → Azure token
  → Azure RBAC
  → Azure resources
```

Parameters pass context into automation. They do not replace authentication and should not introduce long-lived client secrets.

## Output quality

Parameters define input. Function output remains a separate design decision.

Prefer structured output:

```powershell
[PSCustomObject]@{
    Environment = $Environment
    Name        = $resourceName
    GeneratedAt = Get-Date
}
```

Continue distinguishing:

```text
Write-Verbose        → optional diagnostics
success output       → reusable data
formatted text       → presentation for a human
PSCustomObject       → structured automation output
```

Do not place formatting commands inside reusable functions unless formatting is the explicit purpose.

## Common mistakes

### Confusing parameter and argument

```text
Name  → parameter
"Ana" → argument
```

### Assuming PowerShell understands semantic intent

Positional binding uses position, not the meaning of words.

### Choosing string for several values

Use `[string[]]` when the requirement allows multiple strings.

### Using bool for a natural command-line flag

Prefer `[switch]` when presence should enable optional behavior.

### Assuming typed means fully validated

`[int]` confirms a convertible integer, but `ValidateRange` may still be required.

### Adding mandatory without a requirement

Mandatory input changes the public contract and can break non-interactive callers.

### Treating a default as explicitly supplied

Use `$PSBoundParameters.ContainsKey()` when the distinction matters.

### Passing a hashtable without splatting

```powershell
$parameters  # one hashtable object
@parameters  # named arguments
```

### Expecting the function body to handle conversion failures

Parameter conversion and validation normally happen before the body executes.

## Enterprise applications

Parameters support reusable automation for:

- Windows service and process reports;
- Azure resource naming;
- tenant and subscription selection;
- environment validation;
- read-only infrastructure reports;
- safe optional behavior;
- CI/CD workflows;
- GitHub Actions;
- modules and advanced functions;
- REST API and configuration inputs.

## Live-coding method

During an interview:

1. restate the requirement;
2. identify the function name;
3. list caller-controlled inputs;
4. choose parameter names and types;
5. decide mandatory, optional, and default behavior;
6. add only required validation;
7. write the smallest working `param()` block;
8. implement processing;
9. return reusable output;
10. invoke with representative values;
11. test invalid input;
12. explain the interface professionally.

## Interview recap

### What is the difference between a parameter and an argument?

A parameter defines an input accepted by a command. An argument is a value supplied for that parameter during invocation.

### What is parameter binding?

Parameter binding is the process PowerShell uses to associate caller arguments with parameters, perform required conversions, and apply validation.

### What is the difference between named and positional binding?

Named binding identifies the target parameter explicitly by name. Positional binding selects the target based on argument and parameter position.

### Why use typed parameters?

Typed parameters communicate intent, provide a predictable internal type, and reject input that cannot be converted.

### What is the difference between bool and switch?

A Boolean parameter expects an explicit `$true` or `$false` argument. A switch is normally enabled by its presence and disabled by its absence.

### What does Mandatory do?

It tells parameter binding that the caller must supply a value before the command can execute successfully.

### Why use validation attributes?

They reject values that violate a requirement before the main processing logic runs.

### What does PSBoundParameters contain?

It contains parameters explicitly bound during the current invocation, including their bound values.

### What is splatting?

Splatting passes a collection of named or positional arguments to a command using a variable.

### How do arrays differ from pipeline input?

An array parameter can receive one collection argument. Pipeline input normally arrives as separately enumerated objects and is processed one object at a time.

### What are parameter sets?

Parameter sets define valid combinations of parameters for one command. They allow one command to expose several mutually exclusive invocation patterns.

## Exercises

The practical files contain exercises for:

1. parameter and argument identification;
2. named and positional binding;
3. integer conversion;
4. explicit Boolean input;
5. switch parameter behavior;
6. optional parameters and default values;
7. mandatory parameters;
8. string-array input;
9. validation attributes;
10. parameter aliases;
11. `$PSBoundParameters`;
12. named parameter splatting;
13. command discovery and syntax interpretation;
14. pipeline binding by value and property name;
15. cumulative enterprise interface design;
16. cumulative Windows service inventory with validation, switches, and both
    pipeline binding modes.

Files:

- `exercise.ps1` — independent practice;
- `solution.ps1` — reviewed reference implementations.

## Completion criteria

This chapter is complete when you can:

- design a parameter interface from a written requirement;
- write its `param()` block independently;
- select appropriate types and collection shapes;
- explain how arguments are bound and converted;
- choose mandatory, optional, default, Boolean, and switch behavior;
- validate input intentionally;
- inspect explicit caller choices;
- use splatting for readable invocations;
- discover unfamiliar syntax without memorization;
- explain how the interface is consumed by enterprise automation.

## Key takeaway

```text
Clear requirement
  → predictable parameter contract
  → early conversion and validation
  → focused implementation
  → reusable structured output
  → safer enterprise automation
```

Parameters are the public interface of PowerShell automation. Good parameter design makes behavior easier to understand, invoke, validate, test, and integrate.
