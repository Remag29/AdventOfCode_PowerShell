
$pathFile = ".\2022\02\Faight.txt"
$lines = Get-Content $pathFile

$regex = "([A-C]) ([X-Z])"
$myPoints = 0

# A = Rock = 1 pts
# B = Paper = 2 pts
# C = Scissors = 3 pts

# X = Rock = 1 pts
# Y = Paper = 2 pts
# Z = Scissors = 3 pts

foreach ( $line in $lines) {
    if ($line -match $regex) {
        Write-Host "Matched: $line" -ForegroundColor Cyan
        switch ($Matches[1]) {
            A { 
                if ($Matches[2] -eq "X") {
                    # Rock vs Rock
                    Write-Host "Tie" -ForegroundColor Yellow
                    $myPoints += 3
                    $myPoints += 1
                }
                elseif ($Matches[2] -eq "Y") {
                    # Rock vs Paper
                    Write-Host "Win" -ForegroundColor Green
                    $myPoints += 6
                    $myPoints += 2
                }
                else {
                    # Rock vs Scissors
                    Write-Host "Loose" -ForegroundColor Red
                    $myPoints += 0
                    $myPoints += 3
                }
            }
            B { 
                if ($Matches[2] -eq "X") {
                    # Paper vs Rock$
                    Write-Host "Loose" -ForegroundColor Red
                    $myPoints += 0
                    $myPoints += 1
                }
                elseif ($Matches[2] -eq "Y") {
                    # Paper vs Paper
                    Write-Host "Tie" -ForegroundColor Yellow
                    $myPoints += 3
                    $myPoints += 2
                }
                else {
                    # Paper vs Scissors
                    Write-Host "Win" -ForegroundColor Green
                    $myPoints += 6
                    $myPoints += 3
                }
            }
            C { 
                if ($Matches[2] -eq "X") {
                    # Scissors vs Rock$
                    Write-Host "Win" -ForegroundColor Green
                    $myPoints += 6
                    $myPoints += 1
                }
                elseif ($Matches[2] -eq "Y") {
                    # Scissors vs Paper
                    Write-Host "Loose" -ForegroundColor Red
                    $myPoints += 0
                    $myPoints += 2
                }
                else {
                    # Scissors vs Scissors
                    Write-Host "Tie" -ForegroundColor Yellow
                    $myPoints += 3
                    $myPoints += 3
                }
            }
            Default { Write-Host "Error" -ForegroundColor Red }
        }
    }
    Write-Host "My points: $myPoints" -ForegroundColor Blue
}

Write-host "My points : $myPoints" -ForegroundColor Cyan


