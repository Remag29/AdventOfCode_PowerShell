$filePath = "C:\Users\asus\Documents\Projet\AdventOfCod2022\2022\02\input.txt"
$lines = Get-Content -Path $filePath

$regex = "^([a-z]+) ([0-9])$"
$horizontale = 0
$depth = 0
$objectif = 0

$lines | ForEach-Object {
    if ($_ -match $regex) {
        Write-Host "Matches: $($matches[1]) $($matches[2])"
        switch ($x = $matches[1]) {
            forward { 
                $horizontale += $matches[2]
                $depth += $objectif*$matches[2]
                Write-Host "forward" -ForegroundColor Yellow
            }
            up { 
                $objectif -= $matches[2]
                Write-Host "up" -ForegroundColor Yellow
            }
            down { 
                $objectif += $matches[2]
                Write-Host "down" -ForegroundColor Yellow
            }
            Default {
                Write-Host "Unknown command: $x" -ForegroundColor Red
            }
        }
    
    }
}

Write-Host "Horizontale: $horizontale" -ForegroundColor Cyan
Write-Host "depth: $depth" -ForegroundColor Cyan
Write-Host "Objectif: $objectif" -ForegroundColor Cyan
Write-Host "Solution : $($horizontale * $depth)" -ForegroundColor Green