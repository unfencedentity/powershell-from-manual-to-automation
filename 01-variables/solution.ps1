# ==========================================
# Solution - Exercise 1
# Variables
# ==========================================

# Store the resource type
$resource = "vm"

# Store the application name
$application = "cloud-org"

# Store the deployment environment
$environment = "prod"

# Store the Azure region
$region = "neu"

# Build the VM name dynamically
$vmName = "$resource-$application-$environment-$region"

# Display the result
Write-Host "VM Name: $vmName"
