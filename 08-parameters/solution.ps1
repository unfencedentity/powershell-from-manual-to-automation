<#
.SYNOPSIS
    Work-in-progress solutions for Chapter 08: Parameters.

.DESCRIPTION
    Provides reference implementations only for concepts already practised.
    This file will be expanded and finalized after the chapter is completed.

.NOTES
    Exercise 4 is intentionally incomplete because it is the current
    independent learning checkpoint.
#>

# Exercise 1: Distinguish parameters from arguments

function Get-Greeting {
    param(
        [string]$Name
    )

    $Message = "Hello, $Name"
    $Message
}

Get-Greeting -Name "Ana"
Get-Greeting "Mihai"


# Exercise 2: Compare named and positional binding

function Get-PersonalGreeting {
    param(
        [string]$Greeting,
        [string]$Name
    )

    "$Greeting, $Name"
}

Get-PersonalGreeting -Name "Ana" -Greeting "Howdy"
Get-PersonalGreeting "Hello" "Mihai"
Get-PersonalGreeting "Mihai" "Hello"

# Named binding matches arguments to parameters by parameter name, so the
# argument order does not matter. Positional binding matches arguments to
# parameters by their declared position, so reversing the argument order
# changes which value each parameter receives.


# Exercise 3: Observe parameter type conversion

function Get-DoubledNumber {
    param(
        [int]$Number
    )

    $Number * 2
}

Get-DoubledNumber -Number 5
Get-DoubledNumber -Number "5"

# Expected result: parameter binding fails because "five" cannot be converted
# to System.Int32. Uncomment the invocation to observe the binding error.

# Get-DoubledNumber -Number "five"

# PowerShell accepts 5 directly because it is already an integer. It converts
# the numeric string "5" to System.Int32 during parameter binding. The string
# "five" cannot be converted, so binding fails before the function body runs.


# Exercise 4: Convert hours to minutes
# CURRENT LEARNING CHECKPOINT
#
# The solution is intentionally withheld until the independent attempt has
# been completed and reviewed.
