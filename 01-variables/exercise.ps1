$resource   = "vm"
$application = "cloud-org"
$environment = "prod"
$region      = "neu"

$vmName = "$resource-$application-$environment-$region"

Write-Host $vmName
