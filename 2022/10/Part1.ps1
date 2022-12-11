$filePath = ".\2022\10\input.txt"
$lines = Get-Content $filePath

function Get-InstructionFromLine {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $Line
    )
    $lineReGex = "([a-z]+) *([-*0-9]*)"
    if ($Line -match $lineReGex) {
        return @{
            operation = $Matches[1]
            number  = [int32]$Matches[2]
        }
    }
    else {
        throw "Line $Line does not match regex"
    }
    
}


function Invoke-Part1 {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines,
        [Parameter(Mandatory = $true, Position = 1)] [array] $CycleToCheck
    )
    $sixSignalsForces = 0
    $cycle = 0
    $xRegister = 1
    
    $Lines | ForEach-Object {
        $cycle++

        # First check the cycle
        if ($cycle -in $CycleToCheck) {
            Write-Host "Cycle $cycle : Adding $xRegister to six signals forces OUT ADDX"
            $sixSignalsForces += $xRegister*$cycle
        }

        # Second, execute the instruction
        $instruction = Get-InstructionFromLine -Line $_

        switch ($instruction.operation) {
            "noop" {
                # Do nothing
            }
            "addx" {
                $cycle++

                if ($cycle -in $CycleToCheck) {
                    Write-Host "Cycle $cycle : Adding $($xRegister) to six signals forces IN ADDX"
                    $sixSignalsForces += $xRegister*$cycle
                }

                $xRegister += $instruction.number
            }
            Default {
                throw "Unknown operation $($instruction.operation)"
            }
        }

    }
    return $sixSignalsForces
}


$cycleToCheck = @(20, 60, 100, 140, 180, 220)
$result = Invoke-Part1 -Lines $lines -CycleToCheck $cycleToCheck
Write-Host "Result is $result" -ForegroundColor Green