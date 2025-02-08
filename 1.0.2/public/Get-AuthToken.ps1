function Get-AuthToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ClientId
    )

    if (-not $Script:Auth0Tokens) {
        return $null
    }

    Write-Host ('Looking for token with Subject: {0}' -f $ClientId)
    #$token = $Script:Auth0Tokens.Where({ $_.Subject -eq $ClientId })
    $token = $Script:Auth0Tokens[$ClientId]

    if (!$token) {
        Write-Host 'Token not found in cache'
        return $null
    }

    $expandedToken = Expand-JWTtoken -AccessToken $token.Token.access_token
    if ($expandedToken.exp -lt [DateTimeOffset]::Now.ToUnixTimeSeconds()) {
        Write-Host 'Token is about to expire, getting a new one'
    }

    Write-Host 'Found token in cache'
    return $token.Token
}
