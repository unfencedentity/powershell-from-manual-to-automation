<#
Chapter 04 - Pipelines

Solutions for the exercises in exercise.ps1.
#>


# Exercise 1
# Send numbers through the pipeline and multiply each one by 2.

10, 20, 30 | ForEach-Object {
    $_ * 2
}


# Exercise 2
# Display the first five services with an uppercase technical name
# and their current status.

Get-Service |
    Select-Object -First 5 |
    ForEach-Object {
        "Name: $($_.Name.ToUpper()) | Status: $($_.Status)"
    }


# Exercise 3
# Return Name and Status as separate output values.

Get-Service |
    Select-Object -First 3 |
    ForEach-Object {
        $_.Name
        $_.Status
    }


# Exercise 4
# Count all Windows services and return only the Count value.

(Get-Service | Measure-Object).Count


# Exercise 5
# Safely simulate stopping the first Windows service.

Get-Service |
    Select-Object -First 1 |
    Stop-Service -WhatIf
