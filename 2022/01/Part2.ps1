
$pathFile = ".\2022\01\NumbersPart1.txt"

$lines = Get-Content $pathFile
$elfeCount = 0
$max1 = 0
$max2 = 0
$max3 = 0

foreach ( $line in $lines) {
    #If empty line, reset elfeCount and save max
    if ([String]::IsNullOrWhiteSpace($line)) {
        if ($elfeCount -gt $max1) {
            Write-Host "New max1: $elfeCount" -ForegroundColor Cyan
            $max3 = $max2
            $max2 = $max1
            $max1 = $elfeCount
        }
        elseif ($elfeCount -gt $max2) {
            Write-Host "New max2: $elfeCount" -ForegroundColor Magenta
            $max3 = $max2
            $max2 = $elfeCount
        }
        elseif ($elfeCount -gt $max3) {
            Write-Host "New max3: $elfeCount" -ForegroundColor Yellow
            $max3 = $elfeCount
        }
        $elfeCount = 0
    }
    else {
        $elfeCount += [int32]$line
    }
}

Write-Host "Max1 : $max1" -ForegroundColor Green
Write-Host "Max2 : $max2" -ForegroundColor Green
Write-Host "Max3 : $max3" -ForegroundColor Green
Write-Host "Total Max : $($max1 + $max2 + $max3)" -ForegroundColor Green