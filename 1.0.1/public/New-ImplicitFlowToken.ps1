#$Domain = "identity-dev.coor.com"
#$Audience = "https://acos01apms.azure-api.net"

function New-ImplicitFlowToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter(Mandatory)]
        [string[]]
        $Scopes,

        [Parameter()]
        [string]
        $Audience,

        [Parameter()]
        [string]
        $LoginHint,

        [Parameter(Mandatory)]
        [string]
        $RedirectUri,

        [Parameter(Mandatory)]
        [string]
        $Auth0Domain
    )

    throw "Not yet implemented!"

    $headers = @{
        'Content-Type'  = 'application/json; charset=utf-8'
    }

    $body = @{
        #"client_id"     = $ClientId
        #"client_secret" = $ClientSecret
        "audience"      = $Audience
        "scope"         = "serviceRequest"
        #"grant_type"    = "authorization_code"
        "grant_type"    = "implicit"
    } | ConvertTo-Json

    $params = @{
        Method  = "Post"
        Uri     = "https://$($Domain)/oauth/token"
        Headers = $headers
        Body    = $body
    }
    #curl.exe --request POST --url "https://cooriddev.eu.auth0.com/oauth/token" --header ($headers | ConvertTo-Json) --data $body

    #$response = try { Invoke-WebRequest @params -ErrorVariable err } catch { Write-Host $_.Exception }
    $response = Invoke-WebRequest @params
    $token = ConvertFrom-Json -InputObject $response.Content
    #Register-AuthToken -Token $token

    return $token
}
