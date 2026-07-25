<#
Chapter 06 - Selecting and Sorting

Complete each exercise using Select-Object and Sort-Object.
Do not copy the answers from solution.ps1.
#>


# Exercise 1
# Get all Windows services.
# Keep the first five services.
# Include only the Name and Status properties.

# TODO: Write your pipeline here.


# Exercise 2
# Get the first five Windows services.
# Extract only the value of the Name property.
# The results must be strings, not objects containing a Name property.

# TODO: Write your pipeline here.


# Exercise 3
# Get all Windows services.
# Sort them first by Status and then by Name.
# Keep the first ten services.
# Include only Name, DisplayName, and Status.

# TODO: Write your pipeline here.


# Exercise 4
# Send the numbers 1 through 10 into the pipeline.
# Skip the first three numbers.

# TODO: Write your pipeline here.


# Exercise 5
# Get all Windows services.
# Return each distinct Status value only once.

# TODO: Write your pipeline here.


# Exercise 6
# Get all processes.
# Sort them by WorkingSet64 in descending order.
# Keep the first five processes.
#
# Include:
# - Name
# - Id
# - a calculated property named MemoryMB
#
# MemoryMB must:
# - convert WorkingSet64 from bytes to megabytes
# - be rounded to two decimal places

# TODO: Write your pipeline here.


# Exercise 7
# Get all processes.
# Remove processes whose CPU property contains $null.
# Sort the remaining processes by CPU in descending order.
# Keep the first five processes.
# Include only Name, Id, and CPU.

# TODO: Write your pipeline here.
