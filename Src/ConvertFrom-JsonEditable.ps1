using namespace System.Management.Automation
using namespace System.Collections
using namespace System.Collections.Generic


function ConvertValuesInObjectToHashtable {
    <#
    .SYNOPSIS
        �I�u�W�F�N�g�̗v�f�������̓v���p�e�B�̒l���n�b�V���e�[�u���ɕϊ�����B
    .DESCRIPTION
        �����̌^�ɂ���ē����ς���B
        - PSCustomObject�^�̃I�u�W�F�N�g
            - �e�v���p�e�B����Key�A�l��Value�Ƃ��ăn�b�V���e�[�u���ɂ���B
        - Array�^�̃I�u�W�F�N�g
            - �e�v�f�̃C���f�b�N�X��Key�A�l��Value�Ƃ��ăn�b�V���e�[�u���ɂ���B
        - ����ȊO�͋�n�b�V���e�[�u���Ƃ���B
    .PARAMETER InputObject
        Object�^�̃I�u�W�F�N�g
    .OUTPUTS
        Hashtable.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $InputObject
    )
    $hash = [ordered]@{}
    if ($InputObject -is [IDictionary] ) {
        $InputObject.Keys | ForEach-Object { $hash.Add($_,$InputObject[$_])}
    }elseif ($InputObject -is [IEnumerable] -and $InputObject -isnot [string]) {
        for ($i = 0; $i -lt $InputObject.Count; $i++) {
            $hash.Add($i, $InputObject[$i])
        }
    }
    elseif ($InputObject -is [PSCustomObject]) {
        $InputObject.PSObject.Properties | ForEach-Object { $hash.Add($_.Name, $_.Value) }
    }
    
    return $hash
}

function AddGetDepthMethod {
    param (
        [Parameter(Mandatory)]
        [object]
        $InputObject
    )
    if ($InputObject -is [ValueType] -or $InputObject -is [string]) {
        throw "�ΏۊO�̃I�u�W�F�N�g�ł��B"
    }

    # �I�u�W�F�N�g�ɐ[���擾�̃I�u�W�F�N�g��ǉ�����B
    Add-Member -InputObject $InputObject -MemberType ScriptMethod -Name GetDepth -Value {
        param()
        CalcDepth -InputObject $this
    }
}

function ConvertJsonObjectToEditableJson {
    <#
    .SYNOPSIS
        �I�u�W�F�N�g���n�b�V���e�[�u���������͔z��ɕϊ�����B
    .DESCRIPTION

    .PARAMETER InputObject
        Object�^�̃I�u�W�F�N�g
    .OUTPUTS
        object[].
    #>
    param (
        [parameter(Mandatory)]
        [Object]$InputObject
    )

    if ($InputObject -is [ValueType] -or $InputObject -is [string]) {
        throw "�Ή����Ă��Ȃ������̌^�ł��B"
    }

    $dict = ConvertValuesInObjectToHashtable -InputObject $InputObject
    $table = [ordered]@{}
    foreach ($kvp in $dict.GetEnumerator()) {
        $addValue = $kvp.Value
        if ($kvp.Value -is [PSCustomObject] -or $kvp.Value -is [Array]) {
            $addValue = ConvertJsonObjectToEditableJson -InputObject $kvp.Value
        }
        $table.Add($kvp.Key, $addValue)
    }
    # ���͂��z��̏ꍇ�A�n�b�V���e�[�u����z��ɕύX����B
    if ($InputObject -is [Array]) {
        $table = [List[Object]]@( $table.Keys | Sort-Object | ForEach-Object { ,$table[$_] })
    }

    AddGetDepthMethod -InputObject $table
    # �z��̏ꍇ���l�����A�A���{�N�V���O��h��
    return , $table
}

function CalcDepth {
    <#
    .SYNOPSIS
        ����q�̐[�����Z�o����B
    .DESCRIPTION
        �����̃I�u�W�F�N�g�����v�f�i�v���p�e�B�^�ȉ��̏��������q�Ɣ��f���A�ċA�I�ɖ{�֐������s����B
        - InputObject��PSCustomObject�^
        - InputObject��IDictionary�^
        - InputObject��������ȊO��IEnumerable�^

    .PARAMETER InputObject
        Object�^�̃I�u�W�F�N�g
    .OUTPUTS
        int�^�̓���q�̐[��.
    #>
    param (
        [Parameter(Mandatory)]
        [Object]
        $InputObject
    )
    if ($null -eq $InputObject) {
        throw "�������s���ł��B"
    }
    [int]$maxDepth = 0
    [int]$tempDepth = 0
    [Hashtable]$hashtable = ConvertValuesInObjectToHashtable -InputObject $InputObject
    foreach ($value in $hashtable.Values) {
        if ($value -is [PSCustomObject] -or 
            $Value -is [IDictionary] -or
            $Value -is [IEnumerable] -and $Value -isnot [string]) {
            $tempDepth = CalcDepth -InputObject $value
        }
        $maxDepth = [System.Math]::Max($maxDepth, $tempDepth)
    }
    return (1 + $maxDepth)
}

function ConvertFrom-JsonEditable {
    <#
    .SYNOPSIS
        JSON�����񂩂�ҏW�ł���JSON�^�I�u�W�F�N�g�𐶐�����B
    .DESCRIPTION
        ConvertFrom-Json�R�}���h���p���邽�߁A���ꂪ�G���[���N�������͓͂��l�ɃG���[�𔭐�������B
    .PARAMETER Value
        �������JSON
    .OUTPUTS
        [OrderedDictionary] | [Array]
    #>
    param (
        [Parameter(Mandatory, ValueFromPipeline = $true)]
        [Array]
        $Value
    )

    # �p�C�v���C���p
    Begin {
        $jsonText = ""
    }
    Process {
        $jsonText += $Value
    }
    End {
        if (-not $jsonText) {
            throw "JSON������null�������͋󕶎��ł��B"
        }
        try {
            $json = ConvertFrom-Json -InputObject $jsonText
            $object = ConvertJsonObjectToEditableJson -InputObject $json
            return ,$object
        }
        catch {
            if (-not $json) {
                Throw "ConvertFrom-Json�G���[�FJSON�̌`�����m�F���Ă��������B"
            }
            Throw $_
        }
    }
}
