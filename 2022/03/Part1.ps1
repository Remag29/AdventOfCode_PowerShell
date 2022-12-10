$pathFile = ".\2022\03\input.txt"
$lines = Get-Content $pathFile

$resultList = @()

$lines | ForEach-Object {
    $firtPoche = $_.Substring(0, $_.Length / 2)
    $secondPoche = $_.Substring($_.Length / 2, $_.Length / 2)

    for ($indexSecondPoche = 0; $indexSecondPoche -lt $secondPoche.Length; $indexSecondPoche++) {
        if ($firtPoche -cmatch $secondPoche[$indexSecondPoche]) {
            Write-Host "Match found" -ForegroundColor DarkYellow
            Write-Host "$firtPoche" -ForegroundColor Green
            Write-Host "$secondPoche" -ForegroundColor Red
            Write-Host "$($secondPoche[$indexSecondPoche])" -ForegroundColor DarkGreen
            $resultList += $secondPoche[$indexSecondPoche]
            break
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
        Write-Host "$_ : $($intConvert - 96)" -foregroundColor Magenta
    }
    else {
        $finalResult += $intConvert - 38

        Write-Host "$_ : $($intConvert - 38)" -foregroundColor DarkMagenta
    }
}

Write-Host "Final Result: $finalResult" -ForegroundColor Green