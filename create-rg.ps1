[CmdletBinding(SupportsShouldProcess = $true)]
param(
[Parameter(Mandatory = $true)][string]$Environment,
[Parameter(Mandatory = $true)][string]$App,
[Parameter(Mandatory = $true)][string]$Region,
[Parameter(Mandatory = $true)][string]$location,
[Parameter(Mandatory = $false)][hashtable]$AdditionalTags
)

$ErrorActionPreference = "Stop"

$resourceGroupName = "rg-$App-$Environment-$Region"

$tags = @{
    environment = $Environment
    app         = $App
    region      = $Region
    owner       = "cloud-org-infra"
}
