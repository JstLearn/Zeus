#!/usr/bin/env pwsh

$ErrorActionPreference = "Continue" # Do not stop on native commands globally so we can check $LASTEXITCODE

$workspace = "C:\Users\deniz\.openclaw\workspace"
$stateDir = "C:\Users\deniz\.openclaw\update-state"
$stateFile = "$stateDir\last-update-machine.txt"

if (!(Test-Path $stateDir)) {
    New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
}

try {
    Set-Location $workspace

    # Fetch latest
    git fetch origin main 2>&1 | Out-String | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Git fetch failed with exit code $LASTEXITCODE" }

    $behindBeforeStr = git rev-list --count HEAD..origin/main
    if ($LASTEXITCODE -ne 0) { throw "Git rev-list failed" }
    $behindBefore = [int]$behindBeforeStr
    
    if ($behindBefore -gt 0) {
        $status = git status --porcelain
        if ($status) {
            git add .
            git commit -m "Auto backup before update $(Get-Date -Format 's')"
            if ($LASTEXITCODE -ne 0) { throw "Git commit failed" }
        }

        # Get logs before rebasing so we only get the new upstream commits
        $logStr = git log HEAD..origin/main --pretty=format:"  - %s"
        
        # Git Rebase
        # -X theirs : in a rebase, 'theirs' refers to our local commits that we are rebasing onto upstream ('ours').
        # Using -X theirs means if there is a conflict, our local modifications will override the upstream changes.
        git rebase origin/main -X theirs
        if ($LASTEXITCODE -ne 0) { 
            git rebase --abort
            throw "Git rebase failed and was aborted" 
        }

        pnpm install
        
        $behindAfterStr = git rev-list --count HEAD..origin/main
        $behindAfter = [int]$behindAfterStr
        
        $runAtUtc = (Get-Date).ToUniversalTime().ToString("o")
        $runAtLocal = (Get-Date).ToString("o")

        $output = @"
RESULT=UPDATED
RUN_AT_UTC=$runAtUtc
RUN_AT_LOCAL=$runAtLocal
BEHIND_BEFORE=$behindBefore
BEHIND_AFTER=$behindAfter
REASON=Successfully rebased and applied local changes

- Öne çıkan değişiklikler:
$logStr
"@
        Set-Content -Path $stateFile -Value $output -Encoding UTF8
    } else {
        $runAtUtc = (Get-Date).ToUniversalTime().ToString("o")
        $runAtLocal = (Get-Date).ToString("o")
        
        $output = @"
RESULT=OK
RUN_AT_UTC=$runAtUtc
RUN_AT_LOCAL=$runAtLocal
BEHIND_BEFORE=0
BEHIND_AFTER=0
REASON=Already up to date
"@
        Set-Content -Path $stateFile -Value $output -Encoding UTF8
    }
} catch {
    $runAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    $runAtLocal = (Get-Date).ToString("o")
    $errMsg = $_.Exception.Message -replace "`n", " "
    
    $output = @"
RESULT=FAILED
RUN_AT_UTC=$runAtUtc
RUN_AT_LOCAL=$runAtLocal
BEHIND_BEFORE=0
BEHIND_AFTER=0
REASON=$errMsg
"@
    Set-Content -Path $stateFile -Value $output -Encoding UTF8
}
