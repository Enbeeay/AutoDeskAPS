
<#
.SYNOPSIS
Returns a 3 Legged Auth token.

.DESCRIPTION
Grabs the 3 legged Auth token stored in the passwordstate entry associated with it.

.PARAMETER passID
Passwordstate password ID of the access token.

.EXAMPLE
$PWStateObject = Get-PWTokObject;   $PWStateObject.DecryptPassword()

Obtains the PWState object containing the access token, stores it into $PWStateObject,
and then decrypts the password to be able to use the access token.

.NOTES
Must have set the passwordstate-management environment beforehand with the API key.
Functionality is entirely dependent on the passwordstate entry existing/being accurate,
and the C# server running on Azure functioning and regularly refreshing said entry.
#>
function Get-PWTokObject {
    Param(
        $passID = 549
    )
    #Retrieve token object from passwordstate
    $PWStateObject = (Get-PasswordStatePassword -PasswordID $passID)
    return $PWStateObject
}