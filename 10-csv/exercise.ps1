# Chapter 10 - CSV
# Exercise: Windows Server Inventory and Validation
# Status: In progress

# Part 1 - Build an in-memory server inventory

# Create three PSCustomObject instances with these properties:
# ComputerName
# Environment
# Role
# ExpectedService
# Owner

# Use the following server data:
#
# SRV-APP-01, Production, Web, W3SVC, PlatformTeam
# SRV-DB-01, Production, Database, MSSQLSERVER, DataTeam
# SRV-TEST-01, Test, Web, W3SVC, QA-Team

# Store the three server objects in an array named $servers.

# Verify:
# - the number of objects in the array;
# - the type of the first element.


# Part 2 - Prepare a safe temporary CSV lab

# Build an exact temporary directory path using:
# - $env:TEMP as the parent path;
# - powershell-csv-lab as the child path;
# - Join-Path to construct the path.

# Verify whether the path already exists as a directory.


# Future chapter work

# TODO: Create the temporary directory safely.
# TODO: Build an exact CSV file path.
# TODO: Export the inventory with Export-Csv.
# TODO: Inspect the physical CSV content.
# TODO: Import the inventory with Import-Csv.
# TODO: Validate required columns.
# TODO: Transform imported strings into typed output objects.
# TODO: Export a structured validation report.
