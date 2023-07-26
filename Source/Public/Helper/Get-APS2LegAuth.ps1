
<#
.SYNOPSIS
Returns a 2 Legged Auth token.

.DESCRIPTION
Obtains a 2-Legged Auth token with the specified scope from APS.

.PARAMETER passID
Passwordstate password ID of the application's ClientID and ClientSecret.

.PARAMETER scope
List of scopes requested for the OAUTH token.

.EXAMPLE
$2LegTok = Get-APS2LegAuth -scope "account:read"

Obtains a 2-Legged Auth token with read permissions and stores it into the variable $2LegTok.

.NOTES
Must have set the passwordstate-management environment beforehand with the API key.
Functionality is entirely dependent on the passwordstate entry existing/being accurate.
#>
function Get-APS2LegAuth {
    Param(
        $passID = 551,
        $scope = "account:read"
    )
    #Retrieve ClientID and ClientSecret from PWState, convert to Base64
    $PWObj = (Get-PasswordStatePassword -PasswordID $passID)
    $PWObj.DecryptPassword()
    $User = $PWObj.Username
    $Pass = $PWObj.Password
    [string]$Composite = $User + ":" + $Pass
    $B64 = [Convert]::ToBase64String([char[]]$Composite)

    #Use B64 to retrieve a 2-Legged Token
    $2LegUrl = 'https://developer.api.autodesk.com/authentication/v2/token'
    $header = @{}
    $header["Content-Type"] = "application/x-www-form-urlencoded"
    $header["Accept"] = "application/json"
    $header["Authorization"] = "Basic $($B64)"
    $body = @{}
    $body["grant_type"] = "client_credentials"
    $body["scope"] = $scope
    $2LegTok = Invoke-Restmethod -Method POST -Uri $2LegUrl -Header $header -Body $body
    return $2LegTok.access_token
}