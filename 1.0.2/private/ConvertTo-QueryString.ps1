function ConvertTo-QueryString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable]
        $Hashtable
    )

    process {
        return $Hashtable.GetEnumerator() | ForEach-Object {
            '{0}={1}' -f $_.key, $_.value
        } | Join-String -Separator '&'
    }
}
