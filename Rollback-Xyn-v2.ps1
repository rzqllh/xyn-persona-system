# Roll back a v2.0 RC adapter migration by journal; dry-run default.
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$JournalPath,[switch]$Apply)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
function Sha([string]$f) { return (Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash.ToLowerInvariant() }
if (-not (Test-Path -LiteralPath $JournalPath -PathType Leaf)) {throw 'Journal not found'}
$journal = Get-Content -LiteralPath $JournalPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($journal.kind -ne 'adapter_migration' -or $journal.version -ne '2.0.0-rc1') {throw 'Wrong journal version/type'}
$backRoot = Split-Path -Parent $JournalPath
$actions = @($journal.actions)
$planned = New-Object 'System.Collections.Generic.List[object]'
foreach ($a in $actions) {
    if (-not (Test-Path -LiteralPath $a.destination -PathType Leaf)) {
        if ($a.existed) {throw "Old target missing: $($a.destination)"}
        continue
    }
    $cur = Sha $a.destination
    if ($cur -eq $a.beforehash -and $a.existed) {continue}
    if ($cur -ne $a.afterhash) {throw "Target changed since migration. Do not overwrite: $($a.destination)"}
    if ($a.existed) {
        $back = Join-Path $backRoot ('files\'+([string]$a.relative).Replace('/','\'))
        if (-not (Test-Path -LiteralPath $back -PathType Leaf)) {throw "Missing backup: $back"}
        if ((Sha $back) -ne $a.beforehash) {throw "Backup hash mismatch: $back"}
    }
    $planned.Add($a)
}
Write-Host "ROLLBACK READY | verified targets: $($actions.Count) | restore/delete: $($planned.Count)"
if (-not $Apply) {Write-Host 'DRY RUN: no writes. Add -Apply to roll back after review.';return}
foreach ($a in $planned) {
    if ((Sha $a.destination) -ne $a.afterhash) {throw "Concurrent edit: $($a.destination)"}
    if ($a.existed) {
        $back = Join-Path $backRoot ('files\'+([string]$a.relative).Replace('/','\'))
        Copy-Item -LiteralPath $back -Destination $a.destination -Force
        if ((Sha $a.destination) -ne $a.beforehash) {throw "Restore verification failed: $($a.destination)"}
    } else {
        Remove-Item -LiteralPath $a.destination -Force
        if (Test-Path -LiteralPath $a.destination) {throw "Delete verification failed: $($a.destination)"}
    }
}
Write-Host "ROLLBACK PASS: $($planned.Count) targets restored/removed. Other files and main SOUL unchanged."
