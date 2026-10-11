# Writes the GitHub release text for a tag: docs/releases/<tag>.md if it exists, otherwise
# docs/releases/_template.md filled with the section of windjview/changes.txt for that version.
# ASCII only: Windows PowerShell 5.1 reads BOM-less scripts as ANSI (Ukrainian text lives in the template).
# usage: installer/release-notes.ps1 -Tag v2.1.6 -Out release-notes.md
param([Parameter(Mandatory)][string]$Tag, [Parameter(Mandatory)][string]$Out)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$version = $Tag.TrimStart('v')
$notes = Join-Path $repo "docs\releases\$Tag.md"
if (Test-Path $notes) {
    $text = [IO.File]::ReadAllText($notes, [Text.Encoding]::UTF8)
} else {
    $section = @(); $inside = $false
    foreach ($line in [IO.File]::ReadAllLines((Join-Path $repo 'windjview\changes.txt'))) {
        if ($line -match '^Changes in WinDjView-UA (\S+?):?(\s|$)') {
            if ($inside) { break }
            $inside = ($Matches[1].TrimEnd(':') -eq $version)
            continue
        }
        if ($line -match '^WinDjView version history') { break }
        if ($inside) { $section += $line }
    }
    $items = ($section -join "`n").Trim()
    if (-not $items) { $items = "See changes.txt" }
    $template = [IO.File]::ReadAllText((Join-Path $repo 'docs\releases\_template.md'), [Text.Encoding]::UTF8)
    $text = $template.Replace('{VERSION}', $version).Replace('{ITEMS}', $items)
}
[IO.File]::WriteAllText($Out, $text, (New-Object Text.UTF8Encoding $false))
Write-Host "release notes for $Tag -> $Out ($((Get-Item $Out).Length) bytes)"
