
<#
.SYNOPSIS
Updates a Forecast Adjustment.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER forecastId
ID of the forecast adjustment.

.PARAMETER contractID
The ID of the Contract to which the forecast adjustment belongs.

.PARAMETER description
A detailed description of the item.

.PARAMETER quantity
Quantity of labor, material, etc. planned for a budget.

.PARAMETER unitPrice
Unit price of a budget.

.PARAMETER unit
Unit of measures used in the budget.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Edit-APSCostForecastAdjustment -ProjectID $ProjectID -forecastId $forecast -description "Patch FC"

Edits the description of $forecast to be "Patch FC"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-forecast-adjustments-id-PATCH/
#>
function Edit-APSCostForecastAdjustment {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$forecastId,

        # Add all optional parameters, must include type
        [string]$contractID,
        [string]$description,
        [int]$quantity,
        $unitPrice,
        [string]$unit,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/forecast-adjustments/$($forecastId)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Initialize all optional parameters
    if ($contractID) { $Body["contractID"] = $contractID }
    if ($description) { $Body["description"] = $description }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}