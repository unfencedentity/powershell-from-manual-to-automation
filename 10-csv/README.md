# Chapter 10 - CSV

## Objective

Learn how to use CSV files as structured input and output for PowerShell infrastructure automation.

This chapter extends the previous work with objects, pipelines, parameters, and files into a realistic enterprise scenario:

> Import a Windows Server inventory, validate its structure, process the server records, and export a structured report.

The objective is not merely to memorize `Import-Csv` and `Export-Csv`. The objective is to understand the complete data flow:

```text
PowerShell objects
    -> Export-Csv
    -> CSV text on disk
    -> Import-Csv
    -> New PowerShell objects
```

---

## Enterprise Scenario

An organization maintains an inventory of Windows servers.

Each server record contains:

* `ComputerName`
* `Environment`
* `Role`
* `ExpectedService`
* `Owner`

Example:

| ComputerName | Environment | Role     | ExpectedService | Owner        |
| ------------ | ----------- | -------- | --------------- | ------------ |
| SRV-APP-01   | Production  | Web      | W3SVC           | PlatformTeam |
| SRV-DB-01    | Production  | Database | MSSQLSERVER     | DataTeam     |
| SRV-TEST-01  | Test        | Web      | W3SVC           | QA-Team      |

Later chapters will use this inventory to validate connectivity, services, system information, desired state, and failures across multiple servers.

---

## PowerShell Objects Versus CSV Text

A PowerShell object exists in memory and contains properties, values, methods, and type information.

```powershell
$server = [PSCustomObject]@{
    ComputerName    = "SRV-APP-01"
    Environment     = "Production"
    Role            = "Web"
    ExpectedService = "W3SVC"
    Owner           = "PlatformTeam"
}
```

The object type is:

```powershell
$server.GetType().FullName
```

```text
System.Management.Automation.PSCustomObject
```

A CSV file is plain text stored on disk:

```csv
"ComputerName","Environment","Role","ExpectedService","Owner"
"SRV-APP-01","Production","Web","W3SVC","PlatformTeam"
```

The relationship is:

```text
Object                -> CSV data row
Property name         -> CSV header
Property value        -> CSV cell value
Collection of objects -> Multiple CSV data rows
```

The header row defines the column names. It is not a server record.

---

## Creating an In-Memory Inventory

Multiple server objects can be stored in an array:

```powershell
$server = [PSCustomObject]@{
    ComputerName    = "SRV-APP-01"
    Environment     = "Production"
    Role            = "Web"
    ExpectedService = "W3SVC"
    Owner           = "PlatformTeam"
}

$server2 = [PSCustomObject]@{
    ComputerName    = "SRV-DB-01"
    Environment     = "Production"
    Role            = "Database"
    ExpectedService = "MSSQLSERVER"
    Owner           = "DataTeam"
}

$server3 = [PSCustomObject]@{
    ComputerName    = "SRV-TEST-01"
    Environment     = "Test"
    Role            = "Web"
    ExpectedService = "W3SVC"
    Owner           = "QA-Team"
}

$servers = $server, $server2, $server3
```

Validate both the collection size and its contents:

```powershell
$servers.Count

$servers | ForEach-Object {
    $_.GetType().FullName
}
```

A correct item count does not guarantee valid contents. An array can contain three `$null` values and still have a count of three.

---

## Preparing a Safe Temporary Lab

All file operations should use an exact path inside a dedicated temporary directory.

```powershell
$labPath = Join-Path `
    -Path $env:TEMP `
    -ChildPath "powershell-csv-lab"
```

Validate the target before creating it:

```powershell
if (-not (Test-Path -Path $labPath -PathType Container)) {
    $labDirectory = New-Item -Path $labPath -ItemType Directory
}
else {
    $labDirectory = Get-Item -Path $labPath
}
```

Build the exact CSV path:

```powershell
$csvPath = Join-Path `
    -Path $labPath `
    -ChildPath "server-inventory.csv"
```

Remember:

```text
Join-Path -> constructs a path string
Test-Path -> checks existence and expected type
New-Item  -> creates the file-system item
Get-Item  -> retrieves the file-system object
```

A path, a file object, and the content inside the file are different things.

---

## Export-Csv

`Export-Csv` converts PowerShell objects into CSV text and writes that text to a file.

```powershell
$servers |
    Export-Csv -Path $csvPath -NoTypeInformation
```

The pipeline sends the server objects to `Export-Csv`.

`Export-Csv` uses:

* property names as CSV headers;
* property values as CSV values;
* one object per data row.

`Export-Csv` normally produces no console output. Its result is written to the file.

Verify the file:

```powershell
Test-Path -Path $csvPath -PathType Leaf
```

### NoTypeInformation

`-NoTypeInformation` prevents a `#TYPE` metadata line from being written by older PowerShell versions.

PowerShell 6 and later already omit this line by default, but the parameter makes the intent explicit and maintains compatibility with Windows PowerShell.

---

## Inspecting the Physical CSV

Use `Get-Content` to inspect the raw text:

```powershell
$csvLines = Get-Content -Path $csvPath

$csvLines
```

The file contains:

* one header row;
* one data row for each exported object.

With three server objects, the file contains four lines.

`Get-Content` reads the file as raw text. It does not interpret the CSV structure.

```powershell
$csvLines[0].GetType().FullName
```

```text
System.String
```

---

## Get-Item, Get-Content, and Import-Csv

These commands return different information:

| Expression                   | Result                                      |
| ---------------------------- | ------------------------------------------- |
| `$csvPath`                   | Path text as `System.String`                |
| `Get-Item -Path $csvPath`    | File object as `System.IO.FileInfo`         |
| `Get-Content -Path $csvPath` | Raw file content as `System.String` values  |
| `Import-Csv -Path $csvPath`  | Parsed data rows as `PSCustomObject` values |

`Get-Content` reads text.

`Import-Csv` understands headers, columns, delimiters, and data rows.

---

## Import-Csv

Import the CSV into PowerShell:

```powershell
$importedServers = @(
    Import-Csv -Path $csvPath
)
```

The array subexpression operator `@(...)` guarantees that `$importedServers` is an array even when the command returns zero or one record.

Validate the result:

```powershell
$importedServers.Count
$importedServers[0].GetType().FullName
```

Expected type:

```text
System.Management.Automation.PSCustomObject
```

`Import-Csv` does not restore the original objects. It creates new `PSCustomObject` instances based on the CSV structure.

Inspect an imported object:

```powershell
$importedServers[0] | Get-Member
```

The CSV headers become object properties.

---

## Imported CSV Values Are Strings

CSV is a text format. It does not preserve the original PowerShell property types.

After `Import-Csv`, property values are imported as `System.String`.

```powershell
$importedServers[0].ComputerName.GetType().FullName
```

```text
System.String
```

This becomes especially important when a CSV contains values representing:

* integers;
* Boolean values;
* dates;
* ports;
* memory sizes;
* timeouts.

For example, the text `"443"` must be explicitly converted before it is treated as an integer:

```powershell
$expectedPort = [int]"443"
```

Infrastructure automation should not assume that imported text already has the required type.

---

## Filtering Imported Records

Imported records are PowerShell objects and can be used in the pipeline.

Select Production servers:

```powershell
$productionServers = $importedServers |
    Where-Object Environment -eq "Production"
```

Use a script block when multiple conditions are required:

```powershell
$productionWebServers = $importedServers |
    Where-Object {
        $_.Environment -eq "Production" -and
        $_.Role -eq "Web"
    }
```

---

## Selecting Properties

Return only the properties required by the next operation:

```powershell
$importedServers |
    Select-Object ComputerName, Environment, ExpectedService
```

`Select-Object` creates new objects containing the selected properties.

Prefer objects over formatted strings when downstream pipeline processing is expected.

---

## Sorting Records

Sort the inventory by computer name:

```powershell
$importedServers |
    Sort-Object ComputerName
```

Sort by environment and then computer name:

```powershell
$importedServers |
    Sort-Object Environment, ComputerName
```

---

## Delimiters

CSV normally uses a comma as the delimiter.

```powershell
$servers |
    Export-Csv `
        -Path $csvPath `
        -Delimiter "," `
        -NoTypeInformation
```

Some regional configurations and applications use a semicolon:

```powershell
$servers |
    Export-Csv `
        -Path $csvPath `
        -Delimiter ";" `
        -NoTypeInformation
```

The import delimiter must match the export delimiter:

```powershell
$importedServers = Import-Csv `
    -Path $csvPath `
    -Delimiter ";"
```

If the delimiters do not match, PowerShell may interpret the entire row as one property.

---

## Encoding

Encoding determines how text characters are stored as bytes.

Specify encoding explicitly when predictable behavior is important:

```powershell
$servers |
    Export-Csv `
        -Path $csvPath `
        -Encoding utf8 `
        -NoTypeInformation
```

PowerShell 7 uses UTF-8 without a byte-order mark by default for `Export-Csv`.

Windows PowerShell 5.1 has different defaults, so scripts shared across environments should specify and test their encoding requirements.

---

## Overwrite Versus Append

By default, `Export-Csv` overwrites the target file:

```powershell
$servers |
    Export-Csv -Path $csvPath -NoTypeInformation
```

Use `-Append` only when records must be added to an existing CSV:

```powershell
$newServer |
    Export-Csv `
        -Path $csvPath `
        -NoTypeInformation `
        -Append
```

Before appending:

* verify the exact target;
* verify that the file exists;
* ensure the new objects use the same schema;
* avoid creating duplicate records.

For predictable reporting, regenerating the complete report is often safer than repeatedly appending data.

---

## Validating the Input File

Never assume that an input file exists or is the expected item type.

```powershell
if (-not (Test-Path -Path $csvPath -PathType Leaf)) {
    throw "CSV file not found: $csvPath"
}
```

After importing, verify that the file contains data rows:

```powershell
$importedServers = @(
    Import-Csv -Path $csvPath
)

if ($importedServers.Count -eq 0) {
    throw "The CSV file contains no server records."
}
```

---

## Validating Required Columns

Define the expected schema:

```powershell
$requiredColumns = @(
    "ComputerName"
    "Environment"
    "Role"
    "ExpectedService"
    "Owner"
)
```

Retrieve the actual property names:

```powershell
$actualColumns = @(
    $importedServers[0].PSObject.Properties.Name
)
```

Find missing columns:

```powershell
$missingColumns = @(
    $requiredColumns |
        Where-Object {
            $_ -notin $actualColumns
        }
)
```

Stop processing when required columns are missing:

```powershell
if ($missingColumns.Count -gt 0) {
    throw "Missing required CSV columns: $($missingColumns -join ', ')"
}
```

This validates the structure of the inventory before any server operation begins.

---

## Transforming Imported Records

Imported CSV values should be transformed into predictable output objects.

```powershell
$validatedServers = $importedServers |
    ForEach-Object {
        $hasRequiredValues =
            -not [string]::IsNullOrWhiteSpace($_.ComputerName) -and
            -not [string]::IsNullOrWhiteSpace($_.Environment) -and
            -not [string]::IsNullOrWhiteSpace($_.Role) -and
            -not [string]::IsNullOrWhiteSpace($_.ExpectedService) -and
            -not [string]::IsNullOrWhiteSpace($_.Owner)

        [PSCustomObject]@{
            ComputerName    = [string]$_.ComputerName
            Environment     = [string]$_.Environment
            Role            = [string]$_.Role
            ExpectedService = [string]$_.ExpectedService
            Owner           = [string]$_.Owner
            IsValid         = [bool]$hasRequiredValues
        }
    }
```

This creates a clear boundary:

```text
External CSV input
    -> Validate
    -> Convert
    -> Trusted internal objects
```

---

## Exporting a Structured Report

The validated objects can be exported as a new report:

```powershell
$reportPath = Join-Path `
    -Path $labPath `
    -ChildPath "server-inventory-report.csv"

$validatedServers |
    Sort-Object Environment, ComputerName |
    Export-Csv `
        -Path $reportPath `
        -Encoding utf8 `
        -NoTypeInformation
```

Verify the output:

```powershell
Test-Path -Path $reportPath -PathType Leaf
Get-Content -Path $reportPath
```

---

## Common Mistakes

### Quoting Object Variables

Incorrect:

```powershell
$servers = "$server", "$server2", "$server3"
```

The quotation marks convert the objects into strings.

Correct:

```powershell
$servers = $server, $server2, $server3
```

### Building the Array Before Creating the Objects

If the variables are `$null` when the array is created:

```powershell
$servers = $server, $server2, $server3
```

the array stores three `$null` values.

Creating the server variables afterward does not automatically update the existing array.

Correct order:

```text
Create objects
    -> Build array
    -> Validate array
    -> Export
```

### Confusing a Method with a Property

Incorrect:

```powershell
$server.GetType.FullName()
```

Correct:

```powershell
$server.GetType().FullName
```

`GetType()` is a method. `FullName` is a property.

### Using an Undefined Path Variable

A typo such as `$csvPat` instead of `$csvPath` produces a `$null` path.

PowerShell correctly rejects a null or empty `-Path` argument.

### Formatting Before Export

Do not send formatting objects to `Export-Csv`:

```powershell
$servers |
    Format-Table |
    Export-Csv -Path $csvPath
```

`Format-Table` is intended for display. It replaces the original objects with formatting instructions.

Export the original objects:

```powershell
$servers |
    Export-Csv -Path $csvPath -NoTypeInformation
```

---

## Infrastructure Automation Model

CSV processing follows the same enterprise automation workflow:

```text
Receive input
    -> Validate the file and required columns
    -> Import structured records
    -> Transform values into predictable types
    -> Discover current server state
    -> Compare current and desired state
    -> Change only what is necessary
    -> Verify the result
    -> Return objects
    -> Export a structured report
```

Chapter 10 implements the input, validation, transformation, and reporting foundations.

Later chapters will add:

* JSON configuration and desired state;
* REST API communication;
* per-server error isolation;
* reusable modules;
* production-grade advanced functions;
* complete enterprise automation.

---

## Interview Recap

### What is the difference between `Get-Content` and `Import-Csv`?

`Get-Content` returns the raw contents of a file as strings.

`Import-Csv` parses the header and data rows and returns one `PSCustomObject` for each data row.

### What does `Export-Csv` receive?

It receives PowerShell objects through the pipeline and converts their properties into CSV columns.

### Does CSV preserve PowerShell types?

No. CSV is a text format. Imported property values are strings and must be explicitly converted when other types are required.

### What does `-NoTypeInformation` do?

It prevents legacy PowerShell type metadata from being added to the CSV output.

### Does `Export-Csv` append by default?

No. It overwrites the target file by default. `-Append` must be specified explicitly.

### Why validate required columns?

A file may exist and still have an invalid schema. Column validation prevents incorrect or unsafe processing.

### Why should formatting commands not be used before `Export-Csv`?

Formatting commands create objects intended for display. They do not preserve the original infrastructure objects required for structured export.

---

## Must Know by Heart

```text
Export-Csv:
PowerShell objects -> CSV text on disk

Import-Csv:
CSV text on disk -> New PSCustomObject records

Get-Content:
File content -> Raw strings

Get-Item:
File-system item -> FileInfo or DirectoryInfo
```

Also remember:

* one object becomes one CSV data row;
* property names become headers;
* imported CSV values are strings;
* the header row is not a data record;
* delimiters must match during export and import;
* `Export-Csv` overwrites by default;
* `-Append` must be explicit;
* validate the path, data rows, and required columns;
* transform external input into predictable internal objects;
* export objects, not formatted output.

---

## Exercise

Build a PowerShell workflow that:

1. Creates a collection of fictional Windows server objects.
2. Uses the required inventory properties.
3. Creates a dedicated temporary lab directory.
4. Builds exact input and report paths with `Join-Path`.
5. Exports the inventory to CSV.
6. Verifies and inspects the physical file.
7. Imports the CSV as PowerShell objects.
8. Verifies the imported object and property types.
9. Filters, selects, and sorts imported servers.
10. Validates that the file contains data rows.
11. Validates all required columns.
12. Transforms imported records into predictable output objects.
13. Adds a Boolean validation result.
14. Exports a structured validation report.
15. Verifies the final report.

All operations must use exact paths inside the dedicated temporary lab.

---

## Chapter Outcome

After completing this chapter, you should be able to:

* explain the difference between objects and CSV text;
* export object collections as structured reports;
* import CSV rows as PowerShell objects;
* inspect imported objects and property types;
* filter, select, and sort imported data;
* control delimiters and encoding;
* understand overwrite and append behavior;
* validate file existence and CSV schema;
* transform untrusted strings into predictable objects;
* use CSV files as enterprise automation input and output.
