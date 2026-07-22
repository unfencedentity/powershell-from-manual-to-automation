$servers = @(
    "web-01"
    "web-02"
    "db-01"
    "jump-01"
)

Write-Host "Total servers: $($servers.Count)"
Write-Host "First server: $($servers[0])"
Write-Host "Last server: $($servers[-1])"
Write-Host ""

foreach ($server in $servers) {
    Write-Host "Server: $server"
}
