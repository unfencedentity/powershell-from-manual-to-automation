# Chapter 03 — Objects

## Objective

Understand how PowerShell represents data as objects and how to discover the information and behavior available on an unfamiliar object.

The objective is not to memorize every property and method. It is to build a discovery-first workflow using types, `Get-Member`, property access, and method invocation.

By the end of this chapter, you should be able to:

- explain what an object is;
- distinguish properties from methods;
- identify an object's .NET type;
- inspect an object with `Get-Member`;
- access properties with the dot operator;
- invoke methods with parentheses;
- explain why a returned value may differ from the original object;
- use discovery instead of guessing available members.

## Why objects matter

Infrastructure data has structure.

A Windows service is not only displayed text. It contains related information such as:

```text
Name
DisplayName
Status
StartType
CanStop
```

It can also expose operations through methods.

PowerShell represents values as .NET objects so commands can pass structured information to variables, pipelines, filters, reports, and other automation.

## Mental model

```text
Object
├── Type       → what kind of value is this?
├── Properties → what information does it contain?
└── Methods    → what operations can it perform?
```

Discovery workflow:

```text
Obtain an object
       ↓
Identify its type
       ↓
Inspect its members
       ↓
Choose a property or method
       ↓
Verify the returned value
```

## What is an object?

An object is an instance of a type that can contain data and expose behavior.

Example:

```powershell
$name = "Lucian"
```

`$name` is not only visible text. It references an object of type:

```text
System.String
```

The type defines which properties and methods are available.

## Identifying an object's type

Call `GetType()` on an object:

```powershell
$name.GetType()
```

Return only the complete type name:

```powershell
$name.GetType().FullName
```

Output:

```text
System.String
```

Other examples:

```powershell
(42).GetType().FullName
($true).GetType().FullName
(Get-Date).GetType().FullName
```

Common results:

```text
System.Int32
System.Boolean
System.DateTime
```

Parentheses ensure that PowerShell evaluates the expression before `.GetType()` is called.

## Inspecting objects with Get-Member

Use `Get-Member` when you do not know what an object contains or can do:

```powershell
$name | Get-Member
```

`Get-Member` reports:

- the object's type name;
- available properties;
- available methods;
- other member types exposed by PowerShell.

You can narrow the result:

```powershell
$name | Get-Member -MemberType Property
$name | Get-Member -MemberType Method
```

The object flows through the pipeline to `Get-Member`. Pipeline behavior is covered in Chapter 04.

## Properties

Properties expose information about an object.

Use the dot operator to access a property:

```powershell
$name.Length
```

If `$name` contains `"Lucian"`, the output is:

```text
6
```

The general pattern is:

```text
object.property
```

Examples:

```powershell
$currentDate = Get-Date

$currentDate.Year
$currentDate.Month
$currentDate.Day
```

The date remains a structured `System.DateTime` object. Each expression retrieves one property value.

## Methods

Methods expose operations an object can perform.

Call a method with parentheses:

```powershell
$name.ToUpper()
```

The general pattern is:

```text
object.Method(arguments)
```

A method with no arguments still requires parentheses:

```powershell
$name.Trim()
$name.ToUpper()
```

A method that requires arguments receives them inside the parentheses:

```powershell
$resourceName = "vm-core-prod-weu"

$resourceName.Contains("prod")
$resourceName.Replace("prod", "dev")
$resourceName.Split("-")
```

## Property versus method

Compare:

```powershell
$name.Length
$name.ToUpper()
```

`Length` is a property. It returns information already associated with the string.

`ToUpper()` is a method. It performs an operation and returns a result.

The syntax helps identify the difference:

```text
.Property
.Method()
```

When unsure, verify with:

```powershell
$name | Get-Member
```

## Method arguments

Some methods require additional input.

Inspect a method signature:

```powershell
$resourceName | Get-Member -Name Replace
```

Then call it with the required arguments:

```powershell
$resourceName.Replace("prod", "dev")
```

Conceptually:

```text
original value → method + arguments → returned value
```

The strings `"prod"` and `"dev"` are arguments supplied to the method.

## Returned values and immutability

Many string methods return a new string and do not modify the original value:

```powershell
$resourceName = "vm-core-prod-weu"

$resourceName.Replace("prod", "dev")
$resourceName
```

Output:

```text
vm-core-dev-weu
vm-core-prod-weu
```

Capture the result when it must be reused:

```powershell
$updatedResourceName = $resourceName.Replace("prod", "dev")
```

Now the two variables reference different strings:

```powershell
$resourceName
$updatedResourceName
```

This distinction is important in debugging: displaying a transformed result does not necessarily update the original variable.

## Methods can return collections

`Split()` returns multiple string objects:

```powershell
$resourceName = "vm-core-prod-weu"
$parts = $resourceName.Split("-")

$parts
```

Output:

```text
vm
core
prod
weu
```

The returned array can be indexed:

```powershell
$parts[0]
$parts[2]
```

Output:

```text
vm
prod
```

This connects object methods to the array concepts from Chapter 02.

## Cmdlets return objects

Objects are not limited to manually created variables. PowerShell cmdlets return objects:

```powershell
Get-Date
Get-Process
Get-Service
Get-ChildItem
```

Inspect command output directly:

```powershell
Get-Date | Get-Member
Get-Process | Get-Member
Get-Service | Get-Member
```

Or capture one object first:

```powershell
$currentDate = Get-Date

$currentDate.GetType().FullName
$currentDate | Get-Member
```

This discovery-first process works even when the object type is unfamiliar.

## Objects versus displayed text

The console may display an object as a table or a list. That presentation is not the object itself.

For example:

```powershell
Get-Process
```

may display selected columns, but the underlying process objects contain additional properties that can be discovered:

```powershell
Get-Process | Get-Member
```

Do not infer the complete object structure only from the default console view.

Formatting commands should normally remain outside reusable data-processing logic. Later chapters use structured objects so downstream commands can continue filtering, selecting, sorting, and exporting their properties.

## Expressions inside strings

A property access inside a double-quoted string requires a subexpression:

```powershell
$currentDate = Get-Date

"Year: $($currentDate.Year)"
```

Without `$()`, PowerShell cannot interpret the entire property expression as intended.

The same pattern works for a method call:

```powershell
"Normalized name: $($resourceName.ToLower())"
```

## Discovery-first engineering

When working with unfamiliar data, use evidence instead of guessing:

```powershell
$result = Get-Something

$result.GetType().FullName
$result | Get-Member
```

Then inspect the relevant member:

```powershell
$result.PropertyName
$result.MethodName()
```

Additional discovery tools used later in the repository include:

```powershell
Get-Command Get-Something -Syntax
Get-Help Get-Something -Examples
Get-Help Get-Something -Parameter ParameterName
```

## Common mistakes

### Guessing a property name

```powershell
$object.State
```

If the real property is `Status`, the guessed expression will not produce the intended value.

Inspect first:

```powershell
$object | Get-Member
```

### Forgetting method parentheses

Incorrect:

```powershell
$name.ToUpper
```

Correct:

```powershell
$name.ToUpper()
```

### Expecting a string method to modify the original variable

```powershell
$resourceName.Replace("prod", "dev")
$resourceName
```

Capture the returned string when it is needed later:

```powershell
$resourceName = $resourceName.Replace("prod", "dev")
```

### Calling a member on $null

```powershell
$result = $null
$result.GetType()
```

There is no object on which to call the method. Verify that the preceding command produced a value before inspecting it.

### Confusing displayed columns with all available properties

Default formatting shows only a view. Use `Get-Member` to discover the actual members of the object.

### Converting structured data to text too early

Once useful fields are flattened into a display string, later commands cannot access them as separate properties. Preserve objects until formatting is the explicit purpose.

## Enterprise applications

Enterprise commands commonly return objects representing:

- Windows services and processes;
- files and directories;
- Azure resources and contexts;
- Entra ID users and groups;
- REST API responses;
- deployment and health-check results.

Example discovery flow:

```powershell
$services = Get-Service

$services | Get-Member
$services[0].Name
$services[0].Status
```

Structured objects allow later automation to filter, sort, validate, export, and transmit data without parsing console text.

## Interview recap

### What is an object?

An object is an instance of a type that can contain data through properties and expose behavior through methods.

### What is the difference between a property and a method?

A property exposes information about an object. A method performs an operation and is invoked with parentheses.

### How do you identify an object's type?

Call `GetType()` and inspect its `FullName` property:

```powershell
$object.GetType().FullName
```

### How do you inspect an unfamiliar object?

Send it to `Get-Member` to discover its type, properties, methods, and other members.

### Why might Replace() leave the original string unchanged?

Strings are immutable. `Replace()` returns a new string, so its result must be captured if it will be reused.

### Why is PowerShell object-oriented?

PowerShell commands exchange structured .NET objects rather than relying only on plain text, allowing downstream code to work directly with types, properties, and methods.

### Is the console table the complete object?

No. It is a formatting view. The underlying object may expose many additional members discoverable with `Get-Member`.

## Exercises

The practical files contain exercises for:

1. identifying a complete .NET type name;
2. inspecting members;
3. accessing a property and invoking methods;
4. testing whether a string contains a value;
5. replacing part of a string;
6. splitting a string and indexing the returned array;
7. reading properties from a `System.DateTime` object.

Files:

- `exercise.ps1` — independent practice;
- `solution.ps1` — reference implementation.

## Key takeaway

```text
Do not guess the object
        ↓
Inspect its type and members
        ↓
Access properties or invoke methods
        ↓
Preserve structured output for reuse
```

PowerShell becomes easier to learn when unfamiliar values are treated as discoverable objects rather than undocumented text.
