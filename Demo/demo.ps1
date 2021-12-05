Push-Location $PSScriptRoot
. ..\Src\ConvertFrom-JsonEditable.ps1

Set-Content -Path "users.json" -Value @"
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

$users = Get-Content -Path "users.json" | ConvertFrom-JsonEditable

$user = $users | Where-Object { $_.name -eq "Baki Hanma" }
$user.otherInfo.height = 168

$users | ConvertTo-Json -Depth $users.GetDepth() | Set-Content "users.json"

Get-Content -Path "users.json"

Pop-Location