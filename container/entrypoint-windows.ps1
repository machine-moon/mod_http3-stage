#Requires -Version 5

$ErrorActionPreference = 'Stop'

$root  = 'C:\httpd'
$certs = Join-Path $root 'conf\certs'
$port  = if ($env:H3_PORT) { $env:H3_PORT } else { '8443' }
$env:H3_PORT = $port

New-Item -ItemType Directory -Force -Path $certs | Out-Null

if (-not (Test-Path (Join-Path $certs 'server.crt'))) {
    throw "no certificate at $certs; mount one or rebuild the image"
}

# Windows has no /proc/self/fd; relay the log files to stdout.
$logs = Join-Path $root 'logs'
foreach ($f in 'error.log', 'access.log') {
    $path = Join-Path $logs $f
    if (-not (Test-Path $path)) { New-Item -ItemType File -Force -Path $path | Out-Null }
    Start-Job -ArgumentList $path -ScriptBlock {
        Get-Content -Path $args[0] -Wait -Tail 0 | ForEach-Object { Write-Host $_ }
    } | Out-Null
}

& (Join-Path $root 'bin\httpd.exe') -D FOREGROUND -f (Join-Path $root 'conf\httpd.conf') @args
exit $LASTEXITCODE
