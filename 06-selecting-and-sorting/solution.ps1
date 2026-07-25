<#
Chapter 06 - Selecting and Sorting
Solutions
#>


# Exercise 1

Get-Service |
    Select-Object -First 5 Name, Status


# Exercise 2

Get-Service |
    Select-Object -First 5 -ExpandProperty Name


# Exercise 3

Get-Service |
    Sort-Object Status, Name |
    Select-Object -First 10 Name, DisplayName, Status


# Exercise 4

1..10 |
    Select-Object -Skip 3


# Exercise 5

Get-Service |
    Sort-Object Status |
    Select-Object -ExpandProperty Status -Unique


# Exercise 6

Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5 Name, Id, @{
        Name = "MemoryMB"
        Expression = {
            [math]::Round($_.WorkingSet64 / 1MB, 2)
        }
    }


# Exercise 7

Get-Process |
    Where-Object {
        $_.CPU -ne $null
    } |
    Sort-Object CPU -Descending |
    Select-Object -First 5 Name, Id, CPU
