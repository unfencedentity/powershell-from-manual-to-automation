[CmdletBinding(SupportsShouldprocess = $True)]
param(
   [Parameter(Mandatory = $true)][string]$Environment,
   [Parameter(Mandatory = $true)][string]$App,
   [Parameter(Mandatory = $true)][string]$Region,
   [Parameter(Mandatory = $true)][string]$Location,

# Optional: Allows extending the default tag set
   [Parameter(Mandatory = $false)[hashtable]$AdditionalTags
)

$ErrorActionPreference = 'Stop'

# Naming convention for the resource group
$resourceGroupName = "rg-$App-$Environment-$Region"

# Default tagging
$tags = @{
   environment = $Environment
   app         = $App
   region      = $Region
   owner       = "cloud-org-infra"
}

# Merge any additional tags into the default tag set
if ($AdditionalTags) {
   foreach ($key in $AdditionalTags.Keys) {
       $tags[$key] = $AdditionalTags[$key]
   }
}
