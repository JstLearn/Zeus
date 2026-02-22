#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$composeFile = "C:\Users\deniz\OneDrive\Code\Zeus\docker-compose-zeus.yml"
Write-Output "=== Docker compose update ==="
docker-compose -f $composeFile pull
if ($LASTEXITCODE -ne 0) { throw "docker-compose pull failed" }
docker-compose -f $composeFile up -d --remove-orphans
if ($LASTEXITCODE -ne 0) { throw "docker-compose up -d failed" }
Write-Output "=== Update complete ==="
