<#
.SYNOPSIS
    Practice exercises for Chapter 07: Functions.

.DESCRIPTION
    Complete each exercise without copying the solution.
    Use Get-Command, Get-Help, Get-Member, and Ctrl+Space
    when you forget syntax.
#>

# Exercise 1: Define and invoke a function
# Create a function named Show-Greeting.
# The function should output: Hello from PowerShell
# Invoke the function twice.

# TODO: Write your function here.


# Exercise 2: Add a typed parameter
# Create a function named Get-DoubledNumber.
# It should accept an integer parameter named Number.
# It should output the number multiplied by 2.

# TODO: Write your function here.


# Exercise 3: Return a structured object
# Create a function named New-VirtualMachineName.
# It should accept these parameters:
# - Application
# - Environment
# - Region
# - Instance
#
# Build a name using this format:
# vm-<application>-<environment>-<region>-<instance>
#
# Return a PSCustomObject with these properties:
# - Name
# - Application
# - Environment
# - Region
# - Instance

# TODO: Write your function here.


# Exercise 4: Wrap reusable service logic
# Create a function named Get-ServiceReport.
# It should accept a string parameter named Name.
# Give Name a default value of "*".
#
# The function should:
# - get matching Windows services;
# - keep only running services;
# - sort them by DisplayName;
# - return Name, DisplayName, and Status.

# TODO: Write your function here.


# Exercise 5: Build a process report
# Create a function named Get-ProcessReport.
# It should accept a string parameter named Name.
# Give Name a default value of "*".
#
# The function should:
# - get matching processes;
# - sort them by CPU in descending order;
# - select the first five processes;
# - return Name, Id, and CPU.

# TODO: Write your function here.


# Exercise 6: Accept pipeline input
# Create an advanced function named Add-ResourceGroupPrefix.
# It should accept a string parameter named ResourceGroup.
# The parameter should accept input from the pipeline.
#
# For every input value, return the value prefixed with "rg-".
#
# Test the function with:
# "core", "network", "security" | Add-ResourceGroupPrefix

# TODO: Write your function here.


# Exercise 7: Separate diagnostic messages from output
# Create an advanced function named Get-DeploymentStatus.
#
# The function should:
# - use Write-Verbose to write: Checking deployment...
# - return one PSCustomObject;
# - set Name to "core-api";
# - set Status to "Ready".
#
# Capture the result in a variable:
# - first without -Verbose;
# - then with -Verbose.
#
# Confirm that the captured result contains only one object.

# TODO: Write your function here.


# Exercise 8: Accept pipeline input by property name
# Create an advanced function named Get-ServiceStatus.
# It should accept a string parameter named Name.
# The parameter should:
# - be mandatory;
# - accept pipeline input by property name;
# - use ServiceName as an alias.
#
# In the process block:
# - get the Windows service identified by Name;
# - return Name, DisplayName, and Status.
#
# Test the function with an object that has a Name property.
# Test it again with an object that has a ServiceName property.

# TODO: Write your function here.


# Exercise 9: Use begin, process, and end
# Create an advanced function named ConvertTo-NormalizedResourceName.
# It should accept a mandatory string parameter named Name from the pipeline.
#
# The begin block should:
# - initialize a processed counter to 0;
# - write a verbose starting message.
#
# The process block should:
# - increment the counter;
# - remove surrounding spaces from Name;
# - convert Name to lowercase;
# - return a PSCustomObject with OriginalName and NormalizedName.
#
# The end block should write a verbose message containing the processed count.
#
# Test the function with three resource names and -Verbose.

# TODO: Write your function here.


# Exercise 10: Safely simulate a change
# Create an advanced function named Set-DeploymentState.
# Enable SupportsShouldProcess.
#
# The function should accept:
# - a string parameter named Name;
# - a string parameter named State.
#
# Use $PSCmdlet.ShouldProcess() before outputting a message
# that describes the simulated change.
#
# Do not modify any real Azure resource or Windows service.
# Test the function with -WhatIf.

# TODO: Write your function here.
