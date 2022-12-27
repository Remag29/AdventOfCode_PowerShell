# Day 12 - Part 1

function New-Points {
    param (
        [int]$x,
        [int]$y,
        [int]$Count,
        [int]$heuristic,
        [char]$letter
    )
    
    $points = @{
        x         = $x
        y         = $y
        count     = $Count
        heuristic = $heuristic
        letter    = $letter
    }

    return $points
}

function Get-StartPoint {
    param (
        [array] $Lines
    )
    
    foreach ($line in $Lines) {
        $index = $line.IndexOf("S")
        if ($index -ne -1) {
            $point = New-Points -X $Lines.IndexOf($line) -Y $index -letter $line[$index] -Count 0 -heuristic 0
            return $point
        }
    }
}

function Get-PointAt {
    param (
        [array] $Lines,
        [int] $X,
        [int] $Y
    )
    # Check if the point is out of the map
    if (($X -lt 0) -or ($Y -lt 0) -or ($X -ge $Lines.Count) -or ($Y -ge $Lines[$X].Length)) {
        return $null
    }

    $point = New-Points -X $X -Y $Y -letter $Lines[$X][$Y] -Count 0 -heuristic 0

    return $point
}

function Get-EndPoint {
    param (
        [array] $Lines
    )
    
    foreach ($line in $Lines) {
        $index = $line.IndexOf("E")
        if ($index -ne -1) {
            $point = New-Points -X $Lines.IndexOf($line) -Y $index -letter $line[$index] -Count 0 -heuristic 0
            return $point
        }
    }
}

function Test-Heuristic {
    param (
        [psobject]$Point1,
        [psobject]$Point2
    )
    
    if ($Point1.heuristic -lt $Point2.heuristic) {
        return 1
    }
    elseif ($Point1.heuristic -eq $Point2.heuristic) {
        return 0
    }
    else {
        return -1
    }
}

function Update-Heuristic {
    param (
        [psobject]$Point,
        [psobject]$Goal
    )
    # Heuristic = Manhattan distance + count
    $Point.heuristic = ([Math]::Abs($Point.x - $Goal.x) + [Math]::Abs($Point.y - $Goal.y)) + $Point.count
}

function Get-Neighbours {
    param (
        [psobject]$Point,
        [array]$Lines
    )
    $transitionsList = @("S", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "E")
    $actualTransition = $transitionsList.IndexOf("$($Point.letter)")
    $possibleRelativeNeighbours = @(
        @{x = 0; y = 1 }
        @{x = 0; y = -1 }
        @{x = 1; y = 0 }
        @{x = -1; y = 0 }
    )
    $neighbours = New-Object System.Collections.Generic.List[psobject]
    
    foreach ($possibleRelativeNeighbour in $possibleRelativeNeighbours) {
        $neighbour = Get-PointAt -Lines $Lines -X ($Point.x + $possibleRelativeNeighbour.x) -Y ($Point.y + $possibleRelativeNeighbour.y) -Count $Point.count++ -heuristic $Point.heuristic
        if ($null -eq $neighbour) {
            continue
        }
        # Check if the neighbour is a valid transition (same letter or next letter in the alphabet)
        elseif (($neighbour.letter -match $transitionsList[$actualTransition]) -or ($neighbour.letter -match $transitionsList[$actualTransition + 1]) -or ($neighbour.letter -lt $transitionsList[$actualTransition])) {
            $neighbours.Add($neighbour)
        }
    }

    return $neighbours
}

function Test-IspointInList {
    param (
        [psobject]$Point,
        [array]$List
    )
    
    $identicalList = $List | Where-Object { $_.x -eq $Point.x -and $_.y -eq $Point.y }
    if ($identicalList.Count -gt 0) {
        return $true
    }
    else {
        return $false
    }
}

function Get-BestPoint {
    param (
        [array]$OpenList
    )
    
    $bestPoint = $OpenList[0]
    foreach ($point in $OpenList) {
        if ($point.heuristic -lt $bestPoint.heuristic) {
            $bestPoint = $point
        }
    }
    return $bestPoint
}

function Invoke-Part1 {
    param (
        [array]$Lines
    )
    # Get start and end point
    $StartPoint = Get-StartPoint -Lines $Lines
    $EndPoint = Get-EndPoint -Lines $Lines
    $printCount = 0
    
    # Init lists
    $closeLists = New-Object System.Collections.ArrayList
    $openLists = New-Object System.Collections.ArrayList
    $openLists.Add($StartPoint) | Out-Null

    # Main loop
    while ($openLists.Count -gt 0) {
        $printCount++

        $currentPoint = Get-BestPoint -OpenList $openLists
        $openLists.Remove($currentPoint)
        
        # Check if we are at the end
        if (($currentPoint.x -eq $EndPoint.x) -and ($currentPoint.y -eq $EndPoint.y)) {
            return $currentPoint.count
        }
        
        # Get neighbours
        $neighbours = Get-Neighbours -Point $currentPoint -Lines $Lines

        # Loop through neighbours
        foreach ($neighbour in $neighbours) {
            if ((Test-IspointInList -Point $neighbour -List $closeLists) -or ((Test-IspointInList -Point $neighbour -List $openLists) -and ($neighbour.count -lt $currentPoint.count))) {
                continue
            }
            else {
                $neighbour.count = $currentPoint.count + 1
                Update-Heuristic -Point $neighbour -Goal $EndPoint
                $openLists.Add($neighbour) | Out-Null
            }
        }
        $closeLists.Add($currentPoint) | Out-Null

        if (($printCount % 500) -eq 0) {
            Write-Host "Actual point is: $($currentPoint.x), $($currentPoint.y), count: $($currentPoint.count), heuristic: $($currentPoint.heuristic), letter: $($currentPoint.letter)"
            Write-Host "Open list count: $($openLists.Count)"
            Write-Host "Close list count: $($closeLists.Count)"
        }
    }

    return -1
}

#########################################################################################
$filePath = ".\2022\12\input.txt"
# $filePath = ".\2022\12\smallTest.txt"
$lines = Get-Content $filePath

$time = Measure-Command -Expression {
    $result = Invoke-Part1 -Lines $lines
    Write-Host "Result: $result" -ForegroundColor Green
}
Write-Host "Time: $($time.TotalSeconds) seconds" -ForegroundColor Yellow