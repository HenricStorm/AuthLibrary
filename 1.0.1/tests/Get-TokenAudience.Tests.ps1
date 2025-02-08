Describe 'Get-TokenAudience' {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-TokenAudience.ps1"
        . "$PSScriptRoot\..\public\Expand-JWTtoken.ps1"
    }

    It 'Given a token, it returns the audience of the token.access_token' {
        $token = @{
            access_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2FwaS5leGFtcGxlLmNvbSIsInN1YiI6IjEyMzQ1Njc4OTAiLCJuYW1lIjoiSm9obiBEb2UiLCJpYXQiOjE1MTYyMzkwMjJ9.49hB-NAb2tRidNyMCy-oYB4YHQLxaPUXrw7N7Ezp8i8'
        }
        $audience = Get-TokenAudience -Token $token
        $audience | Should -Be 'https://api.example.com'
    }
    It 'Given an access_token, it returns the audience' {
        $access_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2FwaS5leGFtcGxlLmNvbSIsInN1YiI6IjEyMzQ1Njc4OTAiLCJuYW1lIjoiSm9obiBEb2UiLCJpYXQiOjE1MTYyMzkwMjJ9.49hB-NAb2tRidNyMCy-oYB4YHQLxaPUXrw7N7Ezp8i8'
        $audience = Get-TokenAudience -AccessToken $access_token
        $audience | Should -Be 'https://api.example.com'
    }
    It 'Given an access_token with no audience, it returns null' {
        $access_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
        $audience = Get-TokenAudience -AccessToken $access_token
        $audience | Should -Be $null
    }
    It 'Should throw if given an invalid access_token' {
        $access_token = 'eyJFUBAR'
        { Get-TokenAudience -AccessToken $access_token } | Should -Throw 'Invalid token'
    }
}
