<#
Chapter 03 - Objects

Solutions for the exercises in exercise.ps1.
#>


$name = "  Lucian  "
$resourceName = "vm-core-prod-weu"


# Exercise 1

$name.GetType().FullName


# Exercise 2

$name | Get-Member


# Exercise 3

$name.Length
$name.Trim()
$name.ToUpper()


# Exercise 4

$resourceName.Contains("prod")


# Exercise 5

$resourceName.Replace("prod", "dev")


# Exercise 6

$parts = $resourceName.Split("-")

$parts

"Resource type: $($parts[0])"
"Environment: $($parts[2])"


# Exercise 7

$currentDate = Get-Date

"Year: $($currentDate.Year)"
"Month: $($currentDate.Month)"
"Day: $($currentDate.Day)"
