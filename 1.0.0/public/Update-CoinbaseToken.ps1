# Refreshes token (Coinbase)
function Update-CoinbaseToken {
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]
        $Token,

        [Parameter(Mandatory)]
        [PSCustomObject]
        $AppData
    )

    $uri = "https://api.coinbase.com/oauth/token"

    $headers = @{
        "content-type" = "application/x-www-form-urlencoded"
    }

    $body = @{
        "grant_type" = "refresh_token"
        "client_id" = $AppData.ClientId
        "client_secret" = $AppData.ClientSecret
        "refresh_token" = $Token.refresh_token
    }

    $params = @{
        Uri     = $uri
        Method  = "Post"
        Headers = $headers
        Body = $body
    }

    $result = Invoke-RestMethod @params
    return $result
}
