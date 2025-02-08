function ConvertTo-Hex {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [byte[]]
        $Bytes,

        [Parameter()]
        [switch]
        $ToUpper
    )

    process {
        $format = if ($ToUpper.IsPresent) { 'X2' } else { 'x2' }
        $HexChars = $Bytes | Foreach-Object -MemberName ToString -ArgumentList $format
        $HexString = -join $HexChars
        Write-Output $HexString
    }
}
