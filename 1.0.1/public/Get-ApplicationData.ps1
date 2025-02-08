function Get-ApplicationData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'ByClientId')]
        [string]
        $ClientId,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ByClientId')]
        [string]
        $SecretsFilePath = "$($Env:userprofile)\OneDrive - TheStorms\Lösenord\APISecrets.txt"
    )

    #$csvFilePath = 'C:\Users\HenricStorm\OneDrive - Advania\Kunder\Coor\Auth0 Powershell\Storm-Auth0\ClientSecrets.csv'
    #$csvFilePath = Get-Content ('{0}\..\config.json' -f $PSScriptRoot) | ConvertFrom-Json | Select-Object -ExpandProperty SecretsFilePath
    #Write-Host ('PSScriptRoot: {0}' -f $PSScriptRoot)
    $clientData = Import-Csv -Path $SecretsFilePath -Delimiter ';' -Encoding utf8
    $myClientData = $clientData.Where({ ($_.ClientId -and $_.ClientId -eq $ClientId) -or ($_.Name -and $_.Name -eq $Name) })
    if (-not $myClientData) {
        throw 'Name or Client ID not found in secrets file'
    }

    return $myClientData
}
