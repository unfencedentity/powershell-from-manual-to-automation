# Chapter 04 — Pipelines

## Objective

Understand how PowerShell passes objects between commands and how multiple commands can be connected into a single processing flow.

The objective is not to memorize pipeline syntax. It is to learn how to inspect, process, transform, count, and safely act on objects.

---

## Why pipelines exist

Infrastructure automation usually involves multiple stages:

1. Retrieve resources.
2. Keep the relevant resources.
3. Inspect or transform their properties.
4. Perform an action.
5. Return a useful result.

Without a pipeline, each stage would require separate variables and additional code.

PowerShell pipelines allow these stages to be connected directly:

```powershell
Get-Service |
    Select-Object -First 5 |
    ForEach-Object {
        $_.Name
    }
```

This can be read as:

> Get the Windows services, keep the first five, and return the name of each service.

---

## The pipeline operator

The symbol:

```powershell
|
```

is the **pipeline operator**.

It sends the output of the command on the left to the command on the right.

```text
Command A output → | → Command B input
```

Example:

```powershell
Get-Service | Measure-Object
```

`Get-Service` produces service objects.

`Measure-Object` receives and counts those objects.

---

## Pipeline operator versus pipeline

The symbol `|` is the pipeline operator.

The complete chain of connected commands is the pipeline.

```powershell
Get-Service |
    Select-Object -First 5 |
    Measure-Object
```

This is one pipeline containing:

- three commands;
- two pipeline operators.

---

## PowerShell passes objects

PowerShell pipelines normally pass .NET objects, not plain text.

```powershell
Get-Service | Get-Member
```

`Get-Service` produces objects that contain properties and methods.

Common service properties include:

```text
Name
DisplayName
Status
```

Because the pipeline transports objects, the next command can work directly with these properties.

---

## Processing each object

`ForEach-Object` executes a script block once for every object received through the pipeline.

```powershell
10, 20, 30 | ForEach-Object {
    $_ * 2
}
```

Output:

```text
20
40
60
```

The script block runs three times because the pipeline contains three input values.

---

## The current pipeline object

Inside `ForEach-Object`, the automatic variable:

```powershell
$_
```

represents the object currently being processed.

Example:

```powershell
Get-Service |
    Select-Object -First 3 |
    ForEach-Object {
        $_
    }
```

During processing:

```text
First iteration  → $_ is the first service
Second iteration → $_ is the second service
Third iteration  → $_ is the third service
```

`$_` represents the complete object, not one specific property.

---

## Accessing properties

The dot operator accesses a member of an object.

```powershell
$_.Name
```

returns the `Name` property of the current object.

```powershell
$_.Status
```

returns its `Status` property.

Example:

```powershell
Get-Service |
    Select-Object -First 3 |
    ForEach-Object {
        $_.Name
        $_.Status
    }
```

This produces two output values for every service.

---

## Calling methods

A property contains information.

A method performs an action.

```powershell
$_.Name
```

accesses the `Name` property.

```powershell
$_.Name.ToUpper()
```

calls the `ToUpper()` method on the string stored in `Name`.

Example:

```powershell
Get-Service |
    Select-Object -First 5 |
    ForEach-Object {
        $_.Name.ToUpper()
    }
```

The parentheses indicate that the method is being called.

Some methods do not require arguments:

```powershell
"powershell".ToUpper()
```

Other methods receive arguments:

```powershell
"cloud-dev".Replace("dev", "prod")
```

---

## Expressions inside strings

A simple variable can be inserted into a double-quoted string:

```powershell
$name = "Spooler"

"Service: $name"
```

For a complete expression such as a property or method call, use the subexpression operator:

```powershell
$()
```

Example:

```powershell
"Service: $($_.Name) | Status: $($_.Status)"
```

PowerShell evaluates each expression and inserts its result into the string.

---

## Separate output values versus one string

This block produces two output values for every service:

```powershell
ForEach-Object {
    $_.Name
    $_.Status
}
```

For three services:

```text
3 objects × 2 expressions = 6 output values
```

This block produces one formatted string for every service:

```powershell
ForEach-Object {
    "Name: $($_.Name) | Status: $($_.Status)"
}
```

For three services:

```text
3 objects × 1 expression = 3 output values
```

---

## Multiple pipeline stages

Every command receives the output produced by the previous stage.

```powershell
Get-Service |
    Select-Object -First 10 |
    Select-Object -First 4 |
    Measure-Object
```

The object flow is:

```text
All services
    ↓
First 10 services
    ↓
First 4 of those services
    ↓
Count the remaining 4
```

A command cannot receive objects that were already removed by a previous stage.

---

## Counting pipeline objects

`Measure-Object` counts the objects it receives.

```powershell
Get-Service | Measure-Object
```

Its result contains a `Count` property.

To return only the number:

```powershell
(Get-Service | Measure-Object).Count
```

The parentheses execute the pipeline as one expression.

`.Count` then accesses the `Count` property of the resulting object.

---

## Pipeline parameter binding

The receiving command must have a parameter that accepts pipeline input.

This can be inspected using PowerShell help:

```powershell
Get-Help Stop-Service -Parameter InputObject
```

The output can contain:

```text
Accept pipeline input? true (ByValue)
```

### ByValue

PowerShell attempts to bind the complete incoming object or value to a compatible parameter.

```powershell
Get-Service -Name Spooler |
    Stop-Service -WhatIf
```

`Get-Service` produces a `ServiceController` object.

`Stop-Service -InputObject` accepts that object type.

### ByPropertyName

PowerShell can also match a property of the incoming object to a parameter with the same name.

Conceptually:

```text
Incoming object property: Name = "Spooler"
Command parameter:        -Name
```

The property value can be bound to the matching parameter.

This becomes particularly useful when processing structured data imported from CSV files, JSON documents, or REST APIs.

---

## Safely testing actions

Some pipeline commands can modify the system.

For example:

```powershell
Get-Service |
    Select-Object -First 1 |
    Stop-Service
```

This attempts to stop a real Windows service.

Use `-WhatIf` to preview the operation safely:

```powershell
Get-Service |
    Select-Object -First 1 |
    Stop-Service -WhatIf
```

`-WhatIf` describes the intended action without performing it.

This is especially valuable when developing production automation.

---

## Common mistakes

### Missing pipeline operator

Incorrect:

```powershell
Get-Service |
    Select-Object -First 5
    ForEach-Object {
        $_.Name
    }
```

`ForEach-Object` does not receive the selected services because the second pipeline operator is missing.

Correct:

```powershell
Get-Service |
    Select-Object -First 5 |
    ForEach-Object {
        $_.Name
    }
```

### Calling a string method on the complete service object

Incorrect:

```powershell
$_.ToUpper()
```

`$_` is a service object, not a string.

Correct:

```powershell
$_.Name.ToUpper()
```

The `Name` property contains the string.

### Calling a method on a null value

If `ForEach-Object` receives no pipeline input, `$_` can be null.

Attempting this:

```powershell
$_.Name.ToUpper()
```

can produce:

```text
You cannot call a method on a null-valued expression.
```

When debugging, verify that the previous pipeline stage produces the expected objects.

### Forgetting to close a string

Incorrect:

```powershell
"Service: $($_.Name)
```

PowerShell continues displaying the continuation prompt:

```text
>>
```

Press `Ctrl + C` to cancel an incomplete command.

---

## Enterprise applications

PowerShell pipelines are commonly used to:

- process Windows services and processes;
- manage Active Directory and Microsoft Entra ID objects;
- retrieve and modify Azure resources;
- process Microsoft 365 users and mailboxes;
- transform CSV and JSON data;
- process REST API responses;
- build reports;
- perform bulk administrative actions;
- connect discovery, validation, execution, and reporting stages.

A common automation flow is:

```text
Retrieve objects
→ filter objects
→ select properties
→ perform an action
→ return structured results
```

---

## Interview recap

### What is the PowerShell pipeline?

The PowerShell pipeline passes .NET objects from one command to another.

### What does the pipeline operator do?

The `|` operator sends the output of the command on the left to the input of the command on the right.

### What does `$_` mean?

Inside commands such as `ForEach-Object`, `$_` represents the object currently being processed.

### What is the difference between `$_` and `$_.Name`?

`$_` represents the complete current object.

`$_.Name` returns only the value of its `Name` property.

### What is pipeline parameter binding?

Pipeline parameter binding is the mechanism PowerShell uses to connect incoming pipeline objects to parameters accepted by the receiving command.

### What is the difference between `ByValue` and `ByPropertyName`?

`ByValue` binds the incoming object directly to a compatible parameter type.

`ByPropertyName` matches a property of the incoming object to a parameter with the same name.

### Why use `-WhatIf`?

`-WhatIf` previews a potentially destructive operation without making the change.

---

## Interview example

```powershell
Get-Service |
    Select-Object -First 5 |
    ForEach-Object {
        "Name: $($_.Name.ToUpper()) | Status: $($_.Status)"
    }
```

Explanation:

> `Get-Service` produces Windows service objects. `Select-Object` keeps the first five objects. `ForEach-Object` processes them individually. `$_` represents the current service, `.Name` and `.Status` access its properties, and `ToUpper()` transforms the service name into uppercase text.

---

## Key takeaway

```text
Command
→ objects
→ pipeline
→ next command
→ processed output
```

PowerShell pipelines connect small commands into reusable automation flows while preserving the structure and capabilities of the objects being processed.
