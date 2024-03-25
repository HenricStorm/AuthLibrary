function Get-EntraOauth2Endpoints {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $TenantId,

        [Parameter()]
        [ValidateSet('v1', 'v2')]
        [string]
        $Version = 'v2'
    )

    switch ($Version) {
        'v1' {
            $endpoints = [PSCustomObject]@{
                AuthorizationEndpoint = 'https://login.microsoftonline.com/{0}/oauth2/authorize' -f $TenantId
                TokenEndpoint = 'https://login.microsoftonline.com/{0}/oauth2/token' -f $TenantId
            }
        }
        'v2' {
            $endpoints = [PSCustomObject]@{
                AuthorizationEndpoint = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/authorize' -f $TenantId
                TokenEndpoint = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $TenantId
            }
        }
    }

    $metadata = 'https://login.microsoftonline.com/{0}/.well-known/openid-configuration' -f $TenantId
    $endpoints.Add('Metadata', $metadata)

    return $endpoints
}
