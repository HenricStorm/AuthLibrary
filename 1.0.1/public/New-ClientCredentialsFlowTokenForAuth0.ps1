function New-ClientCredentialsFlowTokenForAuth0 {
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
        [string]
        $Domain,

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

    $response = Invoke-RestMethod @params
    Register-AuthToken -Token $response

    return $response
}
