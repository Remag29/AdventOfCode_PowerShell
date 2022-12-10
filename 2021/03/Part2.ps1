$filePath = "C:\Users\asus\Documents\Projet\AdventOfCod2022\2021\03\input.txt"
$lines = Get-Content -Path $filePath
$filterString = "^"


for ($colonneIndex = 0; $colonneIndex -lt $lines[0].Length; $colonneIndex++) {
    $numberOf1 = 0
    $numberOf0 = 0

    # Stop if there is only one line that matches the filter string
    if ($($lines | Where-Object { $_ -match $filterString }).Length -eq 1) {
        Write-Host "STOP"
        write-host $($lines | Where-Object { $_ -match $filterString })
    }

    # For each line that matches the filter string, count the number of 1 and 0
    foreach ($ligne in $($lines | Where-Object { $_ -match $filterString })) {
        if ($ligne[$colonneIndex] -eq "1") {
            $numberOf1++
        }
        else {
            $numberOf0++
        }
    }
    Write-Host "Number of 1: $numberOf1, number of 0: $numberOf0"

    # Update the filter string
    if ($numberOf1 -lt $numberOf0) {
        $filterString += "0"
    }
    else {
        $filterString += "1"
    }
    
}