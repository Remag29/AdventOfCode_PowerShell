$filePath = ".\2022\06\input.txt"
$lines = Get-Content $filePath

$retrunList = @()

$lines | ForEach-Object {

    for ($charIndex = 0; $charIndex -lt $lines.Length - 4; $charIndex++) {
        
        $charList = $_.Substring($charIndex, 4)
        $a = $charList.ToCharArray()

        $b = $a | Select-Object -Unique

        if ($b.Count -eq 4) {
            $retrunList += $charIndex + 4
            break
        }
    }
}

Write-Host "Return list : $retrunList"
