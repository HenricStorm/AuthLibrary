# Generate new token using the Authorization Code Flow
# Example; $t = New-AuthorizationCodeFlowToken -ClientId "Lpm7yAITd7wR0Xk2jUPbrlw1dEVXDkhz" -Scopes "openid","profile","email","serviceRequest","read:workorder","create:workorder" -Audience "https://acos01apms.azure-api.net" -LoginHint "henric@thestorms.se"
function New-AuthorizationCodeFlowToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'Entra')]
        [string]
        $ClientId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'Entra')]
        [string]
        $ClientSecret,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'Entra')]
        [ValidatePattern('^(https?)://')]
        [System.Uri]
        $RedirectUri,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'Entra')]
        [string[]]
        $Scopes,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Entra')]
        [string]
        $Audience,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [ValidatePattern('^(https?)://')]
        [System.Uri]
        $AuthorizeEndpointUri,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [ValidatePattern('^(https?)://')]
        [System.Uri]
        $TokenEndpointUri,

        [Parameter(Mandatory, ParameterSetName = 'Entra')]
        [System.Guid]
        $EntraTenantId, # To build "https://login.microsoftonline.com/{domain name}/v2.0/.well-known/openid-configuration"

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Entra')]
        [string]
        $LoginHint,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Entra')]
        [string[]]
        $AdditionalParameters
    )

    #. "C:\Projects\Coor.CustomerIdentityPlatform\Auth0 Powershell Modules\Manage-Auth0\Private\CheckMsEdgeDriverVersion.ps1"
    #. "C:\Projects\Coor.CustomerIdentityPlatform\Auth0 Powershell Modules\Manage-Auth0\Public\Start-UpdateMsEdgeDriverVersion.ps1"

    # In order to this function to run, Silenium Web Driver DLL needs to be downloaded; https://www.selenium.dev/downloads/
    # Also you need to download the "msedgedriver.exe" matching your Edge browser version; https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver
    $seleniumWebDriverPath = 'C:\Users\HenricStorm\OneDrive - Advania\Kunder\Coor\Auth0 Powershell'

    if (!(CheckMsEdgeDriverVersion -MsEdgeDriverPath ('{0}\msedgedriver.exe' -f $seleniumWebDriverPath))) {
        break
    }

    if (!(Get-Module -Name WebDriver)) {
        Write-Verbose 'Loading module "WebDriver"'
        try {
            Import-Module -Name ('{0}\WebDriver.dll' -f $seleniumWebDriverPath) -ErrorAction Stop
        }
        catch {
            Write-Host -ForegroundColor Red $_.Exception.Message
            break
        }
    }

    $Scopes = $Scopes -join ' '

    # IDP Information
    #$baseUri = "https://$($Auth0Domain)"
    #$tokenAuthorizeEndpoint = "$($baseUri)/authorize"
    #$tokenEndpoint = "$($baseUri)/oauth/token"

    # Optionals
    #$Audience = "https://acos01apms.azure-api.net"
    #$LoginHint = "henric@thestorms.se"

    if ($PSCmdlet.ParameterSetName -eq 'Entra') {
        $params = @{
            Method = 'Get'
            Uri    = 'https://login.microsoftonline.com/{0}/v2.0/.well-known/openid-configuration' -f $EntraTenantId
        }
        $response = Invoke-RestMethod @params
        $TokenEndpointUri = $response.token_endpoint
    }

    $querystringBuilder = @{
        'client_id'     = $ClientId
        'scope'         = [System.Web.HTTPUtility]::UrlEncode($Scopes)
        'redirect_uri'  = [System.Web.HTTPUtility]::UrlEncode($RedirectUri)
        'response_type' = 'code'
    }
    if ($Audience) {
        $querystringBuilder.Add('audience', [System.Web.HTTPUtility]::UrlEncode($Audience))
    }
    if ($LoginHint) {
        $querystringBuilder.Add('login_hint', [System.Web.HTTPUtility]::UrlEncode($LoginHint))
    }
    $querystring = $querystringBuilder | ConvertTo-QueryString

    if ($AdditionalParameters) {
        $querystring += '&{0}' + $AdditionalParameters -join "&"
    }

    $options = New-Object OpenQA.Selenium.Edge.EdgeOptions
    $options.AddArgument('--log-level=3')
    $options.AddArgument('--disable-logging')
    $options.AddArgument('--window-size=600,800')
    $options.AddArgument('--output=/dev/null')
    $options.AddArgument('--disable-extensions')
    #$options.AddArgument('--headless')
    #$options.AcceptInsecureCertificates = $true
    $logLevel = [OpenQA.Selenium.LogLevel] 'Off' # All[0], Debug[1], Info[2], Warning[3], Severe[4], Off[5]
    $options.SetLoggingPreference([OpenQA.Selenium.LogType]::Browser, $logLevel)
    #$options.SetLoggingPreference([OpenQA.Selenium.LogType]::Client, $logLevel)
    $options.SetLoggingPreference([OpenQA.Selenium.LogType]::Driver, $logLevel)
    #$options.SetLoggingPreference([OpenQA.Selenium.LogType]::Profiler, $logLevel)
    #$options.SetLoggingPreference([OpenQA.Selenium.LogType]::Server, $logLevel)
    try {
        $webDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($options)
    }
    catch {
        Write-Warning "$($_.Exception.Message)"
        break
    }

    $webDriver.Url = "${AuthorizeEndpointUri}?${querystring}"
    Write-Verbose "Opening URI: ${$webDriver.Url}"
    Write-Verbose 'Opening Web browser. Please authenticate.'

    # Enable a pause here to see what is going on if $code does not look as expected!
    #pause

    while (!$webDriver.Url.Contains('code=')) {
        Start-Sleep -Seconds 1
    }
    $parsedQueryString = [System.Web.HttpUtility]::ParseQueryString($webDriver.Url)
    Write-Host ($parsedQueryString -join "|")
    Write-Host ($parsedQueryString.Gettype())
    $code = $parsedQueryString[0]
    $webDriver.Quit()

    Write-Verbose ('Received code: {0}' -f $code)
    Write-Verbose 'Exchanging code for a token'

    $params = @{
        Uri     = $TokenEndpointUri
        Method  = 'Post'
        Headers = @{
            'content-type' = 'application/x-www-form-urlencoded'
        }
        Body    = @{
            "grant_type"    = "authorization_code"
            "client_id"     = $ClientId
            "client_secret" = $ClientSecret
            "code"          = $code
            "redirect_uri"  = $RedirectUri
        }
    }

    #Write-Host -ForegroundColor Cyan "URI: $($uri)"
    #Write-Host -ForegroundColor Cyan "Headers: $($headers | ConvertTo-Json -Depth 5)"
    #Write-Host -ForegroundColor Cyan "Body: $($body | ConvertTo-Json -Depth 5)"
    return Invoke-RestMethod @params
}
