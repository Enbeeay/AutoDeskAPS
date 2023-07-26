
<#
.SYNOPSIS
Updates an actual cost.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER actualCostId
The object ID of the item.

.PARAMETER contractID
The ID of the Contract to which the actual cost belongs.

.PARAMETER name
The name of the item.

.PARAMETER quantity
Quantity of labor, material, etc. planned for a budget.

.PARAMETER unitPrice
Unit price of a budget.

.PARAMETER unit
Unit of measures used in the budget.

.PARAMETER exchangeRate
Exchange rate. Default value is 1, if multi-currency is not enabled, it will also be 1.

.EXAMPLE
Edit-APSCostActualCost -ProjectID $ProjectID -actualCostId $ac -name "Patch AC"

Edits the name of the actual cost $ac to the value provided.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-actual-costs-id-PATCH/
#>
function Edit-APSCostActualCost {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$actualCostId,

        # Add all optional parameters, must include type
        [string]$contractID,
        [string]$name,
        [int]$quantity,
        $unitPrice,
        [string]$unit,
        $exchangeRate
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/actual-costs/$($actualCostId)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Set all parameters
    if ($contractID) { $Body["contractID"] = $contractID }
    if ($name) { $Body["name"] = $name }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}