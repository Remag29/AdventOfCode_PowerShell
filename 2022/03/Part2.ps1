$pathFile = ".\2022\03\input.txt"
$lines = Get-Content $pathFile

$resultList = @()

for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex += 3) {

    $sac1 = $lines[$lineIndex]
    $sac2 = $lines[$lineIndex + 1]
    $sac3 = $lines[$lineIndex + 2]

    Write-Host "$sac1" -ForegroundColor Cyan
    Write-Host "$sac2" -ForegroundColor Magenta
    Write-Host "$sac3" -ForegroundColor Yellow

    :labelA for ($indexSac2 = 0; $indexSac2 -lt $sac2.Length; $indexSac2++) {
        if ($sac1 -cmatch $sac2[$indexSac2]) {
            for ($indexSac3 = 0; $indexSac3 -lt $sac3.Length; $indexSac3++) {
                if ($sac2[$indexSac2] -cmatch $sac3[$indexSac3]) {
                    Write-Host "Match found" -ForegroundColor DarkYellow
                    Write-Host "$($sac3[$indexSac3])" -ForegroundColor Green
                    $resultList += $sac3[$indexSac3]
                    break labelA
                }
            }
        }
    }
}

Write-Host "Result:" -ForegroundColor Cyan
Write-Host $resultList

$finalResult = 0

$resultList | ForEach-Object {
    $intConvert = [int]([char]$_)
    if ($intConvert -gt 96) {
        $finalResult += $intConvert - 96
    }
    else {
        $finalResult += $intConvert - 38
    }
}

Write-Host "Final Result: $finalResult" -ForegroundColor Green