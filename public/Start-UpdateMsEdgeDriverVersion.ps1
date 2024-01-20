function Start-UpdateMsEdgeDriverVersion
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$MsEdgeDriverPath
    )

    #$baseUri = "https://msedgewebdriverstorage.z22.web.core.windows.net"
    $msEdgeVersion = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Edge\BLBeacon" -Name version

    #Invoke-Webrequest -Uri "$($baseUri)/?prefix=$($msEdgeDriverVersion)/"
    $directory = ([System.IO.FileInfo]$MsEdgeDriverPath).DirectoryName
    $downloadedFilePath = "$($directory)\edgedriver_win64.zip"

    if (!(Test-Path -Path $directory))
    {
        Write-Host "Directory $($directory) does not exists. Creating it."
        New-Item -Path $directory
    }
    Write-Host "Downloading version $($msEdgeVersion) of MS Edge Driver x64 to ""$($directory)"""
    Invoke-WebRequest -Uri "https://msedgedriver.azureedge.net/$($msEdgeVersion)/edgedriver_win64.zip" -OutFile $downloadedFilePath
    Expand-Archive -Path $downloadedFilePath -DestinationPath "$($directory)\MSEdgeDriver.$($msEdgeVersion)"
    #Remove-Item -Path $MsEdgeDriverPath
    Copy-Item -Path "$($directory)\MSEdgeDriver.$($msEdgeVersion)\msedgedriver.exe" -Destination $directory
    Remove-Item -Path "$($directory)\MSEdgeDriver.$($msEdgeVersion)" -Recurse:$true
}
