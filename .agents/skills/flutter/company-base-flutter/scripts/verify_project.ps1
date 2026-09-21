[CmdletBinding()]
param(
  [string]$ProjectRoot = (Get-Location).Path,
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $resolvedRoot 'pubspec.yaml'))) {
  throw "Not a Flutter project root: $resolvedRoot"
}

$steps = @(
  @{ Name = 'format'; Executable = 'dart'; Args = @('format', 'lib', 'test') },
  @{ Name = 'generate'; Executable = 'dart'; Args = @('run', 'build_runner', 'build', '-d') },
  @{ Name = 'analyze'; Executable = 'flutter'; Args = @('analyze') },
  @{ Name = 'test'; Executable = 'flutter'; Args = @('test', '--test-randomize-ordering-seed', 'random') }
)

Push-Location $resolvedRoot
try {
  foreach ($step in $steps) {
    $displayCommand = "$($step.Executable) $($step.Args -join ' ')"
    if ($DryRun) {
      Write-Output "[dry-run] $displayCommand"
      continue
    }

    Write-Output "[verify:$($step.Name)] $displayCommand"
    $commandArgs = $step.Args
    & $step.Executable @commandArgs
    if ($LASTEXITCODE -ne 0) {
      throw "Verification step '$($step.Name)' failed with exit code $LASTEXITCODE."
    }
  }
} finally {
  Pop-Location
}

if (-not $DryRun) {
  Write-Output 'Project verification passed.'
}
