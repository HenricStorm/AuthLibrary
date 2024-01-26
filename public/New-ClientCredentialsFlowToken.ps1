function New-ClientCredentialsFlowToken {
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
        $Domain,

        [Parameter(Mandatory)]
        [string]
        $Audience,

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

    $headers = @{
        'content-type' = 'application/json; charset=UTF-8'
    }

    $body = @{
        'client_id'     = $ClientId
        'client_secret' = $ClientSecret
        'audience'      = $Audience
        'grant_type'    = "client_credentials"
    } | ConvertTo-Json

    $params = @{
        Method  = 'Post'
        Uri     = 'https://{0}/oauth/token' -f $Domain
        Headers = $headers
        Body    = $body
    }
    #curl.exe --request POST --url "https://cooriddev.eu.auth0.com/oauth/token" --header ($headers | ConvertTo-Json) --data $body

    $response = Invoke-WebRequest @params
    $token = ConvertFrom-Json -InputObject $response.Content
    Register-TokenGlobal -Token $token

    return $token
}
