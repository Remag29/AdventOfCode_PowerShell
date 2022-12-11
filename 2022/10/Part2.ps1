$filePath = ".\2022\10\input.txt"
# $filePath = ".\2022\10\smallTest.txt"
$lines = Get-Content $filePath


function Get-InstructionFromLine {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $Line
    )
    $lineReGex = "([a-z]+) *([-*0-9]*)"
    if ($Line -match $lineReGex) {
        return @{
            operation = $Matches[1]
            number    = [int32]$Matches[2]
        }
    }
    else {
        throw "Line $Line does not match regex"
    }
    
}

function Get-Sprite {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [int32] $RegistryXValue
    )

    $sprite = @()
    for ($i = 0; $i -le 40; $i++) {
        if ($i -eq $RegistryXValue - 1 -or $i -eq $RegistryXValue -or $i -eq $RegistryXValue + 1) {
            $sprite += "#"
        }
        else {
            $sprite += "."
        }
    }
    return $sprite
}

function Show-Sprite {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Sprite
    )
    
    $spriteString = $Sprite -join ""
    Write-Host $spriteString -ForegroundColor Cyan
}

function Invoke-Part2 {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines
    )
    
    $sixSignalsForces = 0
    $cycle = 0
    $xRegister = 1
    $finalLineSprite = @()
    
    $Lines | ForEach-Object {

        # Second, execute the instruction
        $instruction = Get-InstructionFromLine -Line $_
        
        switch ($instruction.operation) {
            "noop" {
                # Do nothing
                $cycle++
                $actualSprite = Get-Sprite -RegistryXValue $xRegister
                $finalLineSprite += $actualSprite[($cycle % 40)-1]
                if ($cycle%40 -eq 0) {
                    Show-Sprite -Sprite $finalLineSprite
                    $finalLineSprite = @()
                }    
            }
            "addx" {
                $cycle++
                $actualSprite = Get-Sprite -RegistryXValue $xRegister
                $finalLineSprite += $actualSprite[($cycle % 40)-1]
                if ($cycle%40 -eq 0) {
                    Show-Sprite -Sprite $finalLineSprite
                    $finalLineSprite = @()
                }
                $cycle++
                $actualSprite = Get-Sprite -RegistryXValue $xRegister
                $finalLineSprite += $actualSprite[($cycle % 40)-1]
                if ($cycle%40 -eq 0) {
                    Show-Sprite -Sprite $finalLineSprite
                    $finalLineSprite = @()
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

Invoke-Part2 -Lines $lines