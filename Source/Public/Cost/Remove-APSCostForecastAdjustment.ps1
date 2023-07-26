
<#
.SYNOPSIS
Deletes a Forecast Adjustment.

.DESCRIPTION
Sends a DELETE request to the APS API to remove the specified item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER forecastId
ID of the forecast adjustment to be removed.

.EXAMPLE
Remove-APSCostForecastAdjustment -ProjectID $ProjectID -forecastId $forecast

Deletes the specified Forecast Adjustment object in the project.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-forecast-adjustments-id-DELETE/
#>
function Remove-APSCostForecastAdjustment {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$forecastId
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/forecast-adjustments/$($forecastId)"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}