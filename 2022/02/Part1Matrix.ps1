
$pathFile = ".\2022\02\Faight.txt"
$lines = Get-Content $pathFile

$regex = "([A-C]) ([X-Z])"
$myPoints = 0

$score = @(
    @(4, 8, 3 ),
    @(1, 5, 9 ),
    @(7, 2, 6 )
)

#     X  Y  Z
# A   4  8  3
# B   2  5  9
# C   7  2  6

# A = Rock = 1 pts
# B = Paper = 2 pts
# C = Scissors = 3 pts

# X = Rock = 1 pts
# Y = Paper = 2 pts
# Z = Scissors = 3 pts

foreach ( $line in $lines) {
    if ($line -match $regex) {
        
        $myPoints += $score[[byte][char]$Matches[1] - 65][[byte][char]$Matches[2] - 88]
    }
    Write-Host "My points: $myPoints" -ForegroundColor Blue
}

Write-host "My points : $myPoints" -ForegroundColor Cyan