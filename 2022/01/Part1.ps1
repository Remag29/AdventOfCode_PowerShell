
$pathFile = ".\2022\01\NumbersPart1.txt"

$lines = Get-Content $pathFile
$elfeCount = 0
$max = 0

foreach ( $line in $lines) {
    if ([String]::IsNullOrWhiteSpace($line)) {
        if ($elfeCount -gt $max) {
            Write-Host "New max: $elfeCount" -ForegroundColor Blue
            $max = $elfeCount
        }
        $elfeCount = 0
    }
    $elfeCount += [int32]$line

}

Write-Host "Max : $max" -ForegroundColor Green