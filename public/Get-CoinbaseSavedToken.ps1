function Get-CoinbaseSavedToken
{
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Coinbase","CoinbasePro")]
        [string]$Application
    )

    $secretsFile = "$($Env:AppData)\Coinbase-Secrets\$($Application)Token.json"

    if (Test-Path -Path $secretsFile)
    {
        $token = Get-Content -Encoding utf8 -Path $secretsFile | ConvertFrom-Json
        return $token
    }

    Write-Warning "No token file found ($($Application)Token.json)"
    return $false
}
