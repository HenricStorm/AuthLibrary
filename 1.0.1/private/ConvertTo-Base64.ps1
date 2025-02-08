function ConvertTo-Base64 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $String
    )

    process {
        [convert]::ToBase64String([System.Text.Encoding]::Default.GetBytes($String))
    }
}
