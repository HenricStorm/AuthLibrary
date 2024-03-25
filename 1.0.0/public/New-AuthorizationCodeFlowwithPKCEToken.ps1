# Generate new token using the Authorization Code Flow with PKCE
function New-AuthorizationCodeFlowwithPKCEToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter()]
        [string[]]
        $Scopes = @('openid', 'profile', 'email'),

        [Parameter()]
        [string]
        $Audience,

        [Parameter()]
        [string]
        $LoginHint,

        [Parameter(Mandatory)]
        [System.Uri]
        $RedirectUri,

        [Parameter(Mandatory)]
        [System.Uri]
        $AuthorizeEndpointUri,

        [Parameter(Mandatory)]
        [System.Uri]
        $TokenEndpointUri,

        [Parameter()]
        [System.Uri]
        $ClientAssertion
    )

    # In order to this function to run, Silenium Web Driver DLL needs to be downloaded; https://www.selenium.dev/downloads/
    # Also you need to download the "msedgedriver.exe" matching your Edge browser version; https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver
    # Also the PKCE module needs to be installed; Install-Module -Name PKCE
    $seleniumWebDriverPath = "C:\Users\HenricStorm\OneDrive - Advania\Kunder\Coor\Auth0 Powershell"

    if (!(CheckMsEdgeDriverVersion -MsEdgeDriverPath "$($seleniumWebDriverPath)\msedgedriver.exe")) {
        break
    }

    # Import module WebDriver if not already imported
    if (!(Get-Module -Name WebDriver)) {
        Write-Verbose "Loading module ""WebDriver"""
        try {
            Import-Module -Name "$($seleniumWebDriverPath)\WebDriver.dll" -ErrorAction Stop
        }
        catch {
            Write-Host -ForegroundColor Red $_.Exception.Message
            break
        }
    }

    # Import module PKCE if not already imported
    if (!(Get-Module -Name PKCE)) {
        Write-Verbose 'Loading module "PKCE"'
        try {
            Import-Module -Name PKCE -ErrorAction Stop
        }
        catch {
            Write-Host -ForegroundColor Red $_.Exception.Message
            break
        }
    }

    # Proof Key for Code Exchange (PKCE)
    $pkce = New-PKCE

    # Add scopes
    $Scopes = $Scopes -join ' '

    $querystring = @(
        "client_id=$($ClientId)"
        "scope=$([System.Web.HTTPUtility]::UrlEncode($Scopes))"
        "redirect_uri=$([System.Web.HTTPUtility]::UrlEncode($RedirectUri))"
        "response_type=code"
        "code_challenge=$($pkce.code_challenge)"
        "code_challenge_method=S256"
    ) -join "&"

    if ($LoginHint) {
        $querystring += "&login_hint=$([System.Web.HTTPUtility]::UrlEncode($LoginHint))"
    }
    if ($Audience) {
        $querystring += "&audience=$([System.Web.HTTPUtility]::UrlEncode($Audience))"
    }

    #$uri = "$($authorizeEndpoint)?$($querystring)"
    $uri = "$($AuthorizeEndpointUri)?$($querystring)"
    Write-Verbose "Opening URI: $($uri)"
    Write-Verbose "Opening Web browser. Please authenticate."

    $options = New-Object OpenQA.Selenium.Edge.EdgeOptions
    $options.AddArgument("--log-level=3")
    $options.AddArgument("--disable-logging")
    $options.AddArgument("--window-size=600,800")
    $options.AddArgument("--output=/dev/null")
    $options.AddArgument("--disable-extensions")
    #$options.AddArgument("--headless")
    #$options.AcceptInsecureCertificates = $true
    $logLevel = [OpenQA.Selenium.LogLevel] "Off" # All[0], Debug[1], Info[2], Warning[3], Severe[4], Off[5]
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
    $webDriver.Url = $uri

    # Enable a pause here to see what is going on if $code does not look as expected!
    #pause

    while (!$webDriver.Url.Contains("code=")) { Start-Sleep -Seconds 1 }
    $parsedQueryString = [System.Web.HttpUtility]::ParseQueryString($webDriver.Url)
    #Write-Host -ForegroundColor Magenta "Parsed querystring: $($parsedQueryString)"
    $code = $parsedQueryString[0]
    $webDriver.Quit()

    Write-Verbose "Received code: $code"
    Write-Verbose "Exchanging code for a token"

    $body = @{
        "grant_type"    = "authorization_code"
        "client_id"     = $ClientId
        "code_verifier" = $pkce.code_verifier
        "code"          = $code
        "redirect_uri"  = $RedirectUri
    }

    if ($ClientAssertion) {
        $body.Add('client_assertion', $ClientAssertion)
        $body.Add('client_assertion_type', 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer')
    }

    Write-Verbose "Body: $($body | ConvertTo-Json -Depth 5)"

    $params = @{
        Headers = @{
            'content-type' = 'application/x-www-form-urlencoded'
        }
        Method  = 'Post'
        Uri     = $TokenEndpointUri
        Body    = $body
    }

    return Invoke-RestMethod @params
}
