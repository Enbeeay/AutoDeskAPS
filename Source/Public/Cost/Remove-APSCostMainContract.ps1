
<#
.SYNOPSIS
Deletes a new main contract item in the specified project.

.DESCRIPTION
Sends a DELETE request to the APS API to remove the specified item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER mainContractId
ID of the main contract to be removed.

.PARAMETER force
This request forces an override of locking so the request can succeed.

.EXAMPLE
Remove-APSCostMainContract -ProjectID $ProjectID -MainContractId $mainContract

Deletes the specified Main Contract object in the project.

.NOTES
Autodesk API Documentation - no documentation exists (as of 06/21/2023), good luck :)
#>
function Remove-APSCostMainContract {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$mainContractId,

        $force
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/main-contracts/$($mainContractId)"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Add query string parameters
    if ($force) { $Body["force"] = $force }

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}