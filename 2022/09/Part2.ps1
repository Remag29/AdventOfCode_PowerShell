$filePath = ".\2022\09\input.txt"
# $filePath = ".\2022\09\smallTest.txt"
# $filePath = ".\2022\09\smallTest2.txt"
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

function Get-Tails {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [int32] $TailLength,
        [Parameter(Mandatory = $false, Position = 1)] [psobject] $position
    )

    # Recursive end
    if ($TailLength -eq 0) {
        return $null
    }
    
    # Create the tail
    $tail = @{
        name     = "Tail $TailLength"
        position = @{
            vertical   = $position.vertical
            horizontal = $position.horizontal
        }
        tail     = Get-Tails -TailLength ($TailLength - 1) -position $position
    }
    return $tail
}

function Get-InitialMatrix {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $LRUDCount,
        [Parameter(Mandatory = $true, Position = 1)] [int32] $tailLength
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

    # Create the head and his tail
    $head = @{
        position = @{vertical = 0 - $LRUDCount.max.up; horizontal = 0 - $LRUDCount.max.left }
        tail     = Get-Tails -TailLength $tailLength -position @{vertical = 0 - $LRUDCount.max.up; horizontal = 0 - $LRUDCount.max.left }
    }

    # Place the head and tail
    $tailMouveMatrix[0 - $LRUDCount.max.up][0 - $LRUDCount.max.left] = 1


    return @{
        head     = $head
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
            throw "[Invoke-HeadMove] - Unknown direction"
        }
    }
}

function Test-IsTailNextToHead {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $head,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $tail
    )
    
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

function Update-TailMoveMatrix {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $TailMoveMatrix,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $Tail
    )
    

    if ($null -ne $Tail.tail) {
        Update-TailMoveMatrix -TailMoveMatrix $TailMoveMatrix -Tail $Tail.tail
    }
    else {
        $TailMoveMatrix[$Tail.position.vertical][$Tail.position.horizontal] = 1
    }
}

function Invoke-MoveTail {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $Head,
        [Parameter(Mandatory = $true, Position = 2)] [psobject] $Tail
    )

    if (-not (Test-IsTailNextToHead -head $head -tail $tail)) {
        # Tail is not next to head so need to move it

        if (($tail.position.vertical -eq $head.position.vertical)) {
            # T on the same line as head
            if (($tail.position.horizontal -gt $head.position.horizontal)) {
                # Need to move tail left
                Invoke-SimpleMove -ObjectToMove $tail -Direction "L"
            }
            else {
                # Need to move tail right
                Invoke-SimpleMove -ObjectToMove $tail -Direction "R"
            }
        }
        elseif (($tail.position.horizontal -eq $head.position.horizontal)) {
            # T on the same column as head
            if (($tail.position.vertical -gt $head.position.vertical)) {
                # Need to move tail top
                Invoke-SimpleMove -ObjectToMove $tail -Direction "U"
            }
            else {
                # Need to move tail bottom
                Invoke-SimpleMove -ObjectToMove $tail -Direction "D"
            }
        }
        elseif (($tail.position.vertical -gt $head.position.vertical)) {
            # Need to move tail top
            Invoke-SimpleMove -ObjectToMove $tail -Direction "U"
    
            if (($tail.position.horizontal -gt $head.position.horizontal)) {
                # Need to move tail left
                Invoke-SimpleMove -ObjectToMove $tail -Direction "L"
            }
            else {
                # Need to move tail right
                Invoke-SimpleMove -ObjectToMove $tail -Direction "R"
            } 
        }
        else {
            # Need to move tail bottom
            Invoke-SimpleMove -ObjectToMove $tail -Direction "D"
    
            if (($tail.position.horizontal -gt $head.position.horizontal)) {
                # Need to move tail left
                Invoke-SimpleMove -ObjectToMove $tail -Direction "L"
            }
            else {
                # Need to move tail right
                Invoke-SimpleMove -ObjectToMove $tail -Direction "R"
            }
        }

        # Move the tail childs
        if ($null -ne $tail.tail) {
            Invoke-MoveTail -Board $Board -Head $Tail -Tail $tail.tail
        }
    }
}

function Invoke-HeadMove {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $Instruction
    )
    # Move the head
    for ($i = 0; $i -lt $Instruction.distance; $i++) {

        Invoke-SimpleMove -ObjectToMove $Board.head -Direction $Instruction.direction

        if ($null -ne $Board.head.tail) {
            # Move the tail if there is one
            Invoke-MoveTail -Board $Board -Head $Board.head -Tail $Board.head.tail
        }

        # Update the tail move matrix
        Update-TailMoveMatrix -TailMoveMatrix $Board.tailMove -Tail $Board.head.tail

        # Show the board for each head move
        # Show-LiveBoard -Board $board
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

function Get-TailsList {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $head
    )
    
    $tailsList = @()
    $tailsList += $head.tail
    if ($null -ne $head.tail) {
        $tailsList += Get-TailsList -head $head.tail
    }
    return $tailsList
}

function Show-LiveBoard {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Board
    )
    Clear-Host

    $objectList = @()
    $objectList += $Board.head
    $objectList += Get-TailsList -head $Board.head
    Write-Host "list of objects: $($objectList.count)"
    $objectList | ForEach-Object {
        Write-Host "object: $($_.name) - $($_.position.vertical) - $($_.position.horizontal)"
    }
    
    for ($lineIndex = 0; $lineIndex -le $Board.gameSize.height; $lineIndex++) {
        for ($columnIndex = 0; $columnIndex -le $Board.gameSize.width; $columnIndex++) {

            $alreadywrite = $false
            foreach ($object in $objectList) {
                if (($object.position.vertical -eq $lineIndex) -and ($object.position.horizontal -eq $columnIndex)) {
                    if ($null -eq $object.name) {
                        Write-Host "H" -NoNewline
                        $alreadywrite = $true
                        break
                    }
                    else {
                        Write-Host "$($object.name.substring(5, 1))" -NoNewline
                        $alreadywrite = $true
                        break
                    } 
                }
            }
            if (-not $alreadywrite) {
                Write-Host "." -NoNewline
            }
        }
        Write-Host ""
    }
    Start-Sleep -Milliseconds 2000
}

function Invoke-Part2 {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines,
        [Parameter(Mandatory = $true, Position = 1)] [int32] $tailLength,
        [Parameter(Mandatory = $false, Position = 2)] [switch] $ShowTailMoveMatrix
    )
    
    # Initialise Matrix
    Write-Host "[Part2] - Initialising Matrix..." -ForegroundColor Cyan
    $board = Get-InitialMatrix -LRUDCount (Get-LeftRightUpDownCount -Lines $lines) -tailLength $tailLength
    
    # Move Head
    Write-Host "[Part2] - Moving Head..." -ForegroundColor Cyan
    $lines | ForEach-Object {
        $instruction = Get-InstructionFromLine -Line $_
        $board = Invoke-HeadMove -board $board -Instruction $instruction
    }

    # Show tail move matrix
    Write-Host "[Part2] - Showing tail matrix..." -ForegroundColor Cyan
    if ($ShowTailMoveMatrix) {
        Show-TailMoveMatrix -Board $board
    }

    # Calculate number of 1 in the tail move matrix
    Write-Host "[Part2] - Calculate tail path long..." -ForegroundColor Cyan
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


$result = Invoke-Part2 -Lines $lines -tailLength 9 #-ShowTailMoveMatrix
Write-Host "[Part2] - Result: $result" -ForegroundColor Green