$filePath = "C:\Users\asus\Documents\Projet\AdventOfCod2022\2021\01\input.txt"
$lines = Get-Content -Path $filePath

$previous = 0
$sum = 0


foreach ($line in $lines) {
    
    $actual = [int32]$line

    if ($actual -gt $previous) {
        $sum++
    }
    $previous = $actual
}

Write-Host "Sum : $($sum-1)" -ForegroundColor Cyan