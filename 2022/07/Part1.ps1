$filePath = ".\2022\07\input.txt"
$lines = Get-Content $filePath

$commandReGex = "^\$ ([a-z][a-z]) *(.*$)"
$dirReGex = "^dir *(.*$)"
$fileReGex = "^([0-9]*) (.+$)"

function New-ClassificationObject {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $Type,
        [Parameter(Mandatory = $true, Position = 1)] [string] $Name,
        [Parameter(Mandatory = $false, Position = 2)] [psobject] $Parent = $null,
        [Parameter(Mandatory = $false, Position = 3)] [int32] $Size = 0

    )
    
    $classObject = New-Object -TypeName PSObject
    $classObject | Add-Member -MemberType NoteProperty -Name Type -Value $Type
    $classObject | Add-Member -MemberType NoteProperty -Name Name -Value $Name
    $classObject | Add-Member -MemberType NoteProperty -Name Size -Value $Size
    $classObject | Add-Member -MemberType NoteProperty -Name Children -Value @()
    $classObject | Add-Member -MemberType NoteProperty -Name Parent -Value $Parent

    return $classObject
}

function Get-TreeStructure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $Lines
    )
    $previousObject = $null
    $rootObject = New-ClassificationObject -Type "dir" -Name "root"
    $rootObject.Children += $(New-ClassificationObject -Type "dir" -Name "/" -Parent $rootObject)
    $actualObject = $rootObject

    foreach ($line in $lines) {
        switch -regex ($line) {
            $commandReGex {
                switch ($Matches[1]) {
                    cd {
                        if ($matches[2] -eq "..") {
                            # Go back to parent
                            $actualObject = $actualObject.Parent
                            $actualObject.Children | Where-Object { $_.Type -eq "dir" } | ForEach-Object { $_.Size += $actualObject.Size }
                        }
                        else {
                            # Go to child
                            $actualObject = $actualObject.Children | Where-Object { $_.Name -eq $matches[2] }
                        }
                    }
                    ls {
                        $actualObject.Children | ForEach-Object { 
                            if ($_.Type -eq "dir") {
                                Write-Host "$($_.Name) (dir)" -ForegroundColor DarkYellow
                            }
                            else {
                                Write-Host "$($_.Name) (file, size=$($_.Size))" -ForegroundColor Magenta
                            }
                        }
                    }
                    Default { Write-Host "Command not found" -ForegroundColor Red }
                }
            }
            $dirReGex {
                $actualObject.Children += $(New-ClassificationObject -Type "dir" -Name $matches[1] -Parent $actualObject)
            }
            $fileReGex {
                $actualObject.Children += $(New-ClassificationObject -Type "file" -Name $matches[2] -Parent $actualObject -Size $matches[1])
                # $actualObject.Size += $matches[1]
            }
            Default { Write-Host "ReGex not found" -ForegroundColor Red }
        }
    }

    return $rootObject
    
}

function Show-TreeStructure {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $RootObject,
        [Parameter(Mandatory = $false, Position = 1)] [int32] $Depth = 0
    )
    
    $rootObject.Children | ForEach-Object {
        $tab = "|    " * $Depth
        if ($_.Type -eq "dir") {
            $tab = Write-Host "$tab| $($_.Name) (dir, size=$($_.Size))" -ForegroundColor DarkYellow
            Show-TreeStructure -RootObject $_ -Depth ($Depth + 1)
        }
        else {
            Write-Host "$tab|-$($_.Name) (file, size=$($_.Size))" -ForegroundColor Magenta
        }
    }
}

function Update-TreeStructureSize {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $RootObject
    )
    $totalSize = 0
    $rootObject.Children | ForEach-Object {
        if ($_.Type -eq "dir") {
            $totalSize += Update-TreeStructureSize -RootObject $_
        }
        else {
            $totalSize += $_.Size
        }
    }
    $RootObject.Size = $totalSize
    return $totalSize
}

function Get-TinyFolder {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [psobject] $RootObject,
        [Parameter(Mandatory = $true, Position = 1)] [int32] $MaxSize
    )
    $returnList = @()
    $rootObject.Children | ForEach-Object {
        if ($_.Type -eq "dir") {
            if ( $_.Size -lt $MaxSize) {
                $returnList += $_
                $returnList += Get-TinyFolder -RootObject $_ -MaxSize $MaxSize
            }
            else {
                $returnList += Get-TinyFolder -RootObject $_ -MaxSize $MaxSize
            }
        }
    }
    return $returnList
}

$rootObject = Get-TreeStructure -Lines $lines
Update-TreeStructureSize -RootObject $rootObject
Show-TreeStructure -RootObject $rootObject

$folderList = Get-TinyFolder -RootObject $rootObject -MaxSize 100000
Write-Host "Sum of size of tiny folders : $($($folderList | Measure-Object -Property Size -Sum).Sum)"
