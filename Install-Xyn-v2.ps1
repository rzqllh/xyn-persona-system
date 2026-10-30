# XYN v2.0 RC controlled adapter migration. Preview by default. PowerShell 5.1+.
# Does NOT modify live Hermes main SOUL, gateway, tokens, secrets, 9Router or runtime engines.
[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$HermesHome = (Join-Path $env:LOCALAPPDATA 'hermes')
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$homeDir = [Environment]::GetFolderPath('UserProfile')

function Sha([string]$file) {
    return (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()
}
function NoLink([string]$path) {
    $x = [IO.Path]::GetFullPath($path)
    while ($x) {
        if (Test-Path -LiteralPath $x) {
            $attrs = (Get-Item -LiteralPath $x -Force).Attributes
            if (($attrs -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Refusing symlink/reparse-point path: $x"
            }
        }
        $next = Split-Path -Path $x -Parent
        if (-not $next -or $next -eq $x) { break }
        $x = $next
    }
}
function ReadHash([object]$record,[string]$key) {
    $prop = $record.PSObject.Properties[$key]
    if ($null -eq $prop) {return ''}
    return ([string]$prop.Value).ToLowerInvariant()
}

$manifestFile = Join-Path $root 'MANIFEST.json'
$baselineFile = Join-Path $root 'BASELINE-V1.2-SHA256.json'
if (-not (Test-Path -LiteralPath $manifestFile -PathType Leaf)) {throw 'Missing MANIFEST.json'}
if (-not (Test-Path -LiteralPath $baselineFile -PathType Leaf)) {throw 'Missing v1.2 baseline hashes'}
$manifest = Get-Content -LiteralPath $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
$baseline = Get-Content -LiteralPath $baselineFile -Raw -Encoding UTF8 | ConvertFrom-Json
$verified = 0
foreach ($prop in $manifest.PSObject.Properties) {
    $src = Join-Path $root ($prop.Name.Replace('/','\'))
    if (-not (Test-Path -LiteralPath $src -PathType Leaf)) {throw "Missing source: $($prop.Name)"}
    if ((Sha $src) -ne ([string]$prop.Value).ToLowerInvariant()) {throw "Source hash mismatch: $($prop.Name)"}
    $verified++
}
if (-not (Test-Path -LiteralPath $HermesHome -PathType Container)) {throw "Hermes home missing: $HermesHome"}
NoLink $HermesHome
$personas = @(Get-ChildItem -LiteralPath (Join-Path $root 'personas') -Directory | Where-Object {$_.Name -match '^xyn-\d\d-[a-z]+$'} | Sort-Object Name)
if ($personas.Count -ne 21) {throw "Expected 21 canonical personas; got $($personas.Count)"}

$targets = New-Object 'System.Collections.Generic.List[object]'
function AddTarget([string]$relative, [string]$destination, [string]$runtime) {
    $source = Join-Path $root ($relative.Replace('/','\'))
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {throw "Missing adapter: $relative"}
    NoLink $destination
    $newHash = Sha $source
    $oldHash = ReadHash $baseline $relative
    $currentHash = ''
    $status = 'ADD'
    if (Test-Path -LiteralPath $destination) {
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            $status = 'CONFLICT_NONFILE'
        } else {
            $currentHash = Sha $destination
            if ($currentHash -eq $newHash) { $status = 'CURRENT' }
            elseif ($oldHash -and $currentHash -eq $oldHash) {$status = 'UPDATE_KNOWN_V1_2'}
            else {$status = 'CONFLICT_MODIFIED'}
        }
    }
    $targets.Add([pscustomobject]@{
        relative=$relative; source=$source; destination=$destination; runtime=$runtime
        status=$status; beforehash=$currentHash; afterhash=$newHash; existed=($currentHash -ne '')
    })
}

$hermesProfiles = Join-Path $HermesHome 'profiles'
$agyAgents = Join-Path $homeDir '.gemini\config\agents'
$agySkills = Join-Path $homeDir '.gemini\antigravity-cli\skills'
$ideSkills = Join-Path $homeDir '.gemini\config\skills'
$codexAgents = Join-Path $homeDir '.codex\agents'
foreach ($item in $personas) {
    $name = $item.Name
    if ($name -ne 'xyn-01-xyn') {
        foreach ($f in @('SOUL.md','STYLE.md','ROLE.md')) {
            AddTarget "adapters/hermes/profiles/$name/$f" (Join-Path $hermesProfiles "$name\$f") 'Hermes'
        }
    }
    AddTarget "adapters/antigravity/agents/$name.md" (Join-Path $agyAgents "$name.md") 'AGY'
    foreach ($f in @('SKILL.md','SOUL.md','STYLE.md','ROLE.md')) {
        $relative = "adapters/antigravity/skills/persona-$name/$f"
        AddTarget $relative (Join-Path $agySkills "persona-$name\$f") 'AGY-skill'
        AddTarget $relative (Join-Path $ideSkills "persona-$name\$f") 'IDE-skill'
    }
    AddTarget "adapters/codex/agents/$name.toml" (Join-Path $codexAgents "$name.toml") 'Codex'
}

Write-Host "XYN v2.0 RC | Source files verified: $verified | Target files: $($targets.Count)"
foreach ($type in @('CURRENT','ADD','UPDATE_KNOWN_V1_2','CONFLICT_MODIFIED','CONFLICT_NONFILE')) {
    $n = @($targets | Where-Object {$_.status -eq $type}).Count
    Write-Host ("{0}: {1}" -f $type,$n)
}
$conflicts = @($targets | Where-Object {$_.status -like 'CONFLICT*'})
if ($conflicts.Count -gt 0) {
    Write-Host 'Refused modifications (first 12):'
    $conflicts | Select-Object -First 12 relative,destination,status | Format-Table -AutoSize
    if ($Apply) {throw "Conflicts: $($conflicts.Count). Nothing written."}
}
Write-Host 'Main SOUL, credentials, gateway, model, Git, runtime engine: UNCHANGED.'
if (-not $Apply) {Write-Host 'DRY-RUN ONLY. Use -Apply only after reviewing diffs and backups.';return}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $env:LOCALAPPDATA "XynPersonaBackups\v2.0-rc1-$stamp"
if (Test-Path -LiteralPath $backupRoot) {throw 'Backup location unexpectedly exists.'}
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$actions = @($targets | Where-Object {$_.status -in @('ADD','UPDATE_KNOWN_V1_2')})
# Back up everything BEFORE changing any target.
foreach ($action in $actions) {
    if ($action.existed) {
        if ((Sha $action.destination) -ne $action.beforehash) {throw "Concurrent edit; stopped before target writes: $($action.destination)"}
        $back = Join-Path $backupRoot ('files\'+$action.relative.Replace('/','\'))
        New-Item -ItemType Directory -Path (Split-Path -Parent $back) -Force | Out-Null
        Copy-Item -LiteralPath $action.destination -Destination $back -ErrorAction Stop
        if ((Sha $back) -ne $action.beforehash) {throw "Backup mismatch: $back"}
    }
}
$journal = [pscustomobject]@{
    version='2.0.0-rc1'; created=(Get-Date).ToString('o'); kind='adapter_migration'
    actions=$actions
}
$journalPath = Join-Path $backupRoot 'journal.json'
$journal | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $journalPath -Encoding UTF8
$changed=0
try {
    foreach ($action in $actions) {
        NoLink $action.destination
        if ($action.existed -and (Sha $action.destination) -ne $action.beforehash) {throw "Concurrent edit: $($action.destination)"}
        if (-not $action.existed -and (Test-Path -LiteralPath $action.destination)) {throw "Target created concurrently: $($action.destination)"}
        New-Item -ItemType Directory -Path (Split-Path -Parent $action.destination) -Force | Out-Null
        Copy-Item -LiteralPath $action.source -Destination $action.destination -Force -ErrorAction Stop
        if ((Sha $action.destination) -ne $action.afterhash) {throw "Written file hash mismatch: $($action.destination)"}
        $changed++
    }
} catch {
    Write-Warning "Partial migration: $changed actions verified. Journal: $journalPath"
    Write-Warning 'Use Rollback-Xyn-v2.ps1 with -JournalPath after inspecting changes.'
    throw
}
Write-Host "ADAPTER MIGRATION PASS: $changed changed."
Write-Host "Rollback journal: $journalPath"
Write-Host 'No actual native dispatch, QA, runtime SOUL load, or messaging smoke test was performed.'
