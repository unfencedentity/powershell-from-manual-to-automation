param(
    [string]$Environment = "dev",
    [string]$App         = "core",
    [string]$Region      = "weu",
    [string]$Location    = "westeurope"
)

$resourceGroupName = "rg-$App-$Environment-$Region"

$resourceGroupName

$tags = @{
    environment = $Environment
    app         = $App
    region      = $Region
    owner       = "cloud-org-infra"
}

$tags

$tags["environment"]
$tags["owner"]

$Servers = @(
    "web01"
    "web02"
    "web03"
)

$Servers
$Servers[0]
$Servers[1]
$Servers[2]

foreach ($Server in $Servers) {
    $Server
}
