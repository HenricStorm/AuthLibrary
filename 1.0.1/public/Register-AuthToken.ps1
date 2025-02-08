function Register-AuthToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $Token
    )

    if (-not $Script:Auth0Tokens) {
        $Script:Auth0Tokens = @()
    }

    $parsedToken = Expand-JWTtoken -AccessToken $Token.access_token
    $clientId = ($parsedToken.sub -split '@')[0]
    #$Script:Auth0Tokens += [PSCustomObject]@{
    $Script:Auth0Tokens[$clientId] = [PSCustomObject]@{
        Token          = $Token
        #Subject        = $clientId
        IssuedAt       = Get-Date -UnixTimeSeconds $parsedToken.iat
        ExpirationTime = Get-Date  -UnixTimeSeconds $parsedToken.exp
    }

    Write-Host "Saved token with Subject: $($parsedToken.sub)"
}
