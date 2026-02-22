# Hourly OpenClaw beta update check
Write-Host "=== Hourly OpenClaw Update Check ==="

# Navigate to OpenClaw directory
Set-Location "C:\Users\deniz\OneDrive\Code\Zeus"

# Run beta update
Write-Host "`n[1/2] Running beta update..."
openclaw update.run --channel beta

# Run doctor and capture output
Write-Host "`n[2/2] Collecting system status..."
$doctorOutput = openclaw doctor --non-interactive 2>&1 | Out-String

# Summarize changes (simple bullet list)
$summary = @"
📋 OpenClaw Hourly Status:
$(($doctorOutput -split "`n" | Where-Object { $_ -match "✓|✗|⚠|updated|error|warning" } | ForEach-Object { "• " + $_ }))
"@

# Send to Telegram (using OpenClaw's message send)
Write-Host "`n[3/3] Sending summary to Telegram..."
$summary | openclaw message send --channel telegram --target 784562495

Write-Host "`nCheck completed at $(Get-Date)"
