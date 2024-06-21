function New-EntraClientCredentialsFlowToken {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'EndpointFromLookup')]
        [string]
        $ClientId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'EndpointFromLookup')]
        [string]
        $ClientSecret,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'EndpointFromLookup')]
        [string]
        $Audience,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [ValidatePattern('http://*', 'https://*')]
        [uri]
        $TokenEndpointUri,

        [Parameter(Mandatory, ParameterSetName = 'EndpointFromLookup')]
        [guid]
        $EntraTenantId,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'EndpointFromLookup')]
        [switch]
        $ForceNew = $false
    )

    if (!$ForceNew) {
        $cachedToken = Get-TokenGlobal -ClientId $ClientId
        if ($cachedToken) {
            return $cachedToken
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'EndpointFromLookup') {
        $params = @{
            Method = 'Get'
            Uri    = 'https://login.microsoftonline.com/{0}/v2.0/.well-known/openid-configuration' -f $EntraTenantId
        }
        $response = Invoke-RestMethod @params
        $TokenEndpointUri = $response.token_endpoint
    }

    $params = @{
        Method  = 'Post'
        Uri     = $TokenEndpointUri
        Headers = @{
            'content-type' = 'application/x-www-form-urlencoded'
        }
        Body    = @{
            'client_id'     = $ClientId
            'client_secret' = $ClientSecret
            'audience'      = $Audience
            'grant_type'    = "client_credentials"
        } | Format-QueryString
    }

    $response = Invoke-WebRequest @params
    $token = ConvertFrom-Json -InputObject $response.Content
    Register-TokenGlobal -Token $token

    return $token
}
