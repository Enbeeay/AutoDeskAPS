
<#
.SYNOPSIS
Attaches/detaches a change order and cost item together.

.DESCRIPTION
Sends a POST request to the APS API to control the association between a CO and CI.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER changeOrderId
ID of the change order.

.PARAMETER costItemId
ID of the cost item.

.PARAMETER detatch
Boolean value determining if it detaches or attaches.

.EXAMPLE
Join-APSCostCOCI -ProjectID $ProjectID -changeOrderId $CO -costItemId $CI

Associates the change order $CO and the cost item $CI.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/bim360/v1/reference/http/cost-cost-items/attach-POST/

#>
function Join-APSCostCOCI {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$changeOrderId,
        [Parameter(Mandatory = $true)]
        [string]$costItemId,

        # Optional parameter to Detach instead of Attach
        [bool]$detatch
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft POST message
    # Set the URL per APS docs
    if ($detach) {
        $JOINUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/cost-items:detach"
    }
    else {
        $JOINUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/cost-items:attach"
    }

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @()
    $hashBody = @{}
    $hashBody["changeOrderId"] = $changeOrderId
    $hashBody["costItemId"] = $costItemId
    $Body += $hashBody
    $Body = ConvertTo-Json -InputObject $Body

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $JOINUrl -Header $Header -Body $Body
}