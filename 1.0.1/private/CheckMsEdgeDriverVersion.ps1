function CheckMsEdgeDriverVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $MsEdgeDriverPath
    )

    $msEdgeVersion = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Edge\BLBeacon" -Name version
    if (!(Test-Path -Path $MsEdgeDriverPath)) {
        Write-Host "MS Edge Driver binary is missing and needs to be downloaded."
        Write-Host "Starting update!"
        Start-UpdateMsEdgeDriverVersion -MsEdgeDriverPath $MsEdgeDriverPath
        Write-Host "Update complete! Please rerun script."
        return $false
    }

    $msEdgeDriverVersion = (Get-Item -Path $MsEdgeDriverPath).VersionInfo

    # Check if MS Edge Driver version is same as MS Edge version
    if ($msEdgeVersion.Split('.')[0] -ne $msEdgeDriverVersion.ProductVersionRaw.Major) {
        #Write-Warning "MS Edge Driver version [$($msEdgeDriverVersion.ProductVersion)] does not match the MS Edge version [$($msEdgeVersion)]. Update needed! Download it from https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver"
        Write-Warning "MS Edge Driver version [$($msEdgeDriverVersion.ProductVersion)] does not match the MS Edge version [$($msEdgeVersion)]. Update needed!"
        Write-Host "Starting update!"
        Start-UpdateMsEdgeDriverVersion -MsEdgeDriverPath $MsEdgeDriverPath
        Write-Host "Update complete! Please rerun script."
        return $false
    }
    else {
        Write-Host "MS Edge Driver is up to date"
        return $true
    }
}
