function Get-CoinbaseToken {
    param (
        [object]$AppData
    )

    $token = Get-CoinbaseSavedToken -Application Coinbase

    if (!$token) {
        $additionalParameters = @("account=all"; "state=SECURE_RANDOM")
        $params = @{
            ClientId             = $appData.Key
            ClientSecret         = $appData.Secret
            RedirectUri          = "https://localhost/callback"
            AuthorizeEndpointUri = "https://www.coinbase.com/oauth/authorize"
            TokenEndpointUri     = "https://api.coinbase.com/oauth/token"
            Scopes               = "wallet:accounts:read", "wallet:transactions:read"
            AdditionalParameters = $additionalParameters
            Verbose              = $true
        }
        $token = New-AuthorizationCodeFlowToken @params
        Save-CoinbaseToken -Token $token -Application Coinbase
    }
    elseif ((Get-Date -UFormat %s) -gt ($token.created_at + $token.expires_in)) {
        Write-Host "Token HAS expired. Renewing token!"
        $token = Update-CoinbaseToken -Token $token
        Save-CoinbaseToken -Token $token -Application Coinbase
    }

    #Write-Host "Token has NOT expired. Valid until $(Get-Date -UnixTimeSeconds ($token.created_at + $token.expires_in) -Format 'yyyy-MM-dd HH:mm:ss')"
    return $token
}
