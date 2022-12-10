$pathFile = ".\2022\04\input.txt"
$lines = Get-Content $pathFile


function Get-SidesNumbers() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $line
    )
    $reGex = "^(.+)-(.+),(.+)-(.+)$"

    if ($line -match $reGex) {
        $min1 = [int32]$Matches[1]
        $max1 = [int32]$Matches[2]
        $min2 = [int32]$Matches[3]
        $max2 = [int32]$Matches[4]
    }

    return @{
        elfe1 = @{min = $min1; max = $max1 }; 
        elfe2 = @{min = $min2; max = $max2 }
    }
}

function Test-RangeInOther() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $ElfesObject
    )

    $elfe1 = $ElfesObject.elfe1
    $elfe2 = $ElfesObject.elfe2

    if (($elfe1.min -ge $elfe2.min) -and ($elfe1.max -le $elfe2.max)) {
        # elfe1 is in elfe2
        return $true
    }
    elseif (($elfe2.min -ge $elfe1.min) -and ($elfe2.max -le $elfe1.max)) {
        # elfe2 is in elfe1
        return $true
    }
    else {
        # elfe1 and elfe2 are not in the same range
        return $false
    }
}


$finalResult = 0

$lines | ForEach-Object {
    $elfesMinMax = Get-SidesNumbers -line $_
    if (Test-RangeInOther -ElfesObject $elfesMinMax) {
        $finalResult++
    }
}

Write-Host "Result: $finalResult" -ForegroundColor Green