# Chapter 10 - CSV
# Cumulative Exercise: Windows Server Inventory and Validation

<#
Scenario:

You receive a CSV inventory containing Windows servers.

Each row must contain these columns:

- ComputerName
- Environment
- Role
- ExpectedService
- Owner

Requirements:

1. Create a dedicated lab directory inside the current user's temporary directory.
2. Build all paths with Join-Path.
3. Create at least three fictional server PSCustomObject instances.
4. Store the server objects in an array.
5. Export the inventory to server-inventory.csv:
   - use UTF-8 encoding;
   - do not include type information;
   - do not use Append.
6. Verify that the CSV exists as a file.
7. Inspect the physical CSV content with Get-Content.
8. Create a function named Get-ServerInventory.
9. The function must:
   - accept a mandatory validated Path parameter;
   - verify that Path points to an existing file;
   - import the CSV;
   - verify that the inventory contains data rows;
   - validate all required columns;
   - report missing columns;
   - stop when validation fails;
   - transform every imported row into a new PSCustomObject;
   - create an IsProduction Boolean property;
   - return objects through the pipeline.
10. Call Get-ServerInventory with the inventory path.
11. Sort the returned objects by ComputerName.
12. Export the validated inventory to server-inventory-report.csv.
13. Verify the exact report path.
14. Import and inspect the final report.

Expected result:

- Three server objects are imported.
- The required-column validation succeeds.
- Production servers have IsProduction set to True.
- Test servers have IsProduction set to False.
- The final report exists inside the dedicated temporary lab.
- Running the script repeatedly does not append duplicate rows.
#>

# Write your solution below.
