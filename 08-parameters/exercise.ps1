<#
.SYNOPSIS
    Practice exercises for Chapter 08: Parameters.

.DESCRIPTION
    Complete each exercise without copying the solution.
    Predict behavior before running each invocation.
    Use Get-Command, Get-Help, Get-Member, and Ctrl+Space
    when syntax is unfamiliar.

.NOTES
    All examples are read-only or simulated. Do not modify real Azure
    resources or critical Windows services.
#>

# Exercise 1: Distinguish parameters from arguments
# Create a function named Get-Greeting.
# It should:
# - accept one string parameter named Name;
# - build the string "Hello, <Name>" in an internal variable named Message;
# - return Message through the success output stream.
#
# Invoke it once with named binding and once with positional binding.
# Identify the parameter, each argument, the parameter variable, and the
# internal variable.

# TODO: Write your function, invocations, and explanation here.


# Exercise 2: Compare named and positional binding
# Create a function named Get-PersonalGreeting.
# It should accept these string parameters in this order:
# - Greeting;
# - Name.
#
# Return one string using this format:
# <Greeting>, <Name>
#
# Test it with:
# - named arguments written in the opposite order;
# - positional arguments written in the declared order;
# - positional arguments written in the opposite order.
#
# Explain why named argument order does not change the result and why
# positional argument order does.

# TODO: Write your function, invocations, and explanation here.


# Exercise 3: Observe integer conversion
# Create a function named ConvertTo-Minutes.
# It should:
# - accept one integer parameter named Hours;
# - return Hours multiplied by 60.
#
# Predict and test:
# ConvertTo-Minutes -Hours 3
# ConvertTo-Minutes -Hours "3"
# ConvertTo-Minutes -Hours "three"
#
# Explain which values are accepted and why conversion failure prevents the
# function body from running.

# TODO: Write your function, invocations, and explanation here.


# Exercise 4: Accept explicit Boolean input
# Create a function named Show-FeatureState.
# It should:
# - accept one Boolean parameter named Enabled;
# - return Enabled;
# - be tested with both $true and $false.
#
# Inspect the returned type and explain why the caller must provide an
# explicit Boolean argument.

# TODO: Write your function, invocations, and type inspection here.


# Exercise 5: Use a switch parameter
# Create a function named Get-ServiceSelectionMode.
# It should:
# - accept a switch parameter named IncludeStopped;
# - return "All services" when the switch is present;
# - return "Running services only" when the switch is absent.
#
# Invoke it with and without -IncludeStopped.
# Explain the difference between [bool] and [switch].

# TODO: Write your function, invocations, and explanation here.


# Exercise 6: Use an optional parameter with a default value
# Create a function named New-ResourceName.
# It should accept:
# - Application as a string;
# - Environment as a string;
# - Instance as an integer with a default value of 1.
#
# Return a name using this format:
# vm-<application>-<environment>-<instance>
#
# Invoke it once without Instance and once with Instance set to 2.

# TODO: Write your function and invocations here.


# Exercise 7: Require mandatory input
# Create an advanced function named Get-DeploymentTarget.
# It should accept mandatory string parameters named Application and
# Environment.
#
# Return a PSCustomObject with these properties:
# - Application;
# - Environment;
# - Target, using the format <application>-<environment>.
#
# Invoke the function with both named arguments.
# Then inspect its syntax with Get-Command.

# TODO: Write your function, invocation, and discovery command here.


# Exercise 8: Accept a string collection
# Create a function named Get-EnvironmentReport.
# It should:
# - accept a string-array parameter named Environment;
# - process every supplied environment with foreach;
# - return one PSCustomObject per environment.
#
# Each object should contain:
# - Environment;
# - ResourceGroupName, using rg-core-<environment>-weu.
#
# Test it with one value and with dev, test, and prod together.

# TODO: Write your function and invocations here.


# Exercise 9: Validate a deployment request
# Create an advanced function named New-DeploymentRequest.
# It should accept:
# - Application: mandatory string, not null or empty;
# - Environment: mandatory string, allowed values dev, test, prod;
# - Instance: integer from 1 through 10, default 1;
# - ResourceGroupName: mandatory string matching ^rg-[a-z0-9-]+$.
#
# Return a PSCustomObject containing all four values.
#
# Test one valid invocation.
# Then test one invalid value for each validation attribute.

# TODO: Write your function and tests here.


# Exercise 10: Add a parameter alias
# Create a function named Get-ServiceLookupRequest.
# It should:
# - accept a string parameter named Name;
# - define ServiceName as an alias for Name;
# - return a PSCustomObject with a Name property.
#
# Invoke it once with -Name and once with -ServiceName.

# TODO: Write your function and invocations here.


# Exercise 11: Inspect explicitly bound parameters
# Create a function named Get-ReportRequest.
# It should accept:
# - Name as a string with a default value of "*";
# - IncludeStopped as a switch.
#
# Return a PSCustomObject containing:
# - Name;
# - IncludeStopped as a Boolean;
# - NameWasSupplied;
# - IncludeStoppedWasSupplied;
# - BoundParameterCount.
#
# Use $PSBoundParameters to calculate the final three properties.
# Test the function with no arguments and with both arguments.

# TODO: Write your function and invocations here.


# Exercise 12: Use named parameter splatting
# Create a hashtable named DeploymentParameters for the
# New-DeploymentRequest function from Exercise 9.
#
# Supply these values:
# - Application: core;
# - Environment: prod;
# - Instance: 2;
# - ResourceGroupName: rg-core-prod-weu.
#
# Invoke New-DeploymentRequest by splatting the hashtable.
# Explain the difference between $DeploymentParameters and
# @DeploymentParameters.

# TODO: Write your hashtable, invocation, and explanation here.


# Exercise 13: Discover parameter syntax
# Use discovery commands to answer these questions about Get-Service:
# - What type does the Name parameter accept?
# - Can Name accept several values?
# - Is Name mandatory?
# - Which command displays only the Name parameter help?
# - Which command displays examples?
#
# Use:
# Get-Command Get-Service -Syntax
# Get-Help Get-Service -Parameter Name
# Get-Help Get-Service -Examples
#
# Write the commands and your interpretation below.

# TODO: Run discovery commands and record your interpretation here.


# Exercise 14: Reinforce pipeline parameter binding
# Part A:
# Create an advanced function named Add-ResourceGroupPrefix.
# It should accept mandatory string input by value from the pipeline.
# In process, return each value prefixed with "rg-".
#
# Test with:
# "core", "network", "security" | Add-ResourceGroupPrefix
#
# Part B:
# Create an advanced function named Resolve-ServiceName.
# It should accept mandatory string input by property name through a parameter
# named Name with ServiceName as an alias.
# In process, return a PSCustomObject containing the bound Name.
#
# Test with an object containing Name and another containing ServiceName.

# TODO: Write both functions and pipeline tests here.


# Exercise 15: Design an enterprise automation interface
# Requirement:
# Create a read-only function named New-AzureAutomationContext.
# It receives explicit Azure targeting information for a GitHub Actions OIDC
# workflow. It must not perform interactive login or use client secrets.
#
# Parameters:
# - TenantId: mandatory, non-empty string;
# - SubscriptionId: mandatory, non-empty string;
# - Environment: mandatory dev, test, or prod string;
# - ResourceGroupName: mandatory string matching ^rg-[a-z0-9-]+$;
# - IncludeDetails: optional switch.
#
# Return one PSCustomObject containing:
# - Authentication = "OIDC";
# - TenantId;
# - SubscriptionId;
# - Environment;
# - ResourceGroupName;
# - IncludeDetails as a Boolean;
# - GeneratedAt as a real DateTime object.
#
# Build a hashtable of named arguments and invoke the function with splatting.
# Capture the result and verify its type, properties, and GeneratedAt type.

# TODO: Design, implement, invoke, capture, and verify the function here.
