function Save-CoinbaseToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]
        $Token,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Coinbase","CoinbasePro")]
        [string]
        $Application
    )

    $secretsDirectory = "$($Env:AppData)\Coinbase-Secrets"

    if (!(Test-Path -Path $secretsDirectory)) {
        New-Item -ItemType Directory -Path $secretsDirectory
    }

    $Token | ConvertTo-JSON | Out-File -FilePath "$($secretsDirectory)\$($Application)Token.json" -Encoding utf8 | Out-Null
}
