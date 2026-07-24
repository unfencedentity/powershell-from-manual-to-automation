<#
Chapter 01 - Variables

Solutions for the exercises in exercise.ps1.
#>


# Exercise 1

$environment = "dev"
$application = "core"
$region = "weu"


# Exercise 2

$resourceGroupName = "rg-$application-$environment-$region"

$resourceGroupName


# Exercise 3

"Deploying $application to $environment in $region"


# Exercise 4

$environment = "prod"

$resourceGroupName = "rg-$application-$environment-$region"

$resourceGroupName
