Chapter 09 — Files

Objective

Build safe, predictable PowerShell workflows for discovering, reading,
creating, updating, moving, copying, renaming, and removing files and
directories.

The chapter focuses on a reusable enterprise pattern:

Build path -> validate target -> retrieve or read -> change -> verify

All destructive practice must use an exact target inside a dedicated temporary
directory.

1. A path is not the item at that path

A path is text that identifies a location:

$filePath = "C:\Reports\servers.txt"
$filePath.GetType().FullName

System.String

The file-system item is an object returned by a command such as Get-Item:

$file = Get-Item -Path $filePath
$file.GetType().FullName

System.IO.FileInfo

The distinction matters because the properties depend on the object type:

$filePath.Length is the number of characters in the path string.

$file.Length is the file size in bytes.

$file.FullName is the absolute path represented by the object.

Mental model:

Path string -> Get-Item -> FileInfo or DirectoryInfo object
Path string -> Get-Content -> content stored inside a file

2. Current location and path forms

Get-Location returns the current PowerShell location:

Get-Location

An absolute path identifies a location independently of the current location:

C:\Automation\servers.txt

A relative path is interpreted from the current location:

.\servers.txt

Use Set-Location when changing the current location is intentional:

Set-Location -Path $labPath

For automation, prefer explicit paths over assumptions about where the caller
started PowerShell.

3. Building paths with Join-Path and PSScriptRoot

Use Join-Path instead of manually concatenating path separators:

$serverPath = Join-Path -Path $labPath -ChildPath "servers.txt"

Join-Path produces a path string. It does not create the file or directory.

$PSScriptRoot contains the directory of the currently executing script:

$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.txt"

This makes a script independent of the caller's current location. At an
interactive prompt, $PSScriptRoot is normally empty because no script file is
executing.

4. Validating paths with Test-Path

Test-Path returns a Boolean and does not return the item:

Test-Path -Path $serverPath

Validate both existence and expected item type:

Test-Path -Path $serverPath -PathType Leaf
Test-Path -Path $labPath -PathType Container

Leaf means a non-container item, normally a file.

Container means a directory.

This prevents code from treating a directory as a file or a file as a
directory.

5. Get-Item versus Get-ChildItem

Get-Item retrieves the exact item identified by a path:

$directory = Get-Item -Path $labPath

Get-ChildItem enumerates the items inside a directory:

$items = Get-ChildItem -Path $labPath

Filter at the source when the provider supports it:

Get-ChildItem -Path $labPath -File
Get-ChildItem -Path $labPath -Directory

Use -Recurse only when traversal of all descendant directories is required.
It can produce large result sets and access locations that were not obvious
from the original path.

6. FileInfo, DirectoryInfo, and PSIsContainer

File-system commands return objects, not display text.

Typical types:

System.IO.FileInfo
System.IO.DirectoryInfo

Inspect the type and available members:

$item.GetType().FullName
$item | Get-Member

PSIsContainer gives one property that works for both file and directory
objects:

if ($item.PSIsContainer) {
    "Directory"
}
else {
    "File"
}

High-value properties:

Property

Meaning

Name

Leaf name of the item

FullName

Absolute path

Extension

File extension, such as .txt

Length

File size in bytes

LastWriteTime

Last modification time

Parent

Parent directory object

PSIsContainer

$true for a directory, $false for a file

Length has file-size meaning on FileInfo. Do not assume it represents the
recursive size of a directory.

7. Reading file content

By default, Get-Content returns one string per line:

$lines = Get-Content -Path $serverPath
$lines.Count
$lines[0]

Use -Raw when the entire file must be one string:

$content = Get-Content -Path $serverPath -Raw

Read only the beginning or end when the full file is unnecessary:

Get-Content -Path $logPath -TotalCount 10
Get-Content -Path $logPath -Tail 20

Choose the form according to the next operation:

line-by-line output is useful for filtering and iteration;

-Raw is useful for whole-document text operations;

-TotalCount and -Tail reduce unnecessary work on large files.

8. Creating directories and files safely

Build an exact path, validate it, create only when absent, and verify afterward:

$outputPath = Join-Path -Path $labPath -ChildPath "output"

if (-not (Test-Path -Path $outputPath -PathType Container)) {
    New-Item -Path $outputPath -ItemType Directory | Out-Null
}

Test-Path -Path $outputPath -PathType Container

Create an empty file only when an empty file is actually required:

$reportPath = Join-Path -Path $outputPath -ChildPath "inventory.txt"

if (-not (Test-Path -Path $reportPath -PathType Leaf)) {
    New-Item -Path $reportPath -ItemType File | Out-Null
}

Do not add -Force automatically. First decide whether replacing or bypassing
an existing state is intentional.

9. Set-Content, Add-Content, and Out-File

Set-Content writes values and replaces existing file content:

$reportLines = @(
    "Server: SERVER01"
    "Status: Running"
)

Set-Content -Path $reportPath -Value $reportLines -Encoding utf8

Add-Content appends values without replacing existing content:

Add-Content -Path $reportPath -Value "Source: Manual" -Encoding utf8

Out-File sends the formatted display representation of pipeline output to a
file:

Get-ChildItem -Path $labPath |
    Select-Object Name, Length |
    Out-File -FilePath $listingPath -Encoding utf8

Use the right tool:

Set-Content for controlled text replacement;

Add-Content for append-only text such as a simple log entry;

Out-File for human-readable formatted output.

Formatted Out-File output is not a reliable structured-data interchange
format. CSV and JSON are covered in later chapters.

10. Encoding

Encoding defines how text characters are represented as bytes. A file can look
correct in one tool and fail in another when producer and consumer disagree
about encoding.

Specify encoding when interoperability matters:

Set-Content -Path $reportPath -Value $reportLines -Encoding utf8
Add-Content -Path $reportPath -Value "Region: București" -Encoding utf8
Out-File -FilePath $listingPath -InputObject $reportLines -Encoding utf8

utf8 is a common modern choice, but the receiving application or legacy
system determines the real requirement.

11. Copying, moving, and renaming

Use exact source and destination paths:

Copy-Item -Path $sourcePath -Destination $copyPath
Move-Item -Path $copyPath -Destination $archivePath
Rename-Item -Path $archivedFilePath -NewName "servers-archived.txt"

The operations have different meanings:

Copy-Item preserves the source and creates another item;

Move-Item changes the item's location;

Rename-Item changes its name in the same parent directory.

After a change, verify the expected source and destination states with
Test-Path or Get-Item.

12. Removing an exact target safely

Resolve and validate the exact disposable target first:

$targetPath = Join-Path -Path $labPath -ChildPath "delete-me.txt"

if (Test-Path -Path $targetPath -PathType Leaf) {
    Remove-Item -Path $targetPath -WhatIf
}

Only after inspecting the -WhatIf result should the real operation be
considered:

if (Test-Path -Path $targetPath -PathType Leaf) {
    Remove-Item -Path $targetPath
}

Test-Path -Path $targetPath

Never begin with a broad directory, an unresolved variable, or recursive
deletion.

13. Cumulative function: Get-FileInventory

The cumulative function accepts a directory, optionally filters by item type,
optionally recurses, and returns predictable objects for downstream pipeline
use.

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

Example invocations:

Get-FileInventory -Path $labPath

Get-FileInventory -Path $labPath -ItemType File |
    Select-Object Name, SizeBytes

Get-FileInventory -Path $labPath -ItemType Directory

Get-FileInventory -Path $labPath -ItemType File -Recurse |
    Sort-Object FullName

The function reuses previous chapters:

mandatory and validated parameters;

a default value and ValidateSet;

a switch parameter;

splatting with conditionally added parameters;

foreach, if, and elseif;

PSCustomObject output;

pipeline-friendly results.

Enterprise applications

These file operations support common Wintel automation tasks:

validating configuration and input files before deployment;

discovering logs, reports, and artifacts;

reading only relevant sections of large log files;

creating report and archive directories predictably;

appending operational audit entries;

copying artifacts into staging locations;

moving completed reports into archive locations;

returning normalized file inventory objects for CSV or JSON export;

previewing destructive work before execution.

Discovery commands

Use discovery instead of guessing syntax:

Get-Command -Noun Path
Get-Command Get-ChildItem -Syntax
Get-Help Test-Path -Parameter PathType
Get-Help Get-Content -Examples
Get-Help Remove-Item -Examples
$item | Get-Member

Use Ctrl+Space after a parameter when the shell can provide valid values.

Live-coding method

When asked to automate a file task:

State whether the input is a path string, an item object, or file content.

Build the exact path with Join-Path.

Validate existence and expected type with Test-Path.

Retrieve metadata with Get-Item or enumerate with Get-ChildItem.

Read or mutate only what the requirement needs.

Use -WhatIf before deletion.

Verify the resulting state.

Return objects when another command may consume the result.

This sequence makes reasoning visible to an interviewer and reduces accidental
file-system changes.

Interview recap

What is the difference between a path and a file object?

A path is normally a System.String identifying a location. Get-Item resolves
that path and returns a file-system object such as System.IO.FileInfo, which
contains metadata and methods.

What is the difference between Get-Item and Get-ChildItem?

Get-Item retrieves the exact item at a path. Get-ChildItem enumerates the
items contained by a directory and can optionally recurse into descendants.

What are FileInfo and DirectoryInfo?

They are .NET object types representing files and directories. PowerShell adds
provider properties such as PSIsContainer, while the underlying objects expose
metadata such as Name, FullName, and LastWriteTime.

Why use Join-Path instead of string concatenation?

Join-Path expresses parent-child path intent clearly and handles the provider's
path separator rules. It also avoids duplicated or missing separators.

Why is PSScriptRoot important?

$PSScriptRoot identifies the directory containing the executing script. It
allows the script to locate adjacent resources independently of the caller's
current working directory.

What does Test-Path return?

Test-Path returns a Boolean. With -PathType Leaf or Container, it validates
both existence and the expected item category.

How does Get-Content behave by default and with -Raw?

By default, it returns file content line by line. With -Raw, it returns the
entire file as one string.

When would you use Set-Content, Add-Content, or Out-File?

Use Set-Content to replace controlled text, Add-Content to append text, and
Out-File to save PowerShell's formatted display output for human consumption.

Why does encoding matter?

Encoding controls how characters become bytes. If producer and consumer expect
different encodings, text can be corrupted or rejected, so automation should
specify the encoding required by the target system.

How would you remove a file safely?

Build an exact target path, validate it as a leaf, preview Remove-Item with
-WhatIf, perform the real deletion only after reviewing the target, and verify
that the path no longer exists.

Why return PSCustomObject instances from an inventory function?

Objects preserve named properties for filtering, sorting, selection, and later
serialization to CSV or JSON. Formatted strings lose that structure.

Must know by heart

The following core should be recallable without copying:

$childPath = Join-Path -Path $parentPath -ChildPath "file.txt"

Test-Path -Path $childPath -PathType Leaf
Test-Path -Path $parentPath -PathType Container

$item = Get-Item -Path $childPath
$children = Get-ChildItem -Path $parentPath

$item.Name
$item.FullName
$item.Length
$item.LastWriteTime
$item.PSIsContainer

$lines = Get-Content -Path $childPath
$text = Get-Content -Path $childPath -Raw

Set-Content -Path $childPath -Value $value -Encoding utf8
Add-Content -Path $childPath -Value $value -Encoding utf8

Remove-Item -Path $exactDisposablePath -WhatIf

Also remember these decisions:

path, item object, and file content are three different things;

relative paths depend on the current location;

$PSScriptRoot anchors resources to the script;

Get-Item gets one item, while Get-ChildItem enumerates children;

Leaf means file-like item and Container means directory;

Set-Content replaces, Add-Content appends, and Out-File formats;

destructive work requires an exact validated target, -WhatIf, and
verification.

Exercises

Complete exercise.ps1 before consulting solution.ps1.

The exercises cover:

path strings, item objects, and content;

absolute, relative, and script-relative paths;

existence and type validation;

file-system enumeration and metadata;

content reading modes;

safe creation and text output;

encoding;

copy, move, rename, and verified removal;

the cumulative Get-FileInventory function;

interview and live-coding reasoning.

Completion criteria

The chapter is complete when you can:

explain the difference between a path, an item object, and file content;

choose between Get-Item, Get-ChildItem, and Get-Content;

build stable paths with Join-Path and $PSScriptRoot;

validate both existence and item type;

use the important properties of file and directory objects;

write and append text intentionally with an explicit encoding;

copy, move, and rename exact targets;

preview and verify file deletion;

implement and explain Get-FileInventory without cargo-cult code.

Key takeaway

Reliable file automation is not a collection of isolated commands. It is a
controlled workflow that distinguishes identifiers, objects, and content;
validates exact targets; performs the smallest required change; and verifies
the result.
