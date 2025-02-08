function New-AuthContext {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('ClientCredentials', 'AuthorizationCode', 'AuthorizationCodeWithPKCE', 'Implicit', 'RefreshToken')]
        [string]
        $FlowType,

        [Parameter(Mandatory)]
        [ValidateSet('Auth0', 'Entra')]
        [string]
        $TokenProvider,

        [Parameter()]
        [switch]
        $ForceNewToken = $false
    )

    $switchParameter = '{0}-{1}' -f $TokenProvider, $FlowType
    switch -Wildcard ($switchParameter) {
        'Auth0-ClientCredentials' {
            $token = New-ClientCredentialsFlowTokenForAuth0 -ClientId $ClientId -ClientSecret $ClientSecret -Audience $Audience -Domain $Domain -ForceNew:$ForceNewToken
        }
        'Entra-ClientCredentials' {
            $token = New-ClientCredentialsFlowTokenForEntra -ClientId $ClientId -ClientSecret $ClientSecret -Audience $Audience -Domain $Domain -ForceNew:$ForceNewToken
        }
        '*-AuthorizationCode' {
            $token = New-AuthorizationCodeFlowToken -ClientId $ClientId -ClientSecret $ClientSecret -Audience $Audience -Domain $Domain -ForceNew
        }
        '*-AuthorizationCodeWithPKCE' {
            $token = New-AuthorizationCodeWithPKCEFlowToken -ClientId $ClientId -ClientSecret $ClientSecret -Audience $Audience -Domain $Domain -ForceNew
        }
        '-*Implicit' {
            $token = New-ImplicitFlowToken -ClientId $ClientId -ClientSecret $ClientSecret -Audience $Audience -Domain $Domain -ForceNew
        }
        'RefreshToken' {
            $token = New-RefreshTokenFlowToken -ClientId $ClientId -ClientSecret $ClientSecret -Audience $Audience -Domain $Domain -ForceNew
        }
    }

    if (!$token) {
        Write-Error 'Something went wrong when getting token'
    }

    Register-AuthToken -Token $token
}
