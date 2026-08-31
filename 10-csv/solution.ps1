# Chapter 10 - CSV
# Solution: Windows Server Inventory and Validation
# Status: In progress

$server = [PSCustomObject]@{
    ComputerName    = "SRV-APP-01"
    Environment     = "Production"
    Role            = "Web"
    ExpectedService = "W3SVC"
    Owner           = "PlatformTeam"
}

$server2 = [PSCustomObject]@{
    ComputerName    = "SRV-DB-01"
    Environment     = "Production"
    Role            = "Database"
    ExpectedService = "MSSQLSERVER"
    Owner           = "DataTeam"
}

$server3 = [PSCustomObject]@{
    ComputerName    = "SRV-TEST-01"
    Environment     = "Test"
    Role            = "Web"
    ExpectedService = "W3SVC"
    Owner           = "QA-Team"
}

$servers = $server, $server2, $server3

$servers.Count
$servers[0].GetType().FullName

$labPath = Join-Path -Path $env:TEMP -ChildPath "powershell-csv-lab"

Test-Path -Path $labPath -PathType Container

# TODO: Continue after the guided practice.
