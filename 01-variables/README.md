# Chapter 01 — Variables

## Objective

Learn how to store, name, update, and reuse values with PowerShell variables.

The objective is not only to remember the `$name = value` syntax. It is to understand how variables remove hardcoded repetition and make automation easier to read, change, and reuse.

By the end of this chapter, you should be able to:

- create and update variables;
- choose descriptive variable names;
- distinguish assignment from output;
- build strings from variable values;
- explain the difference between single-quoted and double-quoted strings;
- use subexpressions when a string contains a property or expression;
- identify and replace hardcoded values.

## Why variables exist

Automation must often use the same value in several places.

Without a variable:

```powershell
"rg-core-prod-weu"
"Deploying core to prod in weu"
```

If the environment changes, every hardcoded occurrence must be found and edited.

With variables:

```powershell
$application = "core"
$environment = "prod"
$region = "weu"

$resourceGroupName = "rg-$application-$environment-$region"
```

The value is defined once and reused wherever it is needed.

## Mental model

```text
Value
  ↓
Assign a meaningful name
  ↓
Store it in memory
  ↓
Read or update it later
  ↓
Reuse it in automation
```

A variable is a named reference to a value stored in the current PowerShell session.

```powershell
$environment = "dev"
```

This can be read as:

> Assign the string `"dev"` to the variable named `environment`.

## Variable syntax

A PowerShell variable name starts with `$`:

```powershell
$name = "Lucian"
$age = 33
$isAdmin = $true
```

The equals sign is the assignment operator. It stores the value on the right in the variable on the left.

```text
variable = value
```

Assignment normally produces no output:

```powershell
$environment = "dev"
```

Referencing the variable produces its current value:

```powershell
$environment
```

Output:

```text
dev
```

## Variables can be updated

A variable can receive a new value:

```powershell
$environment = "dev"
$environment = "prod"

$environment
```

Output:

```text
prod
```

The second assignment replaces the value currently referenced by the variable.

Any expression evaluated after the update uses the new value:

```powershell
$application = "core"
$environment = "dev"
$region = "weu"

$environment = "prod"
$resourceGroupName = "rg-$application-$environment-$region"

$resourceGroupName
```

Output:

```text
rg-core-prod-weu
```

## Variable naming

Choose names that explain the purpose of the value.

Clear names:

```powershell
$resourceGroupName
$subscriptionId
$environment
$serviceStatus
```

Unclear names:

```powershell
$a
$x
$temp
```

PowerShell variable names are case-insensitive:

```powershell
$environment = "dev"
$Environment
```

Both references identify the same variable. Use consistent casing because consistency improves readability even when PowerShell does not require it.

PowerShell commonly uses camelCase for local variables:

```powershell
$resourceGroupName
$deploymentStatus
```

## Variables store objects

Variables are not limited to text. They can reference many kinds of objects:

```powershell
$name = "Lucian"
$retryCount = 3
$isProduction = $false
$checkedAt = Get-Date
```

These values have different .NET types:

```powershell
$name.GetType().FullName
$retryCount.GetType().FullName
$isProduction.GetType().FullName
$checkedAt.GetType().FullName
```

Common results include:

```text
System.String
System.Int32
System.Boolean
System.DateTime
```

Objects and types are covered in greater depth in Chapter 03.

## String interpolation

PowerShell expands variable values inside double-quoted strings:

```powershell
$application = "cloud-org"

"Application: $application"
```

Output:

```text
Application: cloud-org
```

This behavior is called string interpolation.

Single-quoted strings are literal and do not expand variables:

```powershell
'Application: $application'
```

Output:

```text
Application: $application
```

Use double quotes when a variable or expression must be evaluated. Use single quotes when the text should remain literal.

## Expressions inside strings

A simple variable can be inserted directly:

```powershell
"Environment: $environment"
```

A property access or larger expression should use the subexpression operator `$()`:

```powershell
$checkedAt = Get-Date

"Year: $($checkedAt.Year)"
"Next retry: $($retryCount + 1)"
```

PowerShell evaluates the content inside `$()` before inserting the result into the string.

## Building values from variables

Variables can be combined into predictable infrastructure names:

```powershell
$application = "core"
$environment = "prod"
$region = "weu"

$resourceGroupName = "rg-$application-$environment-$region"

$resourceGroupName
```

Output:

```text
rg-core-prod-weu
```

The same values can be reused in another expression:

```powershell
"Deploying $application to $environment in $region"
```

Output:

```text
Deploying core to prod in weu
```

## Assignment versus comparison

The equals sign assigns a value:

```powershell
$environment = "prod"
```

PowerShell comparison operators test values:

```powershell
$environment -eq "prod"
```

Output:

```text
True
```

Do not use `=` when the requirement is to compare two values. Comparison operators are covered in Chapter 05.

## Common mistakes

### Using unclear names

```powershell
$a = "prod"
```

Prefer:

```powershell
$environment = "prod"
```

### Repeating hardcoded values

```powershell
"rg-core-prod-weu"
"Deploying core to prod"
```

Prefer one source for each value:

```powershell
$application = "core"
$environment = "prod"
$region = "weu"
```

### Expecting interpolation inside single quotes

```powershell
'Environment: $environment'
```

Use double quotes when expansion is required:

```powershell
"Environment: $environment"
```

### Forgetting the dollar sign

```powershell
environment
```

This is interpreted as a command name, not a variable reference.

Use:

```powershell
$environment
```

### Inspecting a stale derived value

```powershell
$environment = "dev"
$resourceGroupName = "rg-core-$environment-weu"

$environment = "prod"
$resourceGroupName
```

`$resourceGroupName` still contains the string created when `$environment` was `"dev"`. PowerShell does not automatically rebuild previously assigned strings.

Recalculate the derived value after changing its input:

```powershell
$resourceGroupName = "rg-core-$environment-weu"
```

## Enterprise applications

Variables commonly hold:

- tenant and subscription identifiers;
- resource group and server names;
- environment and region values;
- file paths;
- retry counts and timeout values;
- objects returned by commands;
- intermediate and final report data.

Example:

```powershell
$tenantId = "00000000-0000-0000-0000-000000000000"
$subscriptionId = "11111111-1111-1111-1111-111111111111"
$environment = "prod"
$resourceGroupName = "rg-core-$environment-weu"
```

These values make the intended Azure context explicit. Authentication establishes who the automation is, context identifies the tenant and subscription being targeted, and authorization determines what Azure RBAC permits.

## Interview recap

### What is a variable?

A variable is a named reference to a value stored in memory during a PowerShell session.

### Why are variables preferred over hardcoded values?

Variables improve readability, consistency, maintainability, and reuse by giving a value one meaningful source that can be updated centrally.

### What does the assignment operator do?

The `=` operator evaluates the expression on the right and assigns its result to the variable on the left.

### What is string interpolation?

String interpolation is the expansion of variables and expressions inside a double-quoted string.

### What is the difference between single and double quotes?

Double-quoted strings expand variables and subexpressions. Single-quoted strings normally preserve their contents literally.

### Does changing an input variable update an existing derived string automatically?

No. A previously assigned string keeps the value produced at assignment time and must be recalculated when its inputs change.

## Exercises

The practical files contain exercises for:

1. creating environment, application, and region variables;
2. building an Azure resource group name;
3. producing an interpolated deployment message;
4. updating a value and rebuilding the derived resource name.

Files:

- `exercise.ps1` — independent practice;
- `solution.ps1` — reference implementation.

## Key takeaway

```text
Hardcoded value
    ↓
Meaningful variable
    ↓
Reusable expression
    ↓
Easier change and safer automation
```

Variables give values meaningful names and allow automation logic to reuse those values without duplicating hardcoded data.
