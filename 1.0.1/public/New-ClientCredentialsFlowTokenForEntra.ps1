function New-ClientCredentialsFlowTokenForEntra {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter(Mandatory)]
        [string]
        $ClientSecret,

        [Parameter(Mandatory)]
        [string]
        $Audience,

        [Parameter(Mandatory)]
        [System.Guid]
        $EntraTenantId,

        [Parameter()]
        [switch]
        $ForceNew = $false
    )

    if (!$ForceNew) {
        $cachedToken = Get-AuthToken -ClientId $ClientId
        if ($cachedToken) {
            return $cachedToken
        }
    }

    # if ($PSCmdlet.ParameterSetName -eq 'EndpointFromLookup') {
    #     $params = @{
    #         Method = 'Get'
    #         Uri    = 'https://login.microsoftonline.com/{0}/v2.0/.well-known/openid-configuration' -f $EntraTenantId
    #     }
    #     $response = Invoke-RestMethod @params
    #     $TokenEndpointUri = $response.token_endpoint
    # }
    $tokenEndpointUri = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $EntraTenantId

    $params = @{
        Method  = 'Post'
        Uri     = $tokenEndpointUri
        Headers = @{
            'content-type' = 'application/x-www-form-urlencoded'
        }
        Body    = @{
            'client_id'     = $ClientId
            'client_secret' = $ClientSecret
            'audience'      = $Audience
            'grant_type'    = "client_credentials"
        } | ConvertTo-QueryString
    }

    $response = Invoke-WebRequest @params
    $token = ConvertFrom-Json -InputObject $response.Content
    Register-AuthToken -Token $token

    return $token
}
