function ConvertTo-Base64 {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $String
    )

    process {
        [convert]::ToBase64String([System.Text.Encoding]::Default.GetBytes($String))
    }
}
