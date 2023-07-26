
<#
.SYNOPSIS
Deletes an existing cost item.

.DESCRIPTION
Sends a DELETE request to the APS API to remove the specified item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER costItemId
ID of the cost item to be removed.

.PARAMETER scope
The scope of the cost item, usually by change order type. Possible values: rfq, sco, pco, rco, oco.

.EXAMPLE
Remove-APSCostItem -ProjectID $ProjectID -costItemId $CI

Deletes the specified Cost Item object in the project.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-cost-items-costItemId-DELETE/
#>
function Remove-APSCostItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$costItemId,

        # Query String Parameters
        $scope
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/cost-items/$($costItemId)"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Add query string parameters
    if ($scope) { $Body["scope"] = $scope }

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}