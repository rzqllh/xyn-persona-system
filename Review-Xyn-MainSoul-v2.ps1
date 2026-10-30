# Exact v1.2 addendum replacement into main Hermes SOUL. PREVIEW default.
# Requires separate full-file current SHA256 on -Apply; doesn't restart any process.
[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$ExpectedSha256 = '',
    [int]$MaxCharacters = 20000,
    [string]$HermesHome = (Join-Path $env:LOCALAPPDATA 'hermes')
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$soul=Join-Path $HermesHome 'SOUL.md'
$oldPath=Join-Path $root 'baseline\v1.2-main-addendum.md'
$newPath=Join-Path $root 'adapters\hermes\main\XYN-QUINELLA-ADDENDUM.md'
foreach ($p in @($soul,$oldPath,$newPath)) {
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) {throw "Required file missing: $p"}
}
$sha=(Get-FileHash -LiteralPath $soul -Algorithm SHA256).Hash.ToLowerInvariant()
$bytes=[IO.File]::ReadAllBytes($soul)
$strictUtf8=New-Object System.Text.UTF8Encoding($false,$true)
$hasBom=($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191)
$offset=if($hasBom){3}else{0}
$text=$strictUtf8.GetString($bytes,$offset,$bytes.Length-$offset)
$old=[IO.File]::ReadAllText($oldPath,[Text.Encoding]::UTF8).Trim()
$new=[IO.File]::ReadAllText($newPath,[Text.Encoding]::UTF8).Trim()
$begin='<!-- XYN-QUINELLA-CONTROLLER-v1.2.0 BEGIN -->'
$end='<!-- XYN-QUINELLA-CONTROLLER-v1.2.0 END -->'
$nextBegin='<!-- XYN-QUINELLA-CONTROLLER-v2.0.0 BEGIN -->'
if ($text.Contains($nextBegin)) {throw 'v2 controller already present. Refusing duplicate patch.'}
$start=$text.IndexOf($begin,[StringComparison]::Ordinal)
if ($start -lt 0) {throw 'v1.2 begin marker not found'}
$endAt=$text.IndexOf($end,$start,[StringComparison]::Ordinal)
if ($endAt -lt 0) {throw 'v1.2 end marker not found'}
$endAt+=$end.Length
if ($text.IndexOf($begin,$endAt,[StringComparison]::Ordinal) -ge 0) {throw 'Duplicate v1.2 controller blocks'}
$found=$text.Substring($start,$endAt-$start)
function Norm([string]$x) {return $x.Replace("`r`n","`n").Trim()}
if ((Norm $found) -cne (Norm $old)) {throw 'Existing v1.2 addendum differs from canonical baseline. Manual review required.'}
$lineEnd=if ($found.Contains("`r`n")){"`r`n"}else{"`n"}
$newLines=$new.Replace("`r`n","`n").Replace("`n",$lineEnd)
$proposal=$text.Substring(0,$start)+$newLines+$text.Substring($endAt)
if (-not $proposal.Contains('Lion Guardian')) {throw 'Lion Guardian marker missing; stopped.'}
if ($proposal.Length -gt $MaxCharacters) {throw "Proposed SOUL length $($proposal.Length) exceeds guard $MaxCharacters. Do not apply automatically."}
Write-Host 'XYN RITSUKA SOUL REVIEW — no automatic append.'
Write-Host "Baseline SHA256: $sha"
Write-Host "Characters: $($text.Length) -> $($proposal.Length)"
Write-Host 'Changed region: v1.2 controller block -> v2.0 block, rest preserved.'
Write-Host 'Native delegation remains unverified; replacement changes instructions only.'
if (-not $Apply) {Write-Host 'PREVIEW ONLY. To apply: -Apply -ExpectedSha256 <exact hash from this preview>.';return}
if (-not $ExpectedSha256 -or $ExpectedSha256.ToLowerInvariant() -ne $sha) {throw 'Explicit full-file ExpectedSha256 is missing or wrong.'}
$shaNow=(Get-FileHash -LiteralPath $soul -Algorithm SHA256).Hash.ToLowerInvariant()
if ($shaNow -ne $sha) {throw 'Main SOUL changed after preview; refusing patch.'}
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$backDir=Join-Path $env:LOCALAPPDATA "XynPersonaBackups\main-soul-v2-$stamp"
New-Item -ItemType Directory -Path $backDir -Force | Out-Null
$back=Join-Path $backDir 'SOUL.before.md'
Copy-Item -LiteralPath $soul -Destination $back
if ((Get-FileHash -LiteralPath $back -Algorithm SHA256).Hash.ToLowerInvariant() -ne $sha) {throw 'Backup verification failed.'}
$encoder=New-Object Text.UTF8Encoding($false)
$payload=$encoder.GetBytes($proposal)
if ($hasBom) {
    $withBom=New-Object byte[] ($payload.Length+3)
    $withBom[0]=239;$withBom[1]=187;$withBom[2]=191
    [Array]::Copy($payload,0,$withBom,3,$payload.Length)
    $payload=$withBom
}
$tmp=Join-Path $backDir 'SOUL.proposed.md'
[IO.File]::WriteAllBytes($tmp,$payload)
try {
    if ((Get-FileHash -LiteralPath $soul -Algorithm SHA256).Hash.ToLowerInvariant() -ne $sha) {throw 'Concurrent live edit; aborting.'}
    Copy-Item -LiteralPath $tmp -Destination $soul -Force
    if ((Get-FileHash -LiteralPath $soul -Algorithm SHA256).Hash.ToLowerInvariant() -ne (Get-FileHash -LiteralPath $tmp -Algorithm SHA256).Hash.ToLowerInvariant()) {
        throw 'Post-write verification failed.'
    }
} catch {
    # Fail closed and restore from known-good local backup if a write began.
    Copy-Item -LiteralPath $back -Destination $soul -Force
    throw
}
Write-Host "MAIN SOUL PATCH PASS | Backup: $back"
Write-Host 'Start a fresh isolated session for evaluation. No gateway restart was performed.'
