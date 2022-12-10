$pathFile = ".\2022\02\Faight.txt"
$lines = Get-Content $pathFile

$regex = "([A-C]) ([X-Z])"
$myPoints = 0

# A = Rock = 1 pts
# B = Paper = 2 pts
# C = Scissors = 3 pts

# X = Loose
# Y = Draw
# Z = Win

foreach ( $line in $lines) {
    if ($line -match $regex) {
        Write-Host "Matched: $line" -ForegroundColor Cyan
        switch ($Matches[1]) {
            A { 
                if ($Matches[2] -eq "Z") {
                    # Rock vs Paper
                    Write-Host "Win" -ForegroundColor Green
                    $myPoints += 6
                    $myPoints += 2
                }
                elseif ($Matches[2] -eq "Y") {
                    # Rock vs Rock
                    Write-Host "Tie" -ForegroundColor Yellow
                    $myPoints += 3
                    $myPoints += 1
                }
                else {
                    # Rock vs Scissors
                    Write-Host "Loose" -ForegroundColor Red
                    $myPoints += 0
                    $myPoints += 3
                }
            }
            B { 
                if ($Matches[2] -eq "Z") {
                    # Paper vs Scissors
                    Write-Host "Win" -ForegroundColor Green
                    $myPoints += 6
                    $myPoints += 3
                }
                elseif ($Matches[2] -eq "Y") {
                    # Paper vs Paper
                    Write-Host "Tie" -ForegroundColor Yellow
                    $myPoints += 3
                    $myPoints += 2
                }
                else {
                    # Paper vs Rock
                    Write-Host "Loose" -ForegroundColor Red
                    $myPoints += 0
                    $myPoints += 1
                }
            }
            C { 
                if ($Matches[2] -eq "Z") {
                    # Scissors vs Rock$
                    Write-Host "Win" -ForegroundColor Green
                    $myPoints += 6
                    $myPoints += 1
                }
                elseif ($Matches[2] -eq "Y") {
                    # Scissors vs Scissors
                    Write-Host "Tie" -ForegroundColor Yellow
                    $myPoints += 3
                    $myPoints += 3
                }
                else {
                    # Scissors vs Paper
                    Write-Host "Loose" -ForegroundColor Red
                    $myPoints += 0
                    $myPoints += 2
                }
            }
            Default { Write-Host "Error" -ForegroundColor Red }
        }
    }
    Write-Host "My points: $myPoints" -ForegroundColor Blue
}

Write-host "My points : $myPoints" -ForegroundColor Cyan
