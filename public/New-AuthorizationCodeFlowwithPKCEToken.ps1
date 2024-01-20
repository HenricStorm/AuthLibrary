# Generate new token using the Authorization Code Flow with PKCE
# Example DEV; $t = New-AuthorizationCodeFlowwithPKCEToken -ClientId "Lpm7yAITd7wR0Xk2jUPbrlw1dEVXDkhz" -Scopes "openid","profile","email","read:workorder","update:workorder","read:workorder-proposedwork","update:workorder-proposedwork","read:workorder-completedwork","update:workorder-completedwork" -Audience "https://acos01apms.azure-api.net" -LoginHint "henric@thestorms.se" -RedirectUri "https://jwt.ms" -Auth0Domain "identity-dev.coor.com"
# Example PROD; $t = New-AuthorizationCodeFlowwithPKCEToken -ClientId "1ACjkTgMLojkB1tloTbRXuADTQ1wQLnP" -Scopes "openid","profile","email","read:workorder","update:workorder","read:workorder-proposedwork","update:workorder-proposedwork","read:workorder-completedwork","update:workorder-completedwork" -Audience "https://acos02apms.azure-api.net" -LoginHint "henric@thestorms.se" -RedirectUri "https://jwt.ms" -Auth0Domain "identity.coor.com"

function New-AuthorizationCodeFlowwithPKCEToken
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [string[]]$Scopes,
        [Parameter()]
        [string]$Audience,
        [Parameter()]
        [string]$LoginHint,
        [Parameter(Mandatory)]
        [string]$RedirectUri,
        [Parameter(Mandatory)]
        [string]$Auth0Domain
    )

    # In order to this function to run, Silenium Web Driver DLL needs to be downloaded; https://www.selenium.dev/downloads/
    # Also you need to download the "msedgedriver.exe" matching your Edge browser version; https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver
    # Also the PKCE module needs to be installed; Install-Module -Name PKCE
    $seleniumWebDriverPath = "C:\Users\HenricStorm\OneDrive - Advania\Kunder\Coor\Auth0 Powershell"

    if (!(CheckMsEdgeDriverVersion -MsEdgeDriverPath "$($seleniumWebDriverPath)\msedgedriver.exe"))
    {
        break
    }

    # Import module WebDriver if not already imported
    if (!(Get-Module -Name WebDriver))
    {
        Write-Verbose "Loading module ""WebDriver"""
        try {
            Import-Module -Name "$($seleniumWebDriverPath)\WebDriver.dll" -ErrorAction Stop
        }
        catch
        {
            Write-Host -ForegroundColor Red $_.Exception.Message
            break
        }
    }

    # Import module PKCE if not already imported
    if (!(Get-Module -Name PKCE))
    {
        Write-Verbose "Loading module ""PKCE"""
        try {
            Import-Module -Name PKCE -ErrorAction Stop
        }
        catch
        {
            Write-Host -ForegroundColor Red $_.Exception.Message
            break
        }
    }

    # Proof Key for Code Exchange (PKCE)
    $pkce = New-PKCE

    # Add scopes
    $Scopes = $Scopes -join ' '

    # IDP Information
    $baseUri = "https://$($Auth0Domain)"
    $authorizeEndpoint = "$($baseUri)/authorize"
    $tokenEndpoint = "$($baseUri)/oauth/token"

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

    $uri = "$($authorizeEndpoint)?$($querystring)"
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

    $headers = @{
        "content-type" = "application/x-www-form-urlencoded"
    }

    $body = @{
        "grant_type" = "authorization_code"
        "client_id" = $ClientId
        "code_verifier" = $pkce.code_verifier
        "code" = $code
        "redirect_uri" = $RedirectUri
    }

    $params = @{
        Uri     = $tokenEndpoint
        Method  = "Post"
        Headers = $headers
        Body = $body
    }

    return Invoke-RestMethod @params
}
