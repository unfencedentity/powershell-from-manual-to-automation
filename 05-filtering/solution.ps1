<#
Chapter 05 - Filtering
Solutions
#>


# Exercise 1

5, 10, 15, 20, 25 |
    Where-Object {
        $_ -gt 10
    }


# Exercise 2

Get-Service |
    Where-Object {
        $_.Status -eq "Stopped"
    } |
    Select-Object -First 5


# Exercise 3

Get-Service |
    Where-Object {
        $_.Status -eq "Stopped" -and
        $_.Name -like "A*"
    } |
    Select-Object -First 5


# Exercise 4

$targetServices = "Spooler", "WinRM"

Get-Service |
    Where-Object {
        $_.Name -in $targetServices
    }


# Exercise 5

Get-Process |
    Where-Object {
        $_.WorkingSet64 -gt 200MB -and
        $_.Name -like "b*"
    } |
    Select-Object -First 3


# Exercise 6

$expectedServices = "EventLog", "Dnscache", "LanmanWorkstation"

Get-Service -Name $expectedServices |
    Where-Object {
        $_.Status -ne "Running"
    }
