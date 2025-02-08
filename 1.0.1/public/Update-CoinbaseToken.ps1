# Refreshes token (Coinbase)
function Update-CoinbaseToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]
        $Token,

        [Parameter(Mandatory)]
        [PSCustomObject]
        $AppData
    )

    $params = @{
        Headers = @{
            'content-type' = 'application/x-www-form-urlencoded'
        }
        Method  = 'Post'
        Uri     = 'https://api.coinbase.com/oauth/token'
        Body    = @{
            'grant_type'    = 'refresh_token'
            'client_id'     = $AppData.ClientId
            'client_secret' = $AppData.ClientSecret
            'refresh_token' = $Token.refresh_token
        }
    }

    $result = Invoke-RestMethod @params
    return $result
}
