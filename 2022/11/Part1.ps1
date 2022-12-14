# Part 1

function New-Monkey {
    param (
        [Parameter(Mandatory = $true)] [psobject] $MonkeyParam
    )
    
    $Monkey = New-Object PSObject 

    $Monkey | Add-Member -MemberType NoteProperty -Name "ID" -Value $MonkeyParam.ID
    $Monkey | Add-Member -MemberType NoteProperty -Name "Item" -Value $MonkeyParam.ItemsList
    $Monkey | Add-Member -MemberType NoteProperty -Name "DropTest" -Value $MonkeyParam.DropTest
    $Monkey | Add-Member -MemberType NoteProperty -Name "TrueMonkeyId" -Value $MonkeyParam.TrueMonkeyId
    $Monkey | Add-Member -MemberType NoteProperty -Name "FalseMonkeyId" -Value $MonkeyParam.FalseMonkeyId
    $Monkey | Add-Member -MemberType NoteProperty -Name "Operation" -Value $MonkeyParam.Operation
    $Monkey | Add-Member -MemberType NoteProperty -Name "ItemInspected" -Value 0

    return $Monkey
}

function Get-MonkeyParamFromInput {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)] [array] $Lines
    )
    $id = $null
    $itemsList = $null
    $dropTest = $null
    $trueMonkeyId = $null
    $falseMonkeyId = $null
    $operation = $null
    $returnList = @()

    $itemIndex = 0
    
    $Lines | ForEach-Object {
        switch -regex ($_) {
            "^Monkey ([0-9]+):" {
                if ($null -ne $id) {
                    # Save the previous monkey
                    $singleOperation = @{
                        "ID"            = $id
                        "ItemsList"     = $itemsList
                        "DropTest"      = $dropTest
                        "TrueMonkeyId"  = $trueMonkeyId
                        "FalseMonkeyId" = $falseMonkeyId
                        "Operation"     = $operation
                    }
                    $returnList += $singleOperation
                    Write-Verbose "Monkey saved: $id"
                }
                # Start a new monkey
                $id = $Matches[1]
                $itemsList = $null
                $dropTest = $null
                $trueMonkeyId = $null
                $falseMonkeyId = $null
                $operation = $null
            }
            "Starting items: (.+)" {
                # Save the items list
                $itemsListPreview = $Matches[1].Replace(" ", "").Split(",")
                $itemsList = New-Object System.Collections.ArrayList
                foreach ($item in $itemsListPreview) {
                    $itemsObject = @{
                        "ID"         = $itemIndex
                        "WorryLevel" = [int32]$item
                    }
                    $itemsList.Add($itemsObject) | Out-Null
                    $itemIndex++
                }
            }
            "Operation: new = (.+)" {
                # Save the operation
                $operationList = $Matches[1].Split(" ")
                $operation = New-Object PSObject
                $operation | Add-Member -MemberType NoteProperty -Name "Operation" -Value $operationList[1]
                $operation | Add-Member -MemberType NoteProperty -Name "Param1" -Value $operationList[0]
                $operation | Add-Member -MemberType NoteProperty -Name "Param2" -Value $operationList[2]
            }
            "Test: divisible by ([0-9]+)" {
                # Save the drop test
                $dropTest = $Matches[1]
            }
            "If true: throw to monkey ([0-9]+)" {
                # Save the true monkey id
                $trueMonkeyId = $Matches[1]
            }
            "If false: throw to monkey ([0-9]+)" {
                # Save the false monkey id
                $falseMonkeyId = $Matches[1]
            }
            Default {
                Write-Verbose "Line does not match regex: $_"
            }
        }
    }

    # Save the last monkey
    $singleOperation = @{
        "ID"            = $id
        "ItemsList"     = $itemsList
        "DropTest"      = $dropTest
        "TrueMonkeyId"  = $trueMonkeyId
        "FalseMonkeyId" = $falseMonkeyId
        "Operation"     = $operation
    }
    $returnList += $singleOperation
    Write-Verbose "Monkey saved: $id"

    return $returnList
}

function Invoke-InitialiseMonkey {
    param (
        [Parameter(Mandatory = $true)] [array] $Lines
    )

    $monkeysParamList = $null
    $monkeysParamList = Get-MonkeyParamFromInput -Lines $Lines

    $monkeysList = @()
    $monkeysParamList | ForEach-Object {
        $monkeysList += New-Monkey -MonkeyParam $_
    }

    return $monkeysList
}

function Update-WorryLevel {
    param (
        [Parameter(Mandatory = $true)] [psobject] $Item,
        [Parameter(Mandatory = $true)] [psobject] $Operation
    )
    $param1 = 0
    $param2 = 0

    # Convert old to the item value
    # Param1
    if ($Operation.Param1 -match "old") {
        $param1 = $Item.WorryLevel
    }
    else {
        $param1 = [int]$Operation.Param1
    }
    # Param2
    if ($Operation.Param2 -match "old") {
        $param2 = $Item.WorryLevel
    }
    else {
        $param2 = [int]$Operation.Param2
    }

    # Calculate the new value
    switch ($Operation.Operation) {
        "+" {
            $Item.WorryLevel = $param1 + $param2
        }
        "-" {
            $Item.WorryLevel = $param1 - $param2
        }
        "*" {
            $Item.WorryLevel = $param1 * $param2
        }
        "/" {
            $Item.WorryLevel = $param1 / $param2
        }
        Default {
            Write-Error "Operation not found: $($Operation.Operation)"
        }
    }
}

function Invoke-DropTest {
    param (
        [Parameter(Mandatory = $true)] [psobject] $Item,
        [Parameter(Mandatory = $true)] [int32] $DropTest
    )
    
    if ($Item.WorryLevel % $DropTest -eq 0) {
        return $true
    }
    else {
        return $false
    }
}

function Show-MonkeyItemsWorryLvl {
    param (
        [Parameter(Mandatory = $true)] [psobject] $Monkey
    )
    Write-Host "Monkey $($Monkey.ID):" -NoNewline
    $Monkey.Item | ForEach-Object {
        Write-Host "$($_.WorryLevel), " -NoNewline
    }
    Write-Host
}

function Invoke-StartRounds {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [array] $MonkeysList,
        [Parameter(Mandatory = $true)] [int32] $TotalRound,
        [Parameter(Mandatory = $false)] [switch] $DisplayRounds
    )
    
    for ($round = 1; $round -le $TotalRound; $round++) {
        if ($DisplayRounds) {
            Write-Host "Round $round"
        }
        foreach ($monkey in $MonkeysList) {
            if ($DisplayRounds) {
                Show-MonkeyItemsWorryLvl -Monkey $monkey
            }
            
            
            foreach ($item in $monkey.Item) {
                # Update worry level
                Update-WorryLevel -Item $item -Operation $monkey.Operation
                
                # Divide by 3 (see the problem statement)
                $item.WorryLevel = [System.Math]::Floor($item.WorryLevel / 3)
                
                # Test Drop condition
                if (Invoke-DropTest -Item $item -DropTest $monkey.DropTest) {
                    # Use True Drop
                    $trueMonkey = $MonkeysList | Where-Object { $_.ID -eq $monkey.TrueMonkeyId }
                    $trueMonkey.Item.Add($item) | Out-Null
                }
                else {
                    # Use False Drop
                    $falseMonkey = $MonkeysList | Where-Object { $_.ID -eq $monkey.FalseMonkeyId }
                    $falseMonkey.Item.Add($item) | Out-Null
                }

                $monkey.ItemInspected++
            }

            # Clear monkey items list because all item were given
            $monkey.Item.Clear()
        }

        if ($DisplayRounds) {
            Write-Host
        }
    }
}


############################################################################################################
$filePath = ".\2022\11\input.txt"
# $filePath = ".\2022\11\SmallTest.txt"
$lines = Get-Content $filePath

$monkeyList = Invoke-InitialiseMonkey -Lines $lines
Invoke-StartRounds -MonkeysList $monkeyList -TotalRound 20 -DisplayRounds

$orderedMonkey = $monkeyList | Sort-Object -Descending -Property ItemInspected
$orderedMonkey  | Format-Table -Property ID, ItemInspected
$result = $orderedMonkey[0].ItemInspected * $orderedMonkey[1].ItemInspected
Write-Host "Result : $result" -ForegroundColor Green

# 70731 To low