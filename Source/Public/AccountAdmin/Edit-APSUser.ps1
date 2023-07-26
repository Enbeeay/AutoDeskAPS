<#
.SYNOPSIS
Updates a specific user’s status or default company.

.DESCRIPTION
Allows an admin to change the status of a user "active, inactive, etc." and the default company

.PARAMETER AccountID
The ID of the Account that contains the users

.PARAMETER UserID
The ID of the User you wish to change

.PARAMETER Company_ID
The user’s default company ID in BIM 360

.PARAMETER Status
New status to set the user to (only if not currently pending or not_invited)

Possible values:
active: user is active and has logged into the system sucessfully
inactive: user is disabled

.EXAMPLE
Edit-APSUser -AccountID $AccountID -UserID $UserID -Status "Active"

.NOTES
ONLY company ID and Status can be changed with this function
#>
function Edit-APSUser {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$AccountID,

        [Parameter(Mandatory = $true)]
        [string]$UserID,


        [string]$Company_ID,
        [string]$Status

    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/users-:user_id-PATCH/

    # Retrieve access token information stored in the PasswordState API
    $2LegTok = Get-APS2LegAuth -scope "account:write"

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountID/users/$UserID"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($2LegTok)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Add query string parameters


    # Initialize all optional parameters
    if ($status) { $Body["status"] = $status
    }
    if ($Company_ID) { $Body["Company_ID"] = $Company_ID
    }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json
    Write-Host $PATCHUrl
    Write-Host $Body

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}