[CmdletBinding(SupportsShouldProcess = $true)]
param(
[Parameter(Mandatory = $true)][string]$Environment,
[Parameter(Mandatory = $true)][string]$App,
[Parameter(Mandatory = $true)][string]$Region,
[Parameter(Mandatory = $true)][string]$Location,

#Optional: allows extending the default tag set
[Paramater(Mandatory = $false)][hastable]$AdditionalTags
)
