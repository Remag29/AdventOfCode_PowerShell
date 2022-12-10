$filePath = "C:\Users\asus\Documents\Projet\AdventOfCod2022\2021\03\input.txt"
$lines = Get-Content -Path $filePath

$finalBitString = ""

function Get-InverseBitString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]
        $BitString
    )
    
    $inverseBitString = ""
    for ($i = 0; $i -lt $BitString.Length; $i++) {
        if ($BitString[$i] -eq "0") {
            $inverseBitString += "1"
        }
        else {
            $inverseBitString += "0"
        }
    }
    
    return $inverseBitString
}

for ($colonneIndex = 0; $colonneIndex -lt $lines[0].Length; $colonneIndex++) {
    $sum = 0
    foreach ($ligne in $lines) {
        $sum += $([int32]($ligne[$colonneIndex])-48)
    }

    if ($sum -gt $lines.Count/2) {
        # More than half of the lines are 1
        $finalBitString += "1"
    }
    else {
        # Less than half of the lines are 1
        $finalBitString += "0"
    }
    write-host $sum
}
Write-Host "Final bit string: $finalBitString" -ForegroundColor Yellow
Write-Host "Final bit string inverted: $(Get-InverseBitString -BitString $finalBitString)" -ForegroundColor Yellow

$gamma = [System.Convert]::ToInt32($finalBitString, 2)
$epsilon = [System.Convert]::ToInt32($(Get-InverseBitString -BitString $finalBitString), 2)


Write-Host "Gamma: $gamma" -ForegroundColor Cyan
Write-Host "Epsilon: $epsilon" -ForegroundColor Cyan
Write-Host "Solution : $($gamma * $epsilon)" -ForegroundColor Green

#4191876