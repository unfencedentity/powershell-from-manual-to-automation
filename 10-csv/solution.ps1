# Chapter 10 - CSV
# Solution: Windows Server Inventory and Validation

# Build the dedicated temporary lab path.

$parentPath = $env:TEMP

$labPath = Join-Path `
    -Path $parentPath `
    -ChildPath "powershell-csv-lab"

# Create or retrieve the lab directory.

if (-not (Test-Path -Path $labPath -PathType Container)) {
    $labDirectory = New-Item `
        -Path $labPath `
        -ItemType Directory
} else {
    $labDirectory = Get-Item -Path $labPath
}

# Build the exact input and report paths.

$csvPath = Join-Path `
    -Path $labPath `
    -ChildPath "server-inventory.csv"

$reportPath = Join-Path `
    -Path $labPath `
    -ChildPath "server-inventory-report.csv"

# Create the in-memory server inventory.

$servers = @(
    [PSCustomObject]@{
        ComputerName    = "SRV-APP-01"
        Environment     = "Production"
        Role            = "Web"
        ExpectedService = "W3SVC"
        Owner           = "PlatformTeam"
    }

    [PSCustomObject]@{
        ComputerName    = "SRV-DB-01"
        Environment     = "Production"
        Role            = "Database"
        ExpectedService = "MSSQLSERVER"
        Owner           = "DataTeam"
    }

    [PSCustomObject]@{
        ComputerName    = "SRV-TEST-01"
        Environment     = "Test"
        Role            = "Web"
        ExpectedService = "W3SVC"
        Owner           = "QA-Team"
    }
)

# Export the source inventory.
# The file is intentionally overwritten to avoid duplicate rows.

$servers |
    Export-Csv `
        -Path $csvPath `
        -NoTypeInformation `
        -Encoding utf8

# Verify and inspect the physical CSV.

$csvFileExists = Test-Path `
    -Path $csvPath `
    -PathType Leaf

$csvLines = @(Get-Content -Path $csvPath)

function Get-ServerInventory {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path
    )

    # Verify that the input path points to an existing file.

    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        Write-Warning "Inventory file was not found: $Path"
        return
    }

    # Import the CSV as a predictable collection.

    $inventory = @(Import-Csv -Path $Path)

    if ($inventory.Count -eq 0) {
        Write-Warning "Inventory file contains no data rows: $Path"
        return
    }

    # Define and validate the required inventory columns.

    $requiredColumns = @(
        "ComputerName"
        "Environment"
        "Role"
        "ExpectedService"
        "Owner"
    )

    $actualColumns = $inventory[0].PSObject.Properties.Name

    $missingColumns = $requiredColumns |
        Where-Object {
            $_ -notin $actualColumns
        }

    if ($missingColumns.Count -gt 0) {
        Write-Warning "Inventory is missing required columns: $($missingColumns -join ', ')"
        return
    }

    # Transform imported strings into predictable output objects.

    $inventory |
        ForEach-Object {
            [PSCustomObject]@{
                ComputerName    = [string]$_.ComputerName
                Environment     = [string]$_.Environment
                Role            = [string]$_.Role
                ExpectedService = [string]$_.ExpectedService
                Owner           = [string]$_.Owner
                IsProduction    = [bool](
                    $_.Environment -eq "Production"
                )
            }
        }
}

# Import, validate and transform the inventory.

$inventoryResult = @(
    Get-ServerInventory -Path $csvPath
)

if ($inventoryResult.Count -eq 0) {
    Write-Warning "No validated server objects were returned."
    return
}

# Sort and export the validated report.
# Append is intentionally not used to keep repeated runs predictable.

$inventoryResult |
    Sort-Object -Property ComputerName |
    Export-Csv `
        -Path $reportPath `
        -NoTypeInformation `
        -Encoding utf8

# Verify and import the generated report.

$reportFileExists = Test-Path `
    -Path $reportPath `
    -PathType Leaf

$finalReport = @(Import-Csv -Path $reportPath)

# Return structured verification information.

[PSCustomObject]@{
    LabDirectoryType     = $labDirectory.GetType().FullName
    InputFileExists      = $csvFileExists
    ReportFileExists     = $reportFileExists
    SourceServerCount    = $servers.Count
    ValidatedServerCount = $inventoryResult.Count
    RawHeaderType        = $csvLines[0].GetType().FullName
    BooleanPropertyType  = $inventoryResult[0].IsProduction.GetType().FullName
}

# Display the final report properties.

$finalReport |
    Select-Object -Property `
        ComputerName,
        Environment,
        Role,
        ExpectedService,
        Owner,
        IsProduction
