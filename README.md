# PSConvertFromJsonEditable(日本語)
標準のConvertFrom-Jsonコマンドと異なり、編集可能なJSONオブジェクトを返却する関数です。

# デモ

ConvertFrom-Jsonと同じように呼び出してください。


```powershell
$users = Get-Content -Path "users.json" | ConvertFrom-JsonEditable
$user = $users | Where-Object { $_.id -eq "00001" }
$user.otherInfo.height = 168

$users | ConvertTo-Json -Depth $users.GetDepth() | Set-Content "users.json"

Get-Content -Path "users.json"
```

デモスクリプト → [Demo/demo.ps1](Demo/demo.ps1)


# PSConvertFromJsonEditable(En)
Function which loads json and returns editable object, not like 'ConvertFrom-Json' command. 

# Demo

Call function the same way as 'ConvertFrom-Json'.

```powershell
$users = Get-Content -Path "users.json" | ConvertFrom-JsonEditable
$user = $users | Where-Object { $_.id -eq "00001" }
$user.otherInfo.height = 168

$users | ConvertTo-Json -Depth $users.GetDepth() | Set-Content "users.json"

Get-Content -Path "users.json"
```

This is Demo -> [Demo/demo.ps1](Demo/demo.ps1).
