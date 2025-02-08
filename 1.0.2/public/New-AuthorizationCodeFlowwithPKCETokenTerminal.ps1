# Generate new token using the Authorization Code Flow with PKCE
# Example; $t = New-AuthorizationCodeFlowwithPKCETokenTerminal -ClientId "Lpm7yAITd7wR0Xk2jUPbrlw1dEVXDkhz" -LoginHint "henric@thestorms.se" -RedirectUri "https://jwt.ms" -AuthorizeEndpointUri "https://identity-dev.coor.com/authorize" -TokenEndpointUri "https://identity-dev.coor.com/oauth/token"
function New-AuthorizationCodeFlowwithPKCETokenTerminal {
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
        [string]
        $RedirectUri,

        [Parameter(Mandatory)]
        [string]
        $AuthorizeEndpointUri,

        [Parameter(Mandatory)]
        [string]
        $TokenEndpointUri,

        [Parameter()]
        [string]
        $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0'
    )

    # The PKCE module needs to be installed; Install-Module -Name PKCE
    # Import module PKCE if not already imported
    if (!(Get-Module -Name PKCE)) {
        Write-Verbose 'Loading module "PKCE"'
        try {
            Import-Module -Name 'PKCE' -Force -ErrorAction Stop
        }
        catch {
            Write-Host -ForegroundColor Red $_.Exception.Message
            break
        }
    }

    # Proof Key for Code Exchange (PKCE)
    $pkce = New-PKCE
    #$random = Get-RandomString -Length 128
    #$pkce = @{
    #    code_verifier = $random
    #    code_challenge = $random | ConvertTo-SHA256Hash | ConvertTo-Base64
    #}

    # Add scopes
    $Scopes = $Scopes -join ' '

    # IDP Information
    #$baseUri = "https://$($Auth0Domain)"
    #$authorizeEndpoint = "$($baseUri)/authorize"
    #$tokenEndpoint = "$($baseUri)/oauth/token"

    $querystring = @(
        'client_id={0}' -f $ClientId
        'scope={0}' -f [System.Web.HTTPUtility]::UrlEncode($Scopes)
        'redirect_uri={0}' -f [System.Web.HTTPUtility]::UrlEncode($RedirectUri)
        'response_type=code'
        'code_challenge={0}' -f $pkce.code_challenge
        'code_challenge_method=S256'
    ) -join "&"

    if ($LoginHint) {
        $querystring += '&login_hint={0}' -f [System.Web.HTTPUtility]::UrlEncode($LoginHint)
    }
    if ($Audience) {
        $querystring += '&audience={0}' -f [System.Web.HTTPUtility]::UrlEncode($Audience)
    }

    #$uri = "$($authorizeEndpoint)?$($querystring)"
    $uri = "$($AuthorizeEndpointUri)?$($querystring)"
    Write-Verbose "Opening URI: $($uri)"
    Write-Verbose "Opening Web browser. Please authenticate."

    <#
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
    #>


    #$LoginSession = New-LoginSession -Region $Region -UserAgent $UserAgent
    #$Code = Get-TeslaAuthCode -Username $Username -Password $Password -MfaCode $MFACode -LoginSession $LoginSession
    #$AuthTokens = Get-TeslaAuthToken -Code $Code -LoginSession $LoginSession

    # Create login session and return form fields
    $Params = @{
        Headers   = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
        }
        UserAgent = $UserAgent
        Method    = 'GET'
        Uri       = $uri
    }
    $Response = Invoke-WebRequest @Params -SessionVariable 'WebSession' -ErrorAction 'Stop'
    $FormFields = @{}
    #[Regex]::Matches($Response.Content, 'type=\"hidden\" name=\"(?<name>.*?)\" value=\"(?<value>.*?)\"') | Foreach-Object {
    #    $FormFields.Add($_.Groups['name'].Value, $_.Groups['value'].Value)
    #}
    [Regex]::Matches($Response.Content, 'name=\"(?<name>.*?)\"') | Foreach-Object {
        $FormFields.Add($_.Groups['name'].Value, $_.Groups['value'].Value)
    }

    Write-Host ('Form fields: {0}' -f ($FormFields -join ', '))
    Write-Host ('Session: {0}' -f $WebSession)






    Write-Verbose "Received code: $code"
    Write-Verbose "Exchanging code for a token"

    $params = @{
        Headers = @{
            'content-type' = 'application/x-www-form-urlencoded'
        }
        Method  = 'Post'
        #Uri     = $tokenEndpoint
        Uri     = $TokenEndpointUri
        Body    = @{
            'grant_type'    = 'authorization_code'
            'client_id'     = $ClientId
            'code_verifier' = $pkce.code_verifier
            'code'          = $code
            'redirect_uri'  = $RedirectUri
        }
    }

    return Invoke-RestMethod @params
}
