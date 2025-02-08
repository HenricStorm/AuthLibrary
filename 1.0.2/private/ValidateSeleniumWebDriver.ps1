function ValidateSeleniumWebDriver {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    if (!(Test-Path -Path $Path)) {
        Write-Host "Selenium Web Driver binary is missing and needs to be downloaded."
        return $false
    }

    return $true
}
