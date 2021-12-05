using namespace System.Management.Automation
using namespace System.Collections.Specialized

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ConvertValuesInObjectToHashtable" {
    Context "異常ケース" {
        It "NULL" {
            { ConvertValuesInObjectToHashtable -InputObject $null } | Should -Throw
        }
        It "空配列" {
            $actual = ConvertValuesInObjectToHashtable -InputObject (@())
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.Count   | Should -BeExactly 0
        }
    }
    Context "正常ケース PSCustomObject" {
        It "Depth:1 Count:1" {
            $expect = [PSCustomObject]@{a = 1 }
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual         | Should -HaveCount 1
            $actual.a       | Should -BeExactly $expect.a
        }
        It "Depth:1 Count:2 Array" {
            $expect = [PSCustomObject]@{a = "1"; b = @(2, 3) }
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.count   | Should -BeExactly 2
            $actual.a       | Should -BeExactly $expect.a
            $actual.b       | Should -BeExactly $expect.b
        }
        It "Depth:2 Count:2 Hashtable" {
            $expect = [PSCustomObject]@{a = "1"; b = @{c = 2 } }
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.count   | Should -BeExactly 2
            $actual.a       | Should -BeExactly $expect.a
            $actual.b       | Should -BeExactly $expect.b
        }
    }
    Context "正常ケース Hashtable" {
        It "Depth:1 Count:1" {
            $expect = @{a = 1 }
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual         | Should -HaveCount 1
            $actual.a       | Should -BeExactly $expect.a
        }
        It "Depth:1 Count:2 Array" {
            $expect = @{a = "1"; b = @(2, 3) }
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.count   | Should -BeExactly 2
            $actual.a       | Should -BeExactly $expect.a
            $actual.b       | Should -BeExactly $expect.b
        }
        It "Depth:2 Count:2 Hashtable" {
            $expect = @{a = "1"; b = @{c = 2 } }
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.count   | Should -BeExactly 2
            $actual.a       | Should -BeExactly $expect.a
            $actual.b       | Should -BeExactly $expect.b
            $actual.b       | Should -BeOfType [Hashtable]
        }
    }
    Context "正常ケース Array" {
        It "Depth:1 Count:1" {
            $expect = @(1)
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual         | Should -HaveCount 1
            $actual.a       | Should -BeExactly $expect.a
        }
        It "Depth:1 Count:2 Array" {
            $expect = @(1, @(2))
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.count   | Should -BeExactly $expect.count
            $actual[0]      | Should -BeExactly $expect[0]
            $actual[1]      | Should -BeExactly $expect[1]
        }
        It "Depth:2 Count:2 Hashtable" {
            $expect = @(1, @{a = 2 })
            $actual = ConvertValuesInObjectToHashtable -InputObject $expect
            $actual         | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.count   | Should -BeExactly $expect.count
            $actual[0]      | Should -BeExactly $expect[0]
            $actual[1]      | Should -BeExactly $expect[1]
        }
    }
}

Describe "AddGetDepthMethod" {
    Context "異常ケース" {
        It "Null" {
            { AddGetDepthMethod -InputObject $null } | Should -Throw
        }
        It "ValueType" {
            { AddGetDepthMethod -InputObject 1 } | Should -Throw
            { AddGetDepthMethod -InputObject "1" } | Should -Throw
        }
    }
    Context "正常ケース" {
        It "Array" {
            $array = @()
            AddGetDepthMethod -InputObject $array
            $array.GetDepth | Should -Not -Be $null
        }
        It "Hashtable" {
            $array = @{}
            AddGetDepthMethod -InputObject $array
            $array.GetDepth | Should -Not -Be $null
        }
    }
}

Describe "ConvertJsonObjectToEditableJson" {
    Context "異常ケース" {
        It "Null" {
            { ConvertJsonObjectToEditableJson -InputObject $null }  | Should -Throw
        }
        It "Not Hashtable or Array or PSCustomObject: ValueType" {
            { ConvertJsonObjectToEditableJson -InputObject 1 }      | Should -Throw
        }
        It "Not Hashtable or Array or PSCustomObject: string" {
            { ConvertJsonObjectToEditableJson -InputObject "2" }    | Should -Throw
        }
    }
}

Describe "CalcDepth" {
    Context "異常ケース" {
        It "Null" {
            { CalcDepth -InputObject $null } | Should -Throw
        }
    }
    Context "正常ケース Array" {
        It "Enpty array" {
            CalcDepth -InputObject @() | Should -Be 1
        }
        It "Nested array" {
            CalcDepth -InputObject @(1, @()) | Should -Be 2
        }
        It "Hashtable in array" {
            CalcDepth -InputObject @(1, [PSCustomObject]@{a = 2 }) | Should -Be 2
        }
        It "Depth (1,2,3)" {
            CalcDepth -InputObject @(1, @(2), @(@(3), 4)) | Should -Be 3
        }
        It "Depth (3,2,1)" {
            CalcDepth -InputObject @(@(@(1), 2), @(3), 4) | Should -Be 3
        }
    }
    Context "正常ケース Hashtable" {
        It "Enpty hashtable" {
            CalcDepth -InputObject @{} | Should -Be 1
        }
        It "Nested hashtable" {
            CalcDepth -InputObject @{a = 1; b = @{c = 3 } } | Should -Be 2
        }
        It "Array in hashtable" {
            CalcDepth -InputObject @{a = 1; b = @(2, 3) } | Should -Be 2
        }
    }
    Context "正常ケース PSCustomObject" {
        It "Enpty hashtable" {
            CalcDepth -InputObject ([PSCustomObject]@{}) | Should -Be 1
        }
        It "Nested hashtable" {
            CalcDepth -InputObject ([PSCustomObject]@{a = 1; b = [PSCustomObject]@{c = 3 } }) | Should -Be 2
        }
        It "Array in hashtable" {
            CalcDepth -InputObject ([PSCustomObject]@{a = 1; b = @(2, 3) }) | Should -Be 2
        }
        It "Depth (1,2,3)" {
            CalcDepth -InputObject ([PSCustomObject]@{
                    a = 1;
                    b = [PSCustomObject]@{};
                    c = [PSCustomObject]@{
                        cc = [PSCustomObject]@{ccc = 3 }
                    }
                }) | Should -Be 3
        }
        It "Depth (3,2,1)" {
            CalcDepth -InputObject ([PSCustomObject]@{
                    a = [PSCustomObject]@{
                        aa = [PSCustomObject]@{}
                    };
                    b = [PSCustomObject]@{};
                    c = 3
                }) | Should -Be 3
        }
    }
}
Describe "ConvertFrom-JsonEditable" {
    Context "異常ケース" {
        It "Null" {
            { ConvertFrom-JsonEditable -Value $null } | Should -Throw
        }
        It "JSON形式でない文字列" {
            $value = '{"value":{}'
            { ConvertFrom-JsonEditable -Value $value } | Should -Throw
        }
    }
    Context "正常ケース Objectはじまり" {
        It "Without Array and Object" {
            $value = @"
{
    "a":1,
    "b":"2",
    "c":true,
    "d":null
}
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual.a | Should -BeExactly 1
            $actual.b | Should -BeExactly "2"
            $actual.c | Should -BeExactly $true
            $actual.d | Should -BeExactly $null
            $actual.GetDepth() | Should -BeExactly 1
        }
        It "With Array" {
            $value = @"
{
    "a":1,
    "b":"2",
    "c":true,
    "d":[
        4,5,6
    ]
}
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual.a               | Should -BeExactly 1
            $actual.b               | Should -BeExactly "2"
            $actual.c               | Should -BeExactly $true
            $actual.d               | Should -BeExactly @(4, 5, 6)
            $actual.GetDepth()      | Should -BeExactly 2
            $actual.d.GetDepth()    | Should -BeExactly 1
        }
        It "With Object" {
            $value = @"
{
    "a":1,
    "b":"2",
    "c":false,
    "d":{
        "da":3,
        "db":"4",
        "dc":"true"
    }
}
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual.a           | Should -BeExactly 1
            $actual.b           | Should -BeExactly "2"
            $actual.c           | Should -BeExactly $false
            $actual.d           | Should -BeOfType [System.Collections.Specialized.OrderedDictionary] 
            $actual.d.da        | Should -BeExactly 3
            $actual.d.db        | Should -BeExactly "4"
            $actual.d.dc        | Should -BeExactly $true
            $actual.GetDepth()  | Should -BeExactly 2
            $actual.d.GetDepth() | Should -BeExactly 1
        }
        It "With Array and Object" {
            $value = @"
{
    "a":1,
    "b":"2",
    "c":false,
    "d":{
        "da":3,
        "db":"4",
        "dc":"true"
    },
    "e":[
        5,
        "6",
        true,
        {"f":7}
    ]
}
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual.a               | Should -BeExactly 1
            $actual.b               | Should -BeExactly "2"
            $actual.c               | Should -BeExactly $false
            $actual.d               | Should -BeOfType [System.Collections.Specialized.OrderedDictionary] 
            $actual.d.da            | Should -BeExactly 3
            $actual.d.db            | Should -BeExactly "4"
            $actual.d.dc            | Should -BeExactly $true
            $actual.d.GetDepth()    | Should -BeExactly 1
            $actual.e[0]            | Should -BeExactly 5
            $actual.e[1]            | Should -BeExactly "6"
            $actual.e[2]            | Should -BeExactly $true
            $actual.e[3]            | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            $actual.e[3].f          | Should -BeExactly 7
            $actual.e[3].GetDepth() | Should -BeExactly 1
            $actual.e.GetDepth()    | Should -BeExactly 2
            $actual.GetDepth()      | Should -BeExactly 3
        }
    }

    Context "正常ケース Arrayはじまり" {
        It "Arrayのみ" {
            $value = @"
[
    1,
    "2",
    true,
    null
]
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual | Should -BeExactly @(1, "2", $true, $null)
            $actual.GetDepth() | Should -BeExactly 1
            
        }
        It "Array + Array" {
            $value = @"
[
    1,
    "2",
    true,
    null,
    [3]
]
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual | Should -BeExactly @(1, "2", $true, $null, @(3))
            $actual.GetDepth() | Should -BeExactly 2
            $actual[4].GetDepth() | Should -BeExactly 1
            
        }
    }

    Context "シナリオテスト" {
        It "JSON変換 → 編集 → JSON化 Objectはじまり" {
            $value = @"
{
    "a":1
}
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual.Add("b", @{"c" = 2; "d" = @(3, 4) })
            # 結果を標準のJSONオブジェクトに変換
            $actualStdJson = $actual | ConvertTo-Json -Depth $actual.GetDepth() -Compress | ConvertFrom-Json
            $expectStdJson = '{"a":1,"b":{"c":2,"d":[3,4]}}' | ConvertFrom-Json
            $actualStdJson.a        | Should -Be $expectStdJson.a
            $actualStdJson.b.c      | Should -Be $expectStdJson.b.c
            $actualStdJson.b.d      | Should -Be $expectStdJson.b.d
            # 結果を本スクリプトのハッシュテーブルに変換
            $actualMyJson = $actual | ConvertTo-Json -Depth $actual.GetDepth() -Compress | ConvertFrom-JsonEditable
            $expectMyJson = '{"a":1,"b":{"c":2,"d":[3,4]}}' | ConvertFrom-JsonEditable
            $actualMyJson.a         | Should -Be $expectMyJson.a
            $actualMyJson.b.c       | Should -Be $expectMyJson.b.c
            $actualMyJson.b.d       | Should -Be $expectMyJson.b.d
        }
        It "JSON変換 → 編集 → JSON化 Arrayはじまり" {
            $value = @"
[{
    "a":1
}]
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual[0].Add("b", @{"c" = 2; "d" = @(3, 4) })
            $actual.Add(@{"e"="f"})
            # 結果を標準のJSONオブジェクトに変換
            $actualStdJson = $actual | ConvertTo-Json -Depth $actual.GetDepth() -Compress | ConvertFrom-Json
            $expectStdJson = '[{"a":1,"b":{"c":2,"d":[3,4]}},{"e":"f"}]' | ConvertFrom-Json
            $actualStdJson[0].a         | Should -BeExactly $expectStdJson[0].a
            $actualStdJson[0].b.c       | Should -BeExactly $expectStdJson[0].b.c
            $actualStdJson[0].b.d       | Should -BeExactly $expectStdJson[0].b.d
            $actualStdJson[1].e         | Should -BeExactly $expectStdJson[1].e
            # 結果を本スクリプトのハッシュテーブ-BeExactly変換
            $actualMyJson = $actual | ConvertTo-Json -Depth $actual.GetDepth() -Compress | ConvertFrom-JsonEditable
            $expectMyJson = '[{"a":1,"b":{"c":2,"d":[3,4]}},{"e":"f"}]' | ConvertFrom-JsonEditable
            $actualMyJson[0].a          | Should -BeExactly $expectMyJson[0].a
            $actualMyJson[0].b.c        | Should -BeExactly $expectMyJson[0].b.c
            $actualMyJson[0].b.d        | Should -BeExactly $expectMyJson[0].b.d
            $actualMyJson[1].e          | Should -BeExactly $expectMyJson[1].e
            $actualMyJson.GetDepth()    | Should -BeExactly 4
        }
    }
    Context "Unboxing/Unpacking検証" {
        It "要素1のオブジェクト" {
            
            $value = @"
{
    "a":1
}
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual.a           | Should -BeExactly 1
            $actual.GetDepth()  | Should -BeExactly 1
        }
        It "要素1のオブジェクト" {
            
            $value = @"
[
    [
        1
    ]
]
"@
            $actual = ConvertFrom-JsonEditable -Value $value
            $actual[0][0]       | Should -BeExactly 1
            $actual.GetDepth()  | Should -BeExactly 2
        }
    }
}