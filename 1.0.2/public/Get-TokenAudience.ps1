function Get-TokenAudience {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Token')]
        [object]
        $Token,

        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [string]
        $AccessToken
    )

    if ($PSCmdlet.ParameterSetName -eq 'Token') {
        $AccessToken = $Token.access_token
    }

    $expandedToken = Expand-JWTtoken -AccessToken $AccessToken
    return $expandedToken.aud
}
