function ConvertTo-SHA256Hash {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $String
    )

    process {
        $Hasher = [System.Security.Cryptography.SHA256]::Create()
        $HashBytes = $Hasher.ComputeHash([System.Text.Encoding]::Default.GetBytes($String))
        $Hash = ConvertTo-Hex -Bytes $HashBytes
        Write-Output $Hash
    }
}
