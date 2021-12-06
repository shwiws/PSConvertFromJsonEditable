Push-Location $PSScriptRoot
. ..\Src\ConvertFrom-JsonEditable.ps1

$csvFile = "$PSScriptRoot\users.json"

Set-Content -Path $csvFile -Value @"
[
    {
        "id":"00001",
        "name":"Baki Hanma",
        "otherInfo":{
            "age":18
        }
    },
    {
        "id":"00002",
        "name":"Kaoru Hanayama",
        "otherInfo":{
            "age":19
        }
    }
]
"@

$users = Get-Content -Path $csvFile -Encoding UTF8 | ConvertFrom-JsonEditable

$user = $users | Where-Object { $_.name -eq "Baki Hanma" }
$user.otherInfo.height = 168

$json = $users | ConvertTo-Json -Depth $users.GetDepth()

[System.IO.File]::WriteAllText($csvFile,$json,[System.Text.UTF8Encoding]::new($false))

Get-Content -Path $csvFile -Encoding UTF8 | Write-Host 

Pop-Location