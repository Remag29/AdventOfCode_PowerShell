$filePath = ".\2022\06\input.txt"
$lines = Get-Content $filePath

$retrunList = @()

$lines | ForEach-Object {

    for ($charIndex = 0; $charIndex -lt $lines.Length - 14; $charIndex++) {
        
        $charList = $_.Substring($charIndex, 14)
        $a = $charList.ToCharArray()

        $b = $a | Select-Object -Unique

        if ($b.Count -eq 14) {
            $retrunList += $charIndex + 14
            break
        }
    }
}

Write-Host "Return list : $retrunList"
