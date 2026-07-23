# ==========================================
# Solution - Exercise 3
# Objects
# ==========================================

# Create a string object
$name = "Lucian"

# Inspect the object type
$name.GetType()

# Display the object's members
$name | Get-Member

Write-Host ""

# Properties
Write-Host "Length: $($name.Length)"

Write-Host ""

# Methods
$name.ToUpper()
$name.ToLower()
$name.Replace("a", "X")
$name.Contains("ci")
$name.StartsWith("Lu")
$name.EndsWith("an")
$name.Substring(2)
$name.IndexOf("a")

Write-Host ""

# Create an integer object
$number = 42

$number.GetType()

$number | Get-Member

Write-Host ""

# Create an array object
$servers = @(
    "web-01"
    "web-02"
)

$servers.GetType()

Get-Member -InputObject $servers

Write-Host ""

# Inspect an element inside the array
$servers[0].GetType()

$servers[0] | Get-Member

Write-Host ""

# Cmdlets also return objects
Get-Date

(Get-Date).GetType()

Get-Date | Get-Member

Write-Host ""

# Access properties from the returned object
(Get-Date).Year
(Get-Date).Month
(Get-Date).Day
