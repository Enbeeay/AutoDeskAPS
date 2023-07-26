
<#
.SYNOPSIS
Create a new Forecast Adjustment in a specific project.

.DESCRIPTION
Sends a POST request to the APS API to add a forecast adjustment to a specified budget in a given project.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER budgetId
The ID of the Budget to which the forecast adjustment belongs.

.PARAMETER id
Unique identifier of the forecast adjustment to create.

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
Add-APSCostForecastAdjustment -ProjectID $ProjectID -budgetId $budget -quantity 200 -description "Post FC"

Adds a forecast adjustment with the given parameters to the budget $budget in the project $ProjectID

.NOTES
Does not work due to token privilege? as of 6/27/2023
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-forecast-adjustments-POST/
#>
function Add-APSCostForecastAdjustment {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$budgetId,

        # Add all optional parameters, must include type
        [string]$id,
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

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/forecast-adjustments"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget POST
    # $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["budgetId"] = $budgetId

    # Initialize all optional parameters
    if ($id) { $Body["id"] = $id }
    if ($contractID) { $Body["contractID"] = $contractID }
    if ($description) { $Body["description"] = $description }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($integrationState) { $Body["integrationState"] = $integrationState }


    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}