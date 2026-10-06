param([Parameter(Mandatory = $true)][string]$Godot)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Godot -PathType Leaf)) {
    throw "Godot console executable does not exist: $Godot"
}
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskFixture = Join-Path $taskRoot 'tests/editor_lifecycle_fixture'
$taskOutput = Join-Path ([IO.Path]::GetTempPath()) ('inventory-lifecycle-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $taskOutput 'addons') | Out-Null
Copy-Item -LiteralPath (Join-Path $taskRoot 'addons/simple_inventory') -Destination (Join-Path $taskOutput 'addons/simple_inventory') -Recurse
Copy-Item -LiteralPath (Join-Path $taskFixture 'addons/pilot_test') -Destination (Join-Path $taskOutput 'addons/pilot_test') -Recurse
Copy-Item -LiteralPath (Join-Path $taskFixture 'project.godot') -Destination (Join-Path $taskOutput 'project.godot')
New-Item -ItemType Directory -Path (Join-Path $taskOutput 'tests') | Out-Null
Get-ChildItem -LiteralPath (Join-Path $taskRoot 'tests') -File |
    Where-Object { $_.Extension -in '.gd', '.uid', '.tscn' } |
    Copy-Item -Destination (Join-Path $taskOutput 'tests')

foreach ($taskPhase in 0..1) {
    $taskLog = Join-Path $taskOutput ("phase-$taskPhase.log")
    & $Godot --headless --editor --path $taskOutput *> $taskLog
    $taskExitCode = $LASTEXITCODE
    $taskText = Get-Content -LiteralPath $taskLog -Raw
    if ($taskExitCode -ne 0 -or $taskText -match 'SCRIPT ERROR:' -or
        $taskText -notmatch "EDITOR LIFECYCLE phase=$taskPhase failures=0") {
        Write-Output $taskText
        throw "Lifecycle phase $taskPhase failed. Logs: $taskOutput"
    }
    Select-String -LiteralPath $taskLog -Pattern '^LIFECYCLE|^EDITOR LIFECYCLE' | ForEach-Object { $_.Line }
    if ($taskPhase -eq 0) {
        $taskUiLog = Join-Path $taskOutput 'blank-project-ui.log'
        & $Godot --headless --path $taskOutput res://tests/test_ui_isolation.tscn --quit-after 300 *> $taskUiLog
        $taskUiExit = $LASTEXITCODE
        $taskUiText = Get-Content -LiteralPath $taskUiLog -Raw
        if ($taskUiExit -ne 0 -or $taskUiText -match 'SCRIPT ERROR:|Parse Error:' -or
            $taskUiText -notmatch 'UI isolation: 10 passed, 0 failed') {
            Write-Output $taskUiText
            throw "Blank-project UI failed. Logs: $taskOutput"
        }
        Write-Output 'Blank-project UI: 10 passed, 0 failed (no host assets)'
    }
}
Write-Output "Lifecycle passed; temporary project and logs preserved: $taskOutput"
