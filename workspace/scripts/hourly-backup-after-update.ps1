$ErrorActionPreference = 'Stop'

$stateDir = Join-Path $env:USERPROFILE '.openclaw\update-state'
$metaFile = Join-Path $stateDir 'last-update-result.json'
$backupStateFile = Join-Path $stateDir 'last-backup-hash.txt'
$backupTargetRoot = 'C:\Users\deniz\OneDrive\Code\ZeusYedek'

if (-not (Test-Path $metaFile)) {
  Write-Output 'BACKUP_RESULT=SKIP'
  Write-Output 'BACKUP_REASON=no_update_metadata'
  exit 0
}

$meta = Get-Content $metaFile -Raw | ConvertFrom-Json
$action = [string]$meta.action
$hash = [string]$meta.remoteHash

if ([string]::IsNullOrWhiteSpace($hash)) {
  Write-Output 'BACKUP_RESULT=SKIP'
  Write-Output 'BACKUP_REASON=missing_hash'
  exit 0
}

$lastBackedHash = ''
if (Test-Path $backupStateFile) {
  $lastBackedHash = (Get-Content $backupStateFile -Raw -ErrorAction SilentlyContinue).Trim()
}

if ($action -ne 'updated') {
  Write-Output 'BACKUP_RESULT=SKIP'
  Write-Output 'BACKUP_REASON=last_run_not_updated'
  exit 0
}

if ($lastBackedHash -eq $hash) {
  Write-Output 'BACKUP_RESULT=SKIP'
  Write-Output 'BACKUP_REASON=already_backed_this_hash'
  exit 0
}

New-Item -ItemType Directory -Force -Path $backupTargetRoot | Out-Null
$zipName = 'openclaw-full-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.zip'
$zipPath = Join-Path $backupTargetRoot $zipName

tar -a -c -f $zipPath -C (Join-Path $env:USERPROFILE '') '.openclaw'
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $zipPath)) {
  Write-Output 'BACKUP_RESULT=FAILED'
  Write-Output 'BACKUP_REASON=zip_failed'
  exit 1
}

$hash | Set-Content -Path $backupStateFile -NoNewline
Write-Output 'BACKUP_RESULT=OK'
Write-Output "BACKUP_PATH=$zipPath"
Write-Output "BACKUP_HASH=$hash"
