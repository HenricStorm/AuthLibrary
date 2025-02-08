Import-Module -Name 'C:\Projects\AuthLibrary\AuthLibrary.psm1' -Verbose -Force

#$myToken = New-SAMLToken -
$request = New-MsIdSamlRequest -Issuer 'https://samltool.io' #-AssertionConsumerServiceURL 'https://samltool.io/#hittepa'
# -AssertionConsumerServiceURL 'https://login.microsoftonline.com/d3fffe95-41a8-4486-8a2b-9502bcdac64d/saml2'
$request = New-MSIDSamlRequest -Issuer 'urn:microsoft:adfs:claimsxray'
Get-MsIdSamlFederationMetadata -Issuer 'https://sts.windows.net/d3fffe95-41a8-4486-8a2b-9502bcdac64d/' -Verbose

Invoke-MsIdAzureAdSamlRequest -SamlRequest $request -Verbose -TenantId 'd3fffe95-41a8-4486-8a2b-9502bcdac64d'
