<#
Chapter 02 - Arrays

Solutions for the exercises in exercise.ps1.
#>


# Exercise 1

$environments = "dev", "test", "prod"


# Exercise 2

$environments[0]
$environments[-1]


# Exercise 3

$environments.Count


# Exercise 4

foreach ($environment in $environments) {
    "Environment: $environment"
}


# Exercise 5

$resourceGroupNames = foreach ($environment in $environments) {
    "rg-core-$environment-weu"
}

$resourceGroupNames
