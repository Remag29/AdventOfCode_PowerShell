$filePath = ".\2022\05\input.txt"
$lines = Get-Content $filePath


# Get column count
$columnsCount = 0
$lines | ForEach-Object {
    if ($_ -match "^.+ ([2-9]) $") {
        $columnsCount = $Matches[1]
    }
}

Write-Host "Columns count: $columnsCount" -ForegroundColor DarkMagenta

# Set columns into list
$columnsList = @()
for ($i = 1; $i -le $columnsCount; $i++) {
    $columnsList += @{
        Column = $i
        Seats  = [System.Collections.ArrayList]@()
    }
}
$lines | ForEach-Object {
    if ($_ -match "\[[A-Z]\]") {
        for ($charIndex = 1; $charIndex -lt $_.Length - 1; $charIndex += 4) {
            if ($_[$charIndex] -match "[A-Z]") {
                $columnsList[$charIndex / 4].Seats.Add($_[$charIndex]) | Out-Null
                Write-Host "Char: $($_[$charIndex])" -ForegroundColor Green
            }
            else {
                write-host "Char: $($_[$charIndex])" -ForegroundColor Red
            }
            
        }
    }
}

# Reverse every column
$columnsList | ForEach-Object {
    $_.Seats.Reverse() | Out-Null
}

function Invoke-Move1by1 {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [int32] $NumberOfMove,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $FromColumn,
        [Parameter(Mandatory = $true, Position = 2)] [psobject] $ToColumn
    )

    for ($i = 0; $i -lt $NumberOfMove; $i++) {
        
        $ToColumn.Seats.Add( $FromColumn.Seats[$FromColumn.Seats.Count - 1]) | Out-Null
        $FromColumn.Seats.RemoveAt($FromColumn.Seats.Count - 1)
    }
}

function Invoke-MoveByBlock {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [int32] $NumberOfMove,
        [Parameter(Mandatory = $true, Position = 1)] [psobject] $FromColumn,
        [Parameter(Mandatory = $true, Position = 2)] [psobject] $ToColumn
    )

    for ($i = $NumberOfMove; $i -gt 0; $i--) {
        
        $ToColumn.Seats.Add( $FromColumn.Seats[$FromColumn.Seats.Count - $i]) | Out-Null
    }
    for ($i = 0; $i -lt $NumberOfMove; $i++) {
        $FromColumn.Seats.RemoveAt($FromColumn.Seats.Count - 1) | Out-Null
    }
}

# Interprete the instructions
$lines | ForEach-Object {
    if ($_ -match "move ([0-9]+) from ([0-9]+) to ([0-9]+)") {
        $numberOfMove = $Matches[1]
        $fromColumn = $columnsList | Where-Object { $_.Column -eq $Matches[2] }
        $toColumn = $columnsList | Where-Object { $_.Column -eq $Matches[3] }
        Invoke-MoveByBlock -NumberOfMove $numberOfMove -FromColumn $fromColumn -ToColumn $toColumn
    }
}

# Generate the final string of last letter of each column
$finalString = ""
$columnsList | ForEach-Object {
    $finalString += $_.Seats[$_.Seats.Count - 1]
}

Write-Host "Final string: $finalString" -ForegroundColor DarkGreen