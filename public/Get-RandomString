function Get-RandomString {
    param (
        [Parameter(Mandatory)]
        [int]
        $Length
    )
    -join (Get-Random -InputObject 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray() -Count $Length)
}
