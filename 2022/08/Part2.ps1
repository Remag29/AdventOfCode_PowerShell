[CmdletBinding()]
param()

$filePath = ".\2022\08\input.txt"
$lines = Get-Content $filePath
$bestScore = 0

function Get-TreeScore {
    param (
        [char]$treeSize,
        [char[]]$upSide,
        [char[]]$downSide,
        [char[]]$leftSide,
        [char[]]$rightSide
    )

    # Right
    $scoreTree = 0
    $bestSize = 0
    for ($i = 0; $i -lt $rightSide.Count; $i++) {
        if ($rightSide[$i] -ge $treeSize) {
            $scoreTree++
            break
        }
        elseif ($rightSide[$i] -ge $bestSize) {
            $scoreTree++
            $bestSize = $rightSide[$i]
        }
    }
    $scoreRight= $scoreTree

    # Left
    $scoreTree = 0
    $bestSize = 0
    for ($i = $leftSide.Count - 1; $i -ge 0 ; $i--) {
        if ($leftSide[$i] -ge $treeSize) {
            $scoreTree++
            break
        }
        elseif ($leftSide[$i] -ge $bestSize) {
            $scoreTree++
            $bestSize = $leftSide[$i]
        }
    }
    $scoreLeft= $scoreTree

    # Up
    $scoreTree = 0
    $bestSize = 0
    for ($i = $upSide.Count - 1; $i -ge 0 ; $i--) {
        if ($upSide[$i] -ge $treeSize) {
            $scoreTree++
            break
        }
        elseif ($upSide[$i] -ge $bestSize) {
            $scoreTree++
            $bestSize = $upSide[$i]
        }
    }
    $scoreUp = $scoreTree

    # Down
    $scoreTree = 0
    $bestSize = 0
    for ($i = 0; $i -lt $downSide.Count; $i++) {
        if ($downSide[$i] -ge $treeSize) {
            $scoreTree++
            break
        }
        elseif ($downSide[$i] -ge $bestSize) {
            $scoreTree++
            $bestSize = $downSide[$i]
        }
    }
    $scoreDown = $scoreTree

    return $scoreRight * $scoreLeft * $scoreUp * $scoreDown
}

function Get-UpSide {
    param (
        [int]$lineIndex,
        [int]$columnIndex,
        [string[]]$lines
    )
    $upSide = ""
    for ($i = 0; $i -lt $lineIndex; $i++) {
        $upSide += $lines[$i][$columnIndex]
    }
    return $upSide.ToCharArray()
}

function Get-DownSide {
    param (
        [int]$lineIndex,
        [int]$columnIndex,
        [string[]]$lines
    )

    $downSide = ""
    for ($i = $lineIndex + 1; $i -lt $lines.Length; $i++) {
        $downSide += $lines[$i][$columnIndex]
    }
    return $downSide.ToCharArray()    
}

for ($lineIndex = 1; $lineIndex -lt $lines.Length - 1; $lineIndex++) {
    for ($columnIndex = 1; $columnIndex -lt $lines[0].ToCharArray().Count - 1; $columnIndex++) {

        $treeSize = $lines[$lineIndex][$columnIndex]

        # Get the sides trees (Left, Right, Up, Down)
        $leftSide = $lines[$lineIndex].Substring(0, $columnIndex).ToCharArray()
        $rightSide = $lines[$lineIndex].Substring($columnIndex + 1, $lines[$lineIndex].ToCharArray().Count - $columnIndex - 1).ToCharArray()
        $upSide = Get-UpSide -lineIndex $lineIndex -columnIndex $columnIndex -lines $lines
        $downSide = Get-DownSide -lineIndex $lineIndex -columnIndex $columnIndex -lines $lines

        # Get scrore from tree
        if ($treeSize -ne "0") {
            $treeScore = Get-TreeScore -treeSize $treeSize -upSide $upSide -downSide $downSide -leftSide $leftSide -rightSide $rightSide
        }

        # Update if better score
        if ($treeScore -gt $bestScore) {
            Write-Host "Tree score: $treeScore" -ForegroundColor Cyan
            Write-Host "Tree size: $treeSize" -ForegroundColor Cyan
            Write-Host "Tree position : [$lineIndex][$columnIndex]" -ForegroundColor Cyan
            Write-Host "Left side: $leftSide" -ForegroundColor Green
            Write-Host "Right side: $rightSide" -ForegroundColor Magenta
            Write-Host "Up side: $upSide" -ForegroundColor Yellow
            Write-Host "Down side: $downSide" -ForegroundColor Red
            $bestScore = $treeScore
        }
    }
}

Write-host "Best score: $bestScore" -ForegroundColor Green
#444528