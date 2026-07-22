$name = "  Lucian  "

Write-Host "Length: $($name.Length)"
Write-Host "Trimmed: $($name.Trim())"
Write-Host "Uppercase: $($name.ToUpper())"
Write-Host "Contains 'ci': $($name.Contains('ci'))"

$resourceName = "vm-core-prod-weu"
$parts = $resourceName.Split("-")

Write-Host "Resource type: $($parts[0])"
Write-Host "Environment: $($parts[2])"
