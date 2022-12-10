$filePath = ".\2022\09\input.txt"
# $filePath = ".\2022\09\smallTest.txt"
$lines = Get-Content $filePath

function Get-LeftRightUpDownCount {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines
    )
    $lineReGex = "([UDLR]) ([0-9]+)"
    $r = 0
    $l = 0
    $u = 0
    $d = 0

    $verticalMove = 0
    $horizontalMove = 0

    $maxUp = 0
    $maxDown = 0
    $maxLeft = 0
    $maxRight = 0

    $Lines | ForEach-Object {
        if ($_ -match $lineReGex) {
            switch ($Matches[1]) {
                "U" {
                    $u += $Matches[2]
                    $verticalMove -= $Matches[2]
                }
                "R" {
                    $r += $Matches[2]
                    $horizontalMove += $Matches[2]
                }
                "L" {
                    $l += $Matches[2]
                    $horizontalMove -= $Matches[2]
                }
                "D" {
                    $d += $Matches[2]
                    $verticalMove += $Matches[2]
                }
                Default {
                    throw "Unknown direction"
                }
            }
            if ($verticalMove -lt $maxUp) {
                $maxUp = $verticalMove
            }
            elseif ($verticalMove -gt $maxDown) {
                $maxDown = $verticalMove
            }
            if ($horizontalMove -gt $maxRight) {
                $maxRight = $horizontalMove
            }
            elseif ($horizontalMove -lt $maxLeft) {
                $maxLeft = $horizontalMove
            }
        }
        
    }
    return @{
        finalPosition = @{
            vertical   = $verticalMove
            horizontal = $horizontalMove
        }
        max           = @{
            up    = $maxUp
            down  = $maxDown
            left  = $maxLeft
            right = $maxRight
        }
        count         = @{
            up    = $u
            down  = $d
            left  = $l
            right = $r
        }
    }
}

function Get-InitialMatrix {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $LRUDCount
    )
    
    $tailMouveMatrix = New-Object System.Collections.ArrayList

    $gameSize = @{height = $LRUDCount.max.down - $LRUDCount.max.up; width = $LRUDCount.max.right - $LRUDCount.max.left }

    for ($heightIndex = 0; $heightIndex -le $gameSize.height; $heightIndex++) {
        $tailMoveLine = New-Object System.Collections.ArrayList
        for ($widthIndex = 0; $widthIndex -le $gameSize.width; $widthIndex++) {
            $tailMoveLine.Add(0) | Out-Null
        }
        $tailMouveMatrix.Add($tailMoveLine) | Out-Null
    }

    # Place the head and tail
    $tailMouveMatrix[0 - $LRUDCount.max.up][0 - $LRUDCount.max.left] = 1

    return @{
        head     = @{position = @{vertical = 0 - $LRUDCount.max.up; horizontal = 0 - $LRUDCount.max.left } }
        tail     = @{position = @{vertical = 0 - $LRUDCount.max.up; horizontal = 0 - $LRUDCount.max.left } }
        tailMove = $tailMouveMatrix
        gameSize = $gameSize
    }
}

function Get-InstructionFromLine {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $Line
    )
    $lineReGex = "([UDLR]) ([0-9]+)"
    if ($Line -match $lineReGex) {
        return @{
            direction = $Matches[1]
            distance  = [int32]$Matches[2]
        }
    }
    else {
        throw "Line $Line does not match regex"
    }
    
}

function Invoke-SimpleMove {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $ObjectToMove,
        [Parameter(Mandatory = $true, Position = 1)] [string] $Direction
    )
    
    switch ($Direction) {
        "U" {
            $ObjectToMove.position.vertical--
        }
        "R" {
            $ObjectToMove.position.horizontal++
        }
        "L" {
            $ObjectToMove.position.horizontal--
        }
        "D" {
            $ObjectToMove.position.vertical++
        }
        Default {
            throw "[Invoke-HeadTailMove] - Unknown direction"
        }
    }
    return $ObjectToMove
}

function Test-IsTailNextToHead {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board
    )
    
    $head = $Board.head
    $tail = $Board.tail

    if (($tail.position.horizontal -gt $head.position.horizontal + 1) -or ($tail.position.horizontal -lt $head.position.horizontal - 1)) {
        # Tail is too at right or left of the head
        return $false
    }
    if (($tail.position.vertical -gt $head.position.vertical + 1) -or ($tail.position.vertical -lt $head.position.vertical - 1)) {
        # Tail is too at top or bottom of the head
        return $false
    }
    return $true
}

function Invoke-MoveTail {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $HeadInstruction
    )
    
    $head = $Board.head
    $tail = $Board.tail

    if (($tail.position.vertical -eq $head.position.vertical) -or ($tail.position.horizontal -eq $head.position.horizontal)) {
        # Just need to move the tail like the head
        $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction $HeadInstruction.direction
        $Board.tailMove[$tail.position.vertical][$tail.position.horizontal] = 1
        return $Board
    }
    if (($tail.position.vertical -gt $head.position.vertical)) {
        # Need to move tail top
        $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction "U"

        if (($tail.position.horizontal -gt $head.position.horizontal)) {
            # Need to move tail left
            $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction "L"
        }
        else {
            # Need to move tail right
            $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction "R"
        } 
    }
    else {
        # Need to move tail bottom
        $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction "D"

        if (($tail.position.horizontal -gt $head.position.horizontal)) {
            # Need to move tail left
            $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction "L"
        }
        else {
            # Need to move tail right
            $Board.tail = Invoke-SimpleMove -ObjectToMove $tail -Direction "R"
        }
    }

    # Actualise the tail move matrix
    $Board.tailMove[$tail.position.vertical][$tail.position.horizontal] = 1

    return $Board
}

function Invoke-HeadTailMove {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $Instruction
    )
    # Move the head
    for ($i = 0; $i -lt $Instruction.distance; $i++) {
        $Board.head = Invoke-SimpleMove -ObjectToMove $Board.head -Direction $Instruction.direction

        # Update the tail
        if (-not (Test-IsTailNextToHead -Board $Board)) {
            # Tail is too far from the head
            # We need to move it
            $Board = Invoke-MoveTail -Board $Board -HeadInstruction $Instruction
        }
    }

    return $Board
}

function Show-TailMoveMatrix {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board
    )
    $tailMoveMatrix = $Board.tailMove

    $tailMoveMatrix | ForEach-Object {
        $line = $_
        $line | ForEach-Object {
            if ($_ -eq 0) {
                Write-Host "." -NoNewline
            }
            else {
                Write-Host "#" -NoNewline
            }
        }
        Write-Host ""
    }
}

function Invoke-Part1 {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines,
        [Parameter(Mandatory = $false, Position = 1)] [switch] $ShowTailMoveMatrix
    )
    
    # Initialise Matrix
    Write-Host "[Part1] - Initialising Matrix..." -ForegroundColor Cyan
    $board = Get-InitialMatrix -LRUDCount (Get-LeftRightUpDownCount -Lines $lines)
    
    # Move Head
    Write-Host "[Part1] - Moving Head..." -ForegroundColor Cyan
    $lines | ForEach-Object {
        $instruction = Get-InstructionFromLine -Line $_
        $board = Invoke-HeadTailMove -board $board -Instruction $instruction
    }

    # Show tail move matrix
    Write-Host "[Part1] - Showing tail matrix..." -ForegroundColor Cyan

    if ($ShowTailMoveMatrix) {
        Show-TailMoveMatrix -Board $board
    }

    # Calculate number of 1 in the tail move matrix
    Write-Host "[Part1] - Calculate tail path long..." -ForegroundColor Cyan
    $result = 0
    $tailMoveMatrix = $board.tailMove
    $tailMoveMatrix | ForEach-Object {
        $line = $_
        $line | ForEach-Object {
            if ($_ -eq 1) {
                $result++
            }
        }
    }

    return $result

}


$result = Invoke-Part1 -Lines $lines #-ShowTailMoveMatrix
Write-Host "[Part1] - Result: $result" -ForegroundColor Green