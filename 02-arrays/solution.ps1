# ==========================================
# Solution - Exercise 2
# Arrays
# ==========================================

# Create an array of server names
$servers = @(
    "web-01"
    "web-02"
    "db-01"
    "jump-01"
)

# Display the total number of servers
Write-Host "Total servers: $($servers.Count)"

# Display the first server
Write-Host "First server: $($servers[0])"

# Display the last server
Write-Host "Last server: $($servers[-1])"

Write-Host ""

# Iterate through every server in the array
foreach ($server in $servers) {
    Write-Host "Server: $server"
}

Write-Host ""

# Generate an array dynamically
$generatedServers = foreach ($i in 1..1000) {
    "server$i"
}

# Display information about the generated array
Write-Host "Generated servers: $($generatedServers.Count)"
Write-Host "First generated server: $($generatedServers[0])"
Write-Host "Last generated server: $($generatedServers[-1])"
