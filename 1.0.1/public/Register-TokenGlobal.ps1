function Register-TokenGlobal {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $Token
    )

    if (-not $global:Auth0Tokens) {
        $global:Auth0Tokens = @()
    }

    $parsedToken = Expand-JWTtoken -AccessToken $Token.access_token
    $global:Auth0Tokens += [PSCustomObject]@{
        Token          = $Token
        Subject        = ($parsedToken.sub -split '@')[0]
        IssuedAt       = Get-Date -UnixTimeSeconds $parsedToken.iat
        ExpirationTime = Get-Date  -UnixTimeSeconds $parsedToken.exp
    }
    Write-Host "Saved token with Subject: $($parsedToken.sub)"
}
