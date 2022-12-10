$filePath = ".\2022\09\input.txt"
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

    $Lines | ForEach-Object {
        if ($_ -match $lineReGex) {
            switch ($Matches[1]) {
                "U" {
                    $u += $Matches[2]
                }
                "R" {
                    $r += $Matches[2]
                }
                "L" {
                    $l += $Matches[2]
                }
                "D" {
                    $d += $Matches[2]
                }
                Default {
                    throw "Unknown direction"
                }
            }
        }
        
    }
    return @{
        U = $u
        R = $r
        L = $l
        D = $d
    }
}

function Invoke-Part1 {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines
    )
    $headMatrix = @()
    $tailMatrix = @()
    $tailWayMatrix = @()


    
}


Get-LeftRightUpDownCount $lines