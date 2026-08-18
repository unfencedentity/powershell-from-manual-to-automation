<#
.SYNOPSIS
    Practice exercises for Chapter 09: Files.

.DESCRIPTION
    Complete each exercise without copying the solution.
    Predict the result before running each command.
    Use Get-Command, Get-Help, Get-Member, and Ctrl+Space when syntax is
    unfamiliar.

.NOTES
    Perform every file-system change inside one dedicated temporary lab
    directory. Do not use system directories, broad paths, recursive deletion,
    or Force. Validate every removal target and use WhatIf first.
#>

# Exercise 1: Create a safe temporary lab
# Create a variable named labPath whose value is a unique directory beneath
# [System.IO.Path]::GetTempPath(). Include $PID in the directory name.
#
# Predict the result of Test-Path before creating the directory.
# Create the directory with New-Item, suppress the creation output, and verify
# it with Test-Path and PathType Container.

# TODO: Write the path construction, prediction, creation, and verification.


# Exercise 2: Distinguish a path from the item at that path
# Build serverPath by joining labPath with servers.txt.
# Create an empty file at serverPath.
# Store the result of Get-Item in serverItem.
#
# Inspect and explain:
# - the type of serverPath;
# - the type of serverItem;
# - serverPath.Length;
# - serverItem.Length.

# TODO: Write the commands and explanation.


# Exercise 3: Compare absolute and relative paths
# Display the current location, then change it to labPath.
# Retrieve servers.txt once with its absolute path and once with the relative
# path .\servers.txt.
# Compare the FullName property of both results.
#
# Explain what portion of code gives the relative path its meaning.

# TODO: Write the commands, comparison, and explanation.


# Exercise 4: Use PSScriptRoot for a stable script-relative path
# Build a path to exercise.ps1 using PSScriptRoot and Join-Path.
# Validate it as a leaf.
#
# Explain why this path remains stable when the script is launched from another
# current location. Also explain why PSScriptRoot can be empty at an interactive
# prompt.

# TODO: Write the path construction, validation, and explanation.


# Exercise 5: Validate existence and item type
# Build missingPath for missing.txt without creating the file.
# Predict and test these conditions:
# - serverPath exists as a Leaf;
# - serverPath exists as a Container;
# - labPath exists as a Leaf;
# - labPath exists as a Container;
# - missingPath exists.
#
# Explain Leaf and Container.

# TODO: Write the predictions, commands, and explanation.


# Exercise 6: Compare Get-Item and Get-ChildItem
# Create a directory named archive inside labPath.
# Create a second empty file named notes.txt inside labPath.
#
# Use Get-Item to retrieve labPath itself.
# Use Get-ChildItem to enumerate the immediate children of labPath.
# Then request only files and only directories.
#
# Explain what each command treats as the target.

# TODO: Write the commands and explanation.


# Exercise 7: Inspect file and directory objects
# Retrieve servers.txt and archive into separate variables.
# Inspect their .NET types and PSIsContainer values.
#
# Select these file properties:
# - Name;
# - Extension;
# - Length;
# - LastWriteTime;
# - FullName.
#
# Select these directory properties:
# - Name;
# - Parent;
# - LastWriteTime;
# - FullName;
# - PSIsContainer.

# TODO: Write the commands and identify FileInfo and DirectoryInfo.


# Exercise 8: Read content in different forms
# Write at least four server names to servers.txt using UTF-8.
# Read the file:
# - normally;
# - with Raw;
# - with TotalCount 2;
# - with Tail 1.
#
# Store the normal result and Raw result in separate variables. Inspect their
# types and Count values, then explain the difference.

# TODO: Write the commands and explanation.


# Exercise 9: Create an output directory and report safely
# Build outputPath beneath labPath and reportPath for inventory.txt beneath
# outputPath.
#
# Create the directory and empty report only if each exact target is absent.
# Verify the directory as a Container and the report as a Leaf.

# TODO: Write the guarded creation and verification.


# Exercise 10: Compare Set-Content, Add-Content, and Out-File
# Replace inventory.txt with three lines describing a server, service, and
# status. Use UTF-8.
# Append one source line and verify all four lines with Get-Content.
#
# Create listing.txt by sending Name and Length from the lab's immediate
# children through Select-Object and Out-File. Read listing.txt.
#
# Explain which command replaces, which appends, and which writes formatted
# display output.

# TODO: Write the commands and explanation.


# Exercise 11: Make encoding intentional
# Create encoding.txt beneath outputPath.
# Write a line containing non-ASCII characters with UTF-8, append another UTF-8
# line, and read the result.
#
# Explain why an enterprise script may need an explicit encoding even when the
# text looks correct on the machine that produced it.

# TODO: Write the commands and explanation.


# Exercise 12: Copy, move, and rename exact targets
# Create source.txt beneath labPath with one line of content.
# Copy it to source-copy.txt and verify that both paths exist.
# Move the copy into archive and verify the old and new paths.
# Rename the moved file to source-archived.txt and verify the final exact path.
#
# Explain what happens to the source after each operation.

# TODO: Write the commands, verification, and explanation.


# Exercise 13: Preview and verify removal
# Create the exact disposable file delete-me.txt beneath labPath.
# Validate it as a Leaf.
# Preview its removal with WhatIf and confirm that it still exists.
# Remove that exact file without WhatIf and verify that it no longer exists.
#
# Do not remove labPath, archive, output, or any target recursively.

# TODO: Write the guarded preview, removal, and verification.


# Exercise 14: Build a cumulative inventory function
# Create a function named Get-FileInventory.
# It should accept:
# - Path: mandatory, non-whitespace string;
# - ItemType: All, File, or Directory, with All as the default;
# - Recurse: switch.
#
# The function should:
# - verify that Path exists as a Container;
# - write an error and return when validation fails;
# - build a splatting hashtable for Get-ChildItem;
# - add Recurse, File, or Directory to the hashtable only when requested;
# - enumerate the selected items;
# - return one PSCustomObject per item.
#
# Each output object should contain:
# - Name;
# - ItemType, as File or Directory;
# - FullName;
# - SizeBytes, using null for directories;
# - LastWriteTime.
#
# Test:
# - the default behavior;
# - ItemType File;
# - ItemType Directory;
# - ItemType File with Recurse;
# - a missing directory.

# TODO: Write the function and tests here.


# Exercise 15: Live-coding explanation
# Without running commands, answer these questions in concise English:
# 1. What is the difference between a path, an item object, and file content?
# 2. Why use Join-Path and PSScriptRoot?
# 3. When should you use Get-Item, Get-ChildItem, and Get-Content?
# 4. How do you safely remove one known file?
# 5. Why should an inventory function return objects instead of formatted text?

# TODO: Write your answers here.
