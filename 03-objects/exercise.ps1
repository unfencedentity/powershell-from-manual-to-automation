<#
Chapter 03 - Objects

Complete each exercise by inspecting and using PowerShell objects.
#>


$name = "  Lucian  "
$resourceName = "vm-core-prod-weu"


# Exercise 1
# Return the complete .NET type name of $name.

# TODO: Use GetType() and the appropriate property.


# Exercise 2
# Inspect the properties and methods available on $name.

# TODO: Use the pipeline and Get-Member.


# Exercise 3
# Return:
# - the length of $name;
# - the value without surrounding spaces;
# - the value in uppercase.

# TODO: Access the property and call the methods.


# Exercise 4
# Determine whether $resourceName contains "prod".

# TODO: Call the appropriate string method.


# Exercise 5
# Replace "prod" with "dev" in $resourceName.

# TODO: Call Replace() with the required arguments.


# Exercise 6
# Split $resourceName at each hyphen.
# Return the resource type and environment using array indexes.

# TODO: Split the string and access the required elements.


# Exercise 7
# Get the current date and return its Year, Month, and Day properties.

# TODO: Work with the object returned by Get-Date.
