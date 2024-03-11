#$Domain = "identity-dev.coor.com"
#$Audience = "https://acos01apms.azure-api.net"

function New-TokenFromRefreshToken
{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory)]
        [object]
        $Token,

        [Parameter(Mandatory)]
        [string]
        $RedirectUri,

        [Parameter()]
        [string]
        $Domain = 'cooriddev.eu.auth0.com'
    )

    if (!$Token.refresh_token)
    {
        Write-Warning 'Token contains no refresh_token'
        return
    }

    $headers = @{
        'content-type' = 'application/x-www-form-urlencoded; charset=UTF-8'
    }

    $tokenExpanded = Expand-JWTtoken -AccessToken $Token.id_token

    $body = @{
        'grant_type'    = 'refresh_token'
        'client_id'     = $tokenExpanded.aud
        'redirect_uri'  = $RedirectUri
        'refresh_token' = $Token.refresh_token
    }

    $params = @{
        Method  = 'Post'
        Uri     = 'https://{0}/oauth/token' -f $Domain
        Headers = $headers
        Body    = $body
    }
    #curl.exe --request POST --url "https://cooriddev.eu.auth0.com/oauth/token" --header ($headers | ConvertTo-Json) --data $body

    #$response = try { Invoke-WebRequest @params -ErrorVariable err } catch { Write-Host $_.Exception }
    $response = Invoke-WebRequest @params
    $response
    $token = ConvertFrom-Json -InputObject $response.Content
    #Register-TokenGlobal -Token $token

    return $token
}