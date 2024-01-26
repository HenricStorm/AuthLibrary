function Get-TokenAudience
{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory)]
        [object]
        $Token
    )

    return (Expand-JWTtoken -AccessToken $Token.access_token).aud
}
