$filePath = ".\2022\08\input.txt"
$lines = Get-Content $filePath
$visibleTrees = 0
$treeTested = 0

function Test-IsTreeVisible {
    [CmdletBinding()]
    param (
        [char]$actualTreeHeight,
        [char[]]$side
    )
    
    foreach ($tree in $side) {
        if ($tree -ge $actualTreeHeight) {
            return $false
        }
    }
    return $true
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
        $treeTested++

        # Get the actual tree height
        $actualTreeHeight = $lines[$lineIndex][$columnIndex]

        # Get the sides trees (Left, Right, Up, Down)
        $leftSide = $lines[$lineIndex].Substring(0, $columnIndex).ToCharArray()
        $rightSide = $lines[$lineIndex].Substring($columnIndex+1, $lines[$lineIndex].ToCharArray().Count - $columnIndex - 1).ToCharArray()
        $upSide = Get-UpSide -lineIndex $lineIndex -columnIndex $columnIndex -lines $lines
        $downSide = Get-DownSide -lineIndex $lineIndex -columnIndex $columnIndex -lines $lines

        # Test if the tree is visible
        if ((Test-IsTreeVisible -actualTreeHeight $actualTreeHeight -side $leftSide) -or (Test-IsTreeVisible -actualTreeHeight $actualTreeHeight -side $rightSide) -or (Test-IsTreeVisible -actualTreeHeight $actualTreeHeight -side $upSide) -or (Test-IsTreeVisible -actualTreeHeight $actualTreeHeight -side $downSide)) {
            $visibleTrees++
        }

    }
}

# Adding edges
$visibleTrees += ($lines.Length * $lines.Length) - (($lines.Length - 2) * ($lines.Length - 2) )

Write-Host "Visible trees: $visibleTrees" -foregroundcolor green
Write-Host "Trees tested: $treeTested" -foregroundcolor Cyan