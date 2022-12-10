$filePath = "C:\Users\asus\Documents\Projet\AdventOfCod2022\2021\01\input.txt"
$lines = Get-Content -Path $filePath

$previous = 0
$groupsThree = @(0, 0, 0)
$sum = 0


foreach ($line in $lines) {
    
    # Update the groups
    $actual = [int32]$line

    $groupsThree[0] = $groupsThree[1]
    $groupsThree[1] = $groupsThree[2]
    $groupsThree[2] = $actual

    $sumGroups = $groupsThree[0] + $groupsThree[1] + $groupsThree[2]
    Write-Host "Groups : $($groupsThree[0]), $($groupsThree[1]), $($groupsThree[2]),  SUM : $sumGroups" -ForegroundColor Yellow

    # Calc change
    if (($sumGroups -gt $previous) -and ($groupsThree[0] -ne 0) -and ($groupsThree[1] -ne 0) -and ($groupsThree[2] -ne 0)) {
        $sum++
        Write-Host "BETTER" -ForegroundColor Green
    }
    $previous = $sumGroups
}

Write-Host "Sum : $($sum)" -ForegroundColor Cyan