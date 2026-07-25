# Chapter 06 — Selecting and Sorting

PowerShell commands often return more objects and properties than we need.

This chapter introduces two cmdlets that help transform those results:

```powershell
Select-Object
Sort-Object
```

They answer two different questions:

```text
Select-Object → What information should remain?
Sort-Object   → In what order should the objects appear?
```

## Why selecting exists

A Windows service object contains many properties:

```text
Name
DisplayName
Status
ServiceType
StartType
CanStop
MachineName
...
```

An engineer may need only:

```text
Name
Status
```

Returning only relevant properties makes output:

- easier to read;
- easier to export;
- easier to send to another system;
- more suitable for reports;
- more predictable for automation.

Example:

```powershell
Get-Service |
    Select-Object Name, Status
```

## Why sorting exists

Infrastructure commands do not always return objects in the order required by an engineer.

We may need:

- processes using the most memory;
- newest or oldest files;
- users sorted alphabetically;
- virtual machines grouped by location;
- failed operations ordered by date;
- services sorted by status.

Example:

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending
```

## Mental model

```text
Get objects
    ↓
Filter relevant objects
    ↓
Sort objects
    ↓
Select the required number and properties
```

The common pipeline pattern is:

```powershell
Get-Something |
    Where-Object { condition } |
    Sort-Object Property |
    Select-Object -First 10 Property1, Property2
```

Each stage has a separate responsibility:

```text
Where-Object  → which objects satisfy a condition?
Sort-Object   → in what order should they appear?
Select-Object → how many objects and which properties remain?
```

## Selecting properties

```powershell
Get-Service |
    Select-Object Name, Status
```

`Select-Object` creates new objects containing only the selected properties.

Conceptually:

```text
Original service object
├── Name
├── DisplayName
├── Status
├── ServiceType
├── StartType
├── CanStop
└── many other properties

Selected object
├── Name
└── Status
```

Each selected object remains structured.

This structure is useful for:

- tables;
- CSV exports;
- reports;
- APIs;
- additional pipeline processing.

## Selecting a number of objects

Select the first objects:

```powershell
1..10 |
    Select-Object -First 3
```

Output:

```text
1
2
3
```

Select the last objects:

```powershell
1..10 |
    Select-Object -Last 3
```

Output:

```text
8
9
10
```

Skip the first objects:

```powershell
1..10 |
    Select-Object -Skip 3
```

Output:

```text
4
5
6
7
8
9
10
```

Mental model:

```text
-First → retain objects from the beginning
-Last  → retain objects from the end
-Skip  → discard objects from the beginning
```

## Limiting objects and selecting properties

Both operations can be performed together:

```powershell
Get-Service |
    Select-Object -First 5 Name, Status
```

This means:

```text
Keep five objects
+
Keep two properties from each object
```

Using table terminology:

```text
-First 5     → five rows
Name, Status → two columns
```

## Extracting a property value

Compare these commands:

```powershell
Get-Service |
    Select-Object -First 5 Name
```

```powershell
Get-Service |
    Select-Object -First 5 -ExpandProperty Name
```

The first command produces objects containing a `Name` property:

```text
Object
└── Name = "Spooler"
```

The second command extracts the value stored inside that property:

```text
"Spooler"
```

The difference can be verified with `GetType()`.

Object with a selected property:

```powershell
(
    Get-Service |
        Select-Object -First 1 Name
).GetType().FullName
```

Typical result:

```text
System.Management.Automation.PSCustomObject
```

Expanded value:

```powershell
(
    Get-Service |
        Select-Object -First 1 -ExpandProperty Name
).GetType().FullName
```

Result:

```text
System.String
```

Mental model:

```text
Select-Object Name
→ structured object: { Name = "Spooler" }

Select-Object -ExpandProperty Name
→ simple value: "Spooler"
```

Use structured objects when producing tables and reports.

Use expanded values when another command or function requires the values directly.

## Selecting unique values

`-Unique` removes repeated values.

To discover the service states currently present:

```powershell
Get-Service |
    Sort-Object Status |
    Select-Object -ExpandProperty Status -Unique
```

Possible output:

```text
Stopped
Running
```

Sorting first places identical values together before the unique selection.

When several properties are selected, uniqueness applies to the complete combination.

```powershell
Select-Object Status, Name -Unique
```

This checks whether each `Status` and `Name` combination is unique, not whether `Status` alone is unique.

## Sorting objects

Ascending order is the default:

```powershell
Get-Service |
    Sort-Object Name
```

Descending order must be requested explicitly:

```powershell
Get-Service |
    Sort-Object Name -Descending
```

Examples:

```powershell
Get-ChildItem |
    Sort-Object Length -Descending
```

```powershell
Get-Process |
    Sort-Object CPU -Descending
```

```powershell
Get-Service |
    Sort-Object Status
```

PowerShell sorts the actual property values, not only the text displayed in the console.

## Sorting typed values

The `Status` property returned by `Get-Service` is not ordinary text. It is an enumeration value:

```text
System.ServiceProcess.ServiceControllerStatus
```

Its states have internal numeric values.

For example:

```text
Stopped = 1
Running = 4
```

Therefore:

```powershell
Get-Service |
    Sort-Object Status
```

places `Stopped` before `Running`.

This is not alphabetical text sorting. PowerShell is sorting typed values.

## Sorting by multiple properties

```powershell
Get-Service |
    Sort-Object Status, Name
```

PowerShell sorts:

1. first by `Status`;
2. then by `Name` inside each status group.

Mental model:

```text
Status
└── Name
```

Enterprise examples include:

```text
Department → UserName
Location   → ResourceName
Severity   → Date
Status     → ServerName
```

## Pipeline order matters

Consider:

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5
```

This means:

```text
Sort every process by memory
→ keep the five largest
```

Reversing the stages changes the result:

```powershell
Get-Process |
    Select-Object -First 5 |
    Sort-Object WorkingSet64 -Descending
```

This means:

```text
Keep the first five processes received
→ sort only those five
```

The first pipeline finds the five largest processes.

The second pipeline does not.

## Calculated properties

Sometimes the required property does not exist in the desired format.

`WorkingSet64` represents process memory in bytes:

```powershell
Get-Process |
    Select-Object -First 5 Name, WorkingSet64
```

Large byte values are difficult to read.

A calculated property can convert bytes to megabytes:

```powershell
Get-Process |
    Select-Object -First 5 Name, @{
        Name = "MemoryMB"
        Expression = {
            $_.WorkingSet64 / 1MB
        }
    }
```

The calculated property contains two main components:

```powershell
@{
    Name = "MemoryMB"
    Expression = {
        $_.WorkingSet64 / 1MB
    }
}
```

`Name` defines the name of the new property.

`Expression` defines how its value is calculated for each current object.

Inside `Expression`, `$_` represents the current pipeline object.

## Rounding calculated values

Use the .NET `Math` class to round the result:

```powershell
[math]::Round(value, 2)
```

Complete example:

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5 Name, Id, @{
        Name = "MemoryMB"
        Expression = {
            [math]::Round($_.WorkingSet64 / 1MB, 2)
        }
    }
```

The result becomes a readable report:

```text
Name                Id     MemoryMB
----                --     --------
brave               12844  655.96
Memory Compression  3084   533.39
explorer            7572   310.84
```

## Understanding the CPU property

The `CPU` property returned by `Get-Process` represents accumulated processor time in seconds.

```powershell
Get-Process |
    Select-Object Name, Id, CPU
```

A value such as:

```text
1737.29
```

means the processor has executed work for that process for approximately 1,737 accumulated seconds.

It does not mean:

- that the application started 1,737 seconds ago;
- that the process currently uses 1,737 percent CPU;
- that the process has run continuously for that amount of wall-clock time.

Some process objects may contain `$null` in the `CPU` property.

They can be removed before sorting:

```powershell
Get-Process |
    Where-Object {
        $_.CPU -ne $null
    } |
    Sort-Object CPU -Descending |
    Select-Object -First 5 Name, Id, CPU
```

## Processes versus services

A process is an executing instance of a program.

It has properties such as:

```text
Name
Id
CPU
WorkingSet64
StartTime
```

A service is a registered Windows background capability managed by the Service Control Manager.

It has properties such as:

```text
Name
DisplayName
Status
ServiceType
StartType
```

Mental model:

```text
Service → What background capability does Windows manage?
Process → What code is currently executing and consuming resources?
```

Several processes may have the same name but different IDs:

```text
brave  12844
brave  12408
brave  11512
```

Windows service names must be unique on the local system.

## Selecting data for CSV

CSV means Comma-Separated Values.

A CSV file represents tabular data:

```csv
Name,Status
Spooler,Running
WinRM,Stopped
EventLog,Running
```

PowerShell objects map naturally to CSV:

```text
Object   → row
Property → column
```

Example:

```powershell
Get-Service |
    Select-Object Name, Status |
    Export-Csv -Path ".\services.csv" -NoTypeInformation
```

Selecting only relevant properties produces clean exports.

CSV is covered in detail in Chapter 10.

## Enterprise examples

### Largest processes

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10 Name, Id, WorkingSet64
```

### Stopped services sorted by name

```powershell
Get-Service |
    Where-Object Status -eq "Stopped" |
    Sort-Object Name |
    Select-Object Name, DisplayName, Status
```

### Largest files

```powershell
Get-ChildItem -File |
    Sort-Object Length -Descending |
    Select-Object -First 10 Name, Length
```

### Azure virtual machines

```powershell
Get-AzVM |
    Sort-Object Location, Name |
    Select-Object Name, Location, ResourceGroupName
```

### Disabled users

```powershell
Get-MgUser -All |
    Where-Object AccountEnabled -eq $false |
    Sort-Object DisplayName |
    Select-Object DisplayName, UserPrincipalName
```

The cmdlets change between technologies, but the pipeline mental model remains the same.

## Common mistakes

### Selecting before sorting

Incorrect when looking for the largest objects:

```powershell
Get-Process |
    Select-Object -First 5 |
    Sort-Object WorkingSet64 -Descending
```

Correct:

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5
```

### Confusing filtering with selecting

```powershell
Where-Object
```

retains objects based on conditions.

```powershell
Select-Object
```

chooses the number of objects or their properties.

### Using `Select-Object` without arguments

```powershell
Get-Service |
    Select-Object
```

No useful selection was requested. In ordinary pipelines, this stage is redundant and should be removed.

### Expanding when structure is required

```powershell
Select-Object -ExpandProperty Name
```

returns simple values.

If a report or CSV requires named columns, retain structured properties:

```powershell
Select-Object Name, Status
```

### Sorting formatted text instead of original values

Perform filtering, sorting, and selecting while objects are still structured.

Formatting should happen only at the end when output is intended for a human.

## Interview recap

### What does `Select-Object` do?

It selects objects, limits their number, extracts property values, or creates objects containing specified properties.

### What does `Sort-Object` do?

It orders objects based on one or more property values.

### What is the difference between `Select-Object Name` and `-ExpandProperty Name`?

`Select-Object Name` returns objects containing a `Name` property.

`-ExpandProperty Name` returns the values stored in that property.

### How do you obtain the five processes using the most memory?

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5
```

### Why does pipeline order matter?

Every stage receives the result produced by the previous stage. Selecting objects before sorting creates a different result from sorting before selecting.

### What is a calculated property?

A property created during selection whose value is calculated from the current object.

### Why are calculated properties useful?

They convert, rename, combine, or format data into a form appropriate for reports and downstream automation.

### What is the difference between `CPU` and current CPU percentage?

`CPU` is accumulated processor time. It is not the current real-time utilization percentage.

## Key takeaway

Use each cmdlet for one clear responsibility:

```text
Get objects
→ Where-Object chooses matching objects
→ Sort-Object determines their order
→ Select-Object determines the final objects and properties
```

The core engineering pattern is:

```powershell
Get-Something |
    Where-Object { condition } |
    Sort-Object Property -Descending |
    Select-Object -First 10 Property1, Property2
```
