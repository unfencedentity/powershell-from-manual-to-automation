<#
.SYNOPSIS
    Solutions for Chapter 09: Files.

.DESCRIPTION
    Demonstrates paths, file-system objects, content, validation, enumeration,
    safe creation, text output, encoding, copy, move, rename, verified removal,
    and a cumulative file inventory function.

.NOTES
    Every file-system change is restricted to a unique temporary lab directory.
    The script does not use Force or recursive deletion. The lab remains
    available after execution for manual inspection.
#>

# Exercise 1: Create a safe temporary lab

$labName = "powershell-files-solution-$PID"
$labPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath $labName

$labExistedBeforeCreation = Test-Path -Path $labPath
$labExistedBeforeCreation

if ($labExistedBeforeCreation) {
    throw "Temporary lab already exists: $labPath"
}

New-Item -Path $labPath -ItemType Directory | Out-Null
Test-Path -Path $labPath -PathType Container


# Exercise 2: Distinguish a path from the item at that path

$serverPath = Join-Path -Path $labPath -ChildPath "servers.txt"
New-Item -Path $serverPath -ItemType File | Out-Null

$serverItem = Get-Item -Path $serverPath

$serverPath.GetType().FullName
$serverItem.GetType().FullName
$serverPath.Length
$serverItem.Length

# $serverPath is a System.String, so its Length is the character count.
# $serverItem is a System.IO.FileInfo, so its Length is the file size in bytes.


# Exercise 3: Compare absolute and relative paths

$startingLocation = Get-Location
$startingLocation

Set-Location -Path $labPath

$absoluteItem = Get-Item -Path $serverPath
$relativeItem = Get-Item -Path ".\servers.txt"

$absoluteItem.FullName
$relativeItem.FullName
$absoluteItem.FullName -eq $relativeItem.FullName

# The current location gives .\servers.txt its meaning. Both commands resolve
# to the same absolute path after Set-Location changes the current location.


# Exercise 4: Use PSScriptRoot for a stable script-relative path

$solutionPath = Join-Path -Path $PSScriptRoot -ChildPath "solution.ps1"
Test-Path -Path $solutionPath -PathType Leaf

# PSScriptRoot is the directory of this executing script, so the result does not
# depend on the caller's current location. It can be empty at an interactive
# prompt because no script file is executing there.


# Exercise 5: Validate existence and item type

$missingPath = Join-Path -Path $labPath -ChildPath "missing.txt"

Test-Path -Path $serverPath -PathType Leaf
Test-Path -Path $serverPath -PathType Container
Test-Path -Path $labPath -PathType Leaf
Test-Path -Path $labPath -PathType Container
Test-Path -Path $missingPath

# Leaf identifies a non-container item such as a file. Container identifies a
# directory.


# Exercise 6: Compare Get-Item and Get-ChildItem

$archivePath = Join-Path -Path $labPath -ChildPath "archive"
$notesPath = Join-Path -Path $labPath -ChildPath "notes.txt"

New-Item -Path $archivePath -ItemType Directory | Out-Null
New-Item -Path $notesPath -ItemType File | Out-Null

Get-Item -Path $labPath
Get-ChildItem -Path $labPath
Get-ChildItem -Path $labPath -File
Get-ChildItem -Path $labPath -Directory

# Get-Item retrieves labPath itself. Get-ChildItem enumerates the items inside
# labPath.


# Exercise 7: Inspect file and directory objects

$fileItem = Get-Item -Path $serverPath
$directoryItem = Get-Item -Path $archivePath

$fileItem.GetType().FullName
$directoryItem.GetType().FullName
$fileItem.PSIsContainer
$directoryItem.PSIsContainer

$fileItem |
    Select-Object Name, Extension, Length, LastWriteTime, FullName

$directoryItem |
    Select-Object Name, Parent, LastWriteTime, FullName, PSIsContainer


# Exercise 8: Read content in different forms

$serverNames = @(
    "SERVER01"
    "SERVER02"
    "SERVER03"
    "SERVER04"
)

Set-Content -Path $serverPath -Value $serverNames -Encoding utf8

$lines = Get-Content -Path $serverPath
$rawContent = Get-Content -Path $serverPath -Raw

$lines
$lines.GetType().FullName
$lines.Count

$rawContent
$rawContent.GetType().FullName
$rawContent.Count

Get-Content -Path $serverPath -TotalCount 2
Get-Content -Path $serverPath -Tail 1

# Normal Get-Content returns one string per line. Raw returns the complete file
# as one string.


# Exercise 9: Create an output directory and report safely

$outputPath = Join-Path -Path $labPath -ChildPath "output"
$reportPath = Join-Path -Path $outputPath -ChildPath "inventory.txt"

if (-not (Test-Path -Path $outputPath -PathType Container)) {
    New-Item -Path $outputPath -ItemType Directory | Out-Null
}

if (-not (Test-Path -Path $reportPath -PathType Leaf)) {
    New-Item -Path $reportPath -ItemType File | Out-Null
}

Test-Path -Path $outputPath -PathType Container
Test-Path -Path $reportPath -PathType Leaf


# Exercise 10: Compare Set-Content, Add-Content, and Out-File

$reportLines = @(
    "Server: SERVER01"
    "Service: Spooler"
    "Status: Running"
)

Set-Content -Path $reportPath -Value $reportLines -Encoding utf8
Add-Content -Path $reportPath -Value "Source: Manual" -Encoding utf8
Get-Content -Path $reportPath

$listingPath = Join-Path -Path $outputPath -ChildPath "listing.txt"

Get-ChildItem -Path $labPath |
    Select-Object Name, Length |
    Out-File -FilePath $listingPath -Encoding utf8

Get-Content -Path $listingPath

# Set-Content replaces content. Add-Content appends content. Out-File writes the
# formatted representation of pipeline output.


# Exercise 11: Make encoding intentional

$encodingPath = Join-Path -Path $outputPath -ChildPath "encoding.txt"

Set-Content `
    -Path $encodingPath `
    -Value "Region: București" `
    -Encoding utf8

Add-Content `
    -Path $encodingPath `
    -Value "Status: pregătit" `
    -Encoding utf8

Get-Content -Path $encodingPath

# Explicit encoding gives the producer and consumer a documented byte format.


# Exercise 12: Copy, move, and rename exact targets

$sourcePath = Join-Path -Path $labPath -ChildPath "source.txt"
$copyPath = Join-Path -Path $labPath -ChildPath "source-copy.txt"
$movedPath = Join-Path -Path $archivePath -ChildPath "source-copy.txt"
$renamedPath = Join-Path -Path $archivePath -ChildPath "source-archived.txt"

Set-Content -Path $sourcePath -Value "Source data" -Encoding utf8

Copy-Item -Path $sourcePath -Destination $copyPath
Test-Path -Path $sourcePath -PathType Leaf
Test-Path -Path $copyPath -PathType Leaf

Move-Item -Path $copyPath -Destination $movedPath
Test-Path -Path $copyPath
Test-Path -Path $movedPath -PathType Leaf

Rename-Item -Path $movedPath -NewName "source-archived.txt"
Test-Path -Path $movedPath
Test-Path -Path $renamedPath -PathType Leaf

# Copy preserves the source. Move changes the location of the copied item.
# Rename changes the leaf name inside the same archive directory.


# Exercise 13: Preview and verify removal

$deletePath = Join-Path -Path $labPath -ChildPath "delete-me.txt"
Set-Content -Path $deletePath -Value "Disposable" -Encoding utf8

if (Test-Path -Path $deletePath -PathType Leaf) {
    Remove-Item -Path $deletePath -WhatIf
}

Test-Path -Path $deletePath -PathType Leaf

if (Test-Path -Path $deletePath -PathType Leaf) {
    Remove-Item -Path $deletePath
}

Test-Path -Path $deletePath


# Exercise 14: Build a cumulative inventory function

function Get-FileInventory {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,

        [ValidateSet("All", "File", "Directory")]
        [string]$ItemType = "All",

        [switch]$Recurse
    )

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "Directory not found: $Path"
        return
    }

    $getChildItemParams = @{
        Path = $Path
    }

    if ($Recurse) {
        $getChildItemParams.Recurse = $true
    }

    if ($ItemType -eq "File") {
        $getChildItemParams.File = $true
    }
    elseif ($ItemType -eq "Directory") {
        $getChildItemParams.Directory = $true
    }

    $items = Get-ChildItem @getChildItemParams

    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            $itemTypeName = "Directory"
            $sizeBytes = $null
        }
        else {
            $itemTypeName = "File"
            $sizeBytes = $item.Length
        }

        [PSCustomObject]@{
            Name          = $item.Name
            ItemType      = $itemTypeName
            FullName      = $item.FullName
            SizeBytes     = $sizeBytes
            LastWriteTime = $item.LastWriteTime
        }
    }
}

Get-FileInventory -Path $labPath

Get-FileInventory -Path $labPath -ItemType File |
    Select-Object Name, ItemType, SizeBytes

Get-FileInventory -Path $labPath -ItemType Directory |
    Select-Object Name, ItemType

Get-FileInventory -Path $labPath -ItemType File -Recurse |
    Select-Object Name, FullName

# Expected error. Uncomment to test the missing-directory branch.
# Get-FileInventory -Path $missingPath


# Exercise 15: Live-coding explanation

# 1. A path is a string identifier. An item object represents file-system
#    metadata and behavior. File content is the data stored inside the file.
# 2. Join-Path builds parent-child paths without manual separators. PSScriptRoot
#    anchors resources to the executing script instead of the caller's location.
# 3. Get-Item retrieves one exact item, Get-ChildItem enumerates directory
#    contents, and Get-Content reads data stored inside a file.
# 4. Build and validate one exact leaf path, preview Remove-Item with WhatIf,
#    perform the removal only after reviewing the target, and verify afterward.
# 5. Objects preserve named properties for filtering, sorting, selection, and
#    serialization. Formatted text loses that structure.


# Final lab location for manual inspection

$labPath
Set-Location -Path $startingLocation
