param(
    [string]$Environment = "dev",
    [string]$App         = "core",
    [string]$Region      = "weu",
    [string]$Location    = "westeurope"
)

$resourceGroupName = "rg-$App-$Environment-$Region"

