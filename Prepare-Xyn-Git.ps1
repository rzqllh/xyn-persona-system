# Safe local Git preparation for the PUBLIC SOURCE release candidate. No push or remote writes.
[CmdletBinding()]
param([switch]$Initialize,[switch]$Commit)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$git=Get-Command git -ErrorAction Stop
$python=Get-Command python -ErrorAction Stop
Push-Location $root
try {
    & $python.Source 'tools/scan_public_release.py'
    if ($LASTEXITCODE -ne 0) {throw 'Public preflight failed.'}
    & $python.Source 'tools/build_adapters.py' '--check'
    if ($LASTEXITCODE -ne 0) {throw 'Generated adapter drift.'}
    & $python.Source '-m' 'unittest' 'discover' '-s' 'tests' '-p' 'test_*.py'
    if ($LASTEXITCODE -ne 0) {throw 'Static tests failed.'}
    if (-not $Initialize) {
        Write-Host 'PREVIEW COMPLETE. No git history or remote changed.'
        Write-Host 'Use -Initialize to create a local Git repository, -Initialize -Commit for a local commit.'
        return
    }
    if (Test-Path -LiteralPath (Join-Path $root '.git')) {
        throw 'Existing .git detected. This helper refuses to modify an existing repository.'
    }
    & $git.Source 'init' '-b' 'main'
    if ($LASTEXITCODE -ne 0) {throw 'Git init failed.'}
    & $git.Source 'add' '--all'
    if ($LASTEXITCODE -ne 0) {throw 'Git stage failed.'}
    Write-Host '=== STAGED CHANGES ==='
    & $git.Source 'status' '--short'
    if ($Commit) {
        & $git.Source 'commit' '-m' 'feat: prepare XYN v2.0.0-rc1 canonical multi-agent release candidate'
        if ($LASTEXITCODE -ne 0) {throw 'Commit failed (check git user.name / user.email).'}
        Write-Host 'LOCAL COMMIT READY; no remote configured and nothing published.'
    } else {
        Write-Host 'LOCAL STAGING READY; no commit or push performed.'
    }
} finally {Pop-Location}
