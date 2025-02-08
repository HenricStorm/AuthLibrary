Describe 'hmac' {
    BeforeAll {
        . "$PSScriptRoot\..\private\hmac.ps1"
    }

    It 'Should return a value of type string' {
        hmac -Message 'fubar' -Secret 'none' | Should -BeOfType [string]
    }
    It 'Should return a specific value' {
        hmac -Message 'fubar' -Secret 'none' | Should -Be 'Gtus/lOhMaSSk3U9SN1NBDkFAlQrzsFtOWpRKQfQg2w='
    }
}
