
<#
.SYNOPSIS
Updates the specified schedule of values (SOV) item in the given project.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER SOVID
ID of the SOV item.

.PARAMETER code
The code of the SOV item.

.PARAMETER name
The name of the item.

.PARAMETER quantity
The quantity of the SOV item.

.PARAMETER unitPrice
The unit price of the SOV item.

.PARAMETER unit
The unit of measure of the SOV item.

.PARAMETER amount
The total price of the SOV item.

.PARAMETER lockedField
The field of the SOV item to lock. You can lock the item’s quantity, unitPrice, or amount when calculating its cost.

.PARAMETER quantityPerBulk
The quantity conversion ratio of the SOV item.

.PARAMETER exchangeRate
The exchange rate that applies to the SOV item’s base currency price. For example, provide the value 0.7455 for a foreign currency that’s worth 0.7455 of your base currency.

.EXAMPLE
Edit-APSCostScheduleOfValues -ProjectID $ProjectID -SOVID $SOV -name "TEST"

Edits the name of the schedule of values $SOV to "TEST"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-schedule-of-values-id-PATCH/

#>
function Edit-APSCostScheduleOfValues {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Alias("id")]
        [Parameter(Mandatory = $true)]
        [string]$SOVID,

        # Add all optional parameters, must include type
        [string]$code,
        [string]$name,
        [int]$quantity,
        [decimal]$unitPrice,
        [string]$unit,
        $amount,
        [string]$lockedField,
        [int]$quantityPerBulk,
        $exchangeRate
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/schedule-of-values/$($SOVID)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Add query string parameters
    # if ($force) { $Body["force"] = $force }

    # Initialize all optional parameters
    if ($code) { $Body["code"] = $code }
    if ($name) { $Body["name"] = $name }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($amount) { $Body["amount"] = $amount }
    if ($lockedField) { $Body["lockedField"] = $lockedField }
    if ($quantityPerBulk) { $Body["quantityPerBulk"] = $quantityPerBulk }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}