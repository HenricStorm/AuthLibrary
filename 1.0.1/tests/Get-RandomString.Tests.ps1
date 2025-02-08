Describe 'Get-TokenAudience' {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-RandomString.ps1"
    }

    It 'Should return a value of type string' {
        Get-RandomString -Length 10 | Should -BeOfType [string]
    }
    It 'Should return a string of length 10' {
        $string = Get-RandomString -Length 10
        $string.length | Should -Be 10
    }
    It 'Should throw if length is less than 1' {
        { Get-RandomString -Length 0 } | Should -Throw
    }
}
