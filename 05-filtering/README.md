# Chapter 05 — Filtering

Filtering allows us to keep only the objects that satisfy a condition.

Instead of manually inspecting hundreds of services, processes, users, files, or cloud resources, PowerShell can evaluate every object and return only the relevant ones.

## Why filtering exists

Infrastructure commands commonly return large collections.

Examples include:

- hundreds of Windows services;
- thousands of files;
- many Azure resources;
- Microsoft 365 users;
- Entra ID accounts;
- running processes;
- REST API results.

Usually, we do not need every object. We need objects that match a specific condition.

Examples:

- services that are stopped;
- processes consuming excessive memory;
- disabled user accounts;
- virtual machines in a specific region;
- files larger than a defined limit;
- resources missing a required tag.

PowerShell provides `Where-Object` for this purpose.

## Mental model

```text
Collection → test every object → keep matching objects
```

Example:

```powershell
1, 5, 10, 15, 20 |
    Where-Object {
        $_ -gt 10
    }
```

Output:

```text
15
20
```

For every number, PowerShell asks:

```text
Is this number greater than 10?
```

If the answer is `True`, the object continues through the pipeline.

If the answer is `False`, the object is removed from the pipeline.

## The current pipeline object

Inside the `Where-Object` script block, `$_` represents the current object being evaluated.

```powershell
Get-Service |
    Where-Object {
        $_.Status -eq "Stopped"
    }
```

For every service:

```text
$_         = current service object
$_.Status  = Status property of the current service
```

PowerShell keeps the service only when the comparison returns `True`.

## Comparison operators

PowerShell uses comparison operators instead of symbols such as `>` and `<`.

| Operator | Meaning |
|---|---|
| `-eq` | Equal to |
| `-ne` | Not equal to |
| `-gt` | Greater than |
| `-ge` | Greater than or equal to |
| `-lt` | Less than |
| `-le` | Less than or equal to |

Examples:

```powershell
10 -eq 10
10 -ne 5
10 -gt 5
10 -ge 10
5 -lt 10
5 -le 5
```

Each comparison produces a Boolean value:

```text
True
False
```

A single equals sign performs assignment:

```powershell
$status = "Running"
```

The `-eq` operator performs comparison:

```powershell
$status -eq "Running"
```

## Full and simplified syntax

Full syntax:

```powershell
Get-Service |
    Where-Object {
        $_.Status -eq "Stopped"
    }
```

Simplified syntax:

```powershell
Get-Service |
    Where-Object Status -eq "Stopped"
```

The simplified version is useful for basic property comparisons.

The full script-block version is required for more complex conditions and is easier to extend.

## Filtering text with wildcards

The `-like` operator performs wildcard matching.

```powershell
Get-Service |
    Where-Object {
        $_.Name -like "A*"
    }
```

Wildcard symbols:

| Symbol | Meaning |
|---|---|
| `*` | Zero or more characters |
| `?` | Exactly one character |

Examples:

```powershell
"Azure" -like "A*"
"PowerShell" -like "*Shell"
"Test1" -like "Test?"
```

Use `-notlike` when the text must not match the pattern.

```powershell
Get-Service |
    Where-Object {
        $_.Name -notlike "A*"
    }
```

## Combining conditions

Use `-and` when every condition must be true.

```powershell
Get-Service |
    Where-Object {
        $_.Status -eq "Stopped" -and
        $_.Name -like "A*"
    }
```

The service is retained only if:

```text
Status is Stopped
AND
Name begins with A
```

Use `-or` when at least one condition must be true.

```powershell
Get-Service |
    Where-Object {
        $_.Status -eq "Running" -or
        $_.Name -like "A*"
    }
```

A service is retained when it is running, its name begins with `A`, or both conditions are true.

Use `-not` to reverse a condition.

```powershell
Get-Service |
    Where-Object {
        -not ($_.Status -eq "Running")
    }
```

The equivalent and more readable comparison is:

```powershell
Get-Service |
    Where-Object {
        $_.Status -ne "Running"
    }
```

## Collection membership

Use `-in` to check whether one value exists in a collection.

```powershell
$targetServices = "Spooler", "WinRM"

Get-Service |
    Where-Object {
        $_.Name -in $targetServices
    }
```

Mental model:

```text
Current service name → is it inside the target list?
```

The direction matters:

```powershell
$item -in $collection
$collection -contains $item
```

Related operators:

| Operator | Meaning |
|---|---|
| `-in` | Item exists in collection |
| `-notin` | Item does not exist in collection |
| `-contains` | Collection contains item |
| `-notcontains` | Collection does not contain item |

## Regular-expression matching

The `-match` operator uses regular expressions.

```powershell
Get-Service |
    Where-Object {
        $_.Name -match "\d"
    }
```

This retains service names containing at least one digit.

Basic regular-expression symbols:

| Pattern | Meaning |
|---|---|
| `^A` | Begins with A |
| `A$` | Ends with A |
| `\d` | Contains a digit |
| `.` | Any single character |

Wildcards and regular expressions are different:

```powershell
$_.Name -like "A*"   # Wildcard pattern
$_.Name -match "^A"  # Regular expression
```

Use `-like` for straightforward text patterns. Use `-match` when the pattern requires more precise validation.

## Case sensitivity

PowerShell comparisons are case-insensitive by default.

```powershell
"Azure" -eq "azure"
```

Result:

```text
True
```

Prefix the operator with `c` when capitalization must match:

```powershell
"Azure" -ceq "azure"
```

Result:

```text
False
```

Examples:

| Default | Case-sensitive |
|---|---|
| `-eq` | `-ceq` |
| `-ne` | `-cne` |
| `-like` | `-clike` |
| `-match` | `-cmatch` |

Most PowerShell automation uses the default case-insensitive operators.

## Filtering processes by memory

`Get-Process` returns process objects.

One of their properties is `WorkingSet64`, which represents approximately how much physical memory the process currently uses.

```powershell
Get-Process |
    Where-Object {
        $_.WorkingSet64 -gt 200MB
    }
```

`WorkingSet64` is measured in bytes, but PowerShell understands size units such as:

```powershell
1KB
1MB
1GB
```

This makes comparisons easier to read:

```powershell
$_.WorkingSet64 -gt 200MB
```

## Detecting operational problems

Filtering becomes especially valuable when the condition represents an unhealthy state.

```powershell
$expectedServices = "EventLog", "Dnscache", "LanmanWorkstation"

Get-Service -Name $expectedServices |
    Where-Object {
        $_.Status -ne "Running"
    }
```

The expected state is that every service is running.

Therefore:

- no output means no problem was detected;
- returned objects represent possible problems.

This is a fundamental automation pattern:

```text
Get current state
        ↓
Compare with expected state
        ↓
Return only deviations
```

The same model applies to:

- stopped enterprise services;
- disabled Entra ID accounts;
- failed backups;
- unhealthy virtual machines;
- expiring certificates;
- missing Azure tags;
- unsuccessful deployment jobs.

## Pipeline order matters

This pipeline:

```powershell
Get-Service |
    Where-Object Status -eq "Stopped" |
    Select-Object -First 5
```

means:

```text
Get every service
→ keep stopped services
→ return the first five stopped services
```

Reversing the stages changes the result:

```powershell
Get-Service |
    Select-Object -First 5 |
    Where-Object Status -eq "Stopped"
```

This means:

```text
Get every service
→ keep the first five services
→ determine which of those five are stopped
```

Pipeline stages execute from left to right.

## Discovering available properties

Different commands return different object types.

Processes may have properties such as:

```text
Name
Id
WorkingSet64
CPU
```

Services may have properties such as:

```text
Name
DisplayName
Status
```

Use `Get-Member` instead of guessing:

```powershell
Get-Process | Get-Member
Get-Service | Get-Member
```

Engineering workflow:

```text
Inspect → identify useful properties → build conditions → verify results
```

## Common mistakes

### Using assignment instead of comparison

Incorrect:

```powershell
$_.Status = "Running"
```

Correct:

```powershell
$_.Status -eq "Running"
```

### Filtering the wrong property

```powershell
$_.Name
```

is the technical service name.

```powershell
$_.DisplayName
```

is the friendly display name.

Choose the property that represents the intended data.

### Incorrect wildcard pattern

Incorrect:

```powershell
$_.Name -like "A"
```

This matches only the exact text `A`.

Correct:

```powershell
$_.Name -like "A*"
```

This matches text beginning with `A`.

### Misunderstanding empty output

An empty result does not necessarily indicate an error.

It often means that no objects satisfied the condition.

## Enterprise examples

Azure virtual machines in a specific location:

```powershell
Get-AzVM |
    Where-Object {
        $_.Location -eq "westeurope"
    }
```

Disabled Entra ID users:

```powershell
Get-MgUser -All |
    Where-Object {
        $_.AccountEnabled -eq $false
    }
```

Large files:

```powershell
Get-ChildItem -File |
    Where-Object {
        $_.Length -gt 100MB
    }
```

Failed operations returned by an API:

```powershell
$response |
    Where-Object {
        $_.Status -eq "Failed"
    }
```

The syntax changes slightly between technologies, but the mental model remains identical.

## Interview recap

### What does `Where-Object` do?

It filters pipeline objects by evaluating a condition for each object and returning only objects for which the condition is true.

### What does `$_` mean?

It represents the current pipeline object being evaluated.

### What is the difference between `-eq` and `=`?

`-eq` compares values. `=` assigns a value to a variable or property.

### What is the difference between `-and` and `-or`?

`-and` requires every condition to be true. `-or` requires at least one condition to be true.

### What is the difference between `-like` and `-match`?

`-like` uses wildcard patterns. `-match` uses regular expressions.

### Why should filtering happen early?

Early filtering reduces the number of objects processed by later pipeline stages, improving clarity and potentially improving performance.

### How can filtering detect infrastructure problems?

Define the expected state and return only objects that deviate from it.

## Key takeaway

`Where-Object` answers one question:

```text
Should this object continue through the pipeline?
```

The complete mental model is:

```text
Get objects
→ inspect each current object with $_
→ evaluate a condition
→ retain only matching objects
→ send them to the next pipeline stage
```
