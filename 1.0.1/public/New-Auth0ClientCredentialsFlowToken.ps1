function New-Auth0ClientCredentialsFlowToken {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter(Mandatory)]
        [string]
        $ClientSecret,

        [Parameter(Mandatory)]
        [string]
        $Audience,

        #[Parameter(Mandatory)]
        #[ValidatePattern('http://*', 'https://*')]
        #[uri]
        #$TokenEndpointUri,

        [Parameter(Mandatory)]
        [string]
        $Domain,

        [Parameter()]
        [switch]
        $ForceNew = $false
    )

    if (!$ForceNew) {
        $cachedToken = Get-TokenGlobal -ClientId $ClientId
        if ($cachedToken) {
            return $cachedToken
        }
    }

    $params = @{
        Method  = 'Post'
        Uri     = 'https://{0}/oauth/token' -f $Domain
        Headers = @{
            'content-type' = 'application/json; charset=UTF-8'
        }
        Body    = @{
            'client_id'     = $ClientId
            'client_secret' = $ClientSecret
            'audience'      = $Audience
            'grant_type'    = "client_credentials"
        } | ConvertTo-Json
    }
    #curl.exe --request POST --url "https://cooriddev.eu.auth0.com/oauth/token" --header ($headers | ConvertTo-Json) --data $body

    $response = Invoke-RestMethod @params
    Register-TokenGlobal -Token $response

    return $token
}
