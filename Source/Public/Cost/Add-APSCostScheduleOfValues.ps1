
<#
.SYNOPSIS
Creates a new schedule of values (SOV) item for the given project as a child of an existing SOV item.

.DESCRIPTION
Sends a POST request to the APS API to create a new SOV under an existing root SOV item. Root SOVs are created by linking a contract and budget together via the Join function.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER code
The code of the SOV item.

.PARAMETER name
The name of the item.

.PARAMETER id
The unique ID of this SOV item.

.PARAMETER parentId
The ID of the SOV item’s parent item. For root SOV items, this value is null.

.PARAMETER contractId
The ID of the contract to which the SOV item belongs.

.PARAMETER budgetId
The ID of the budget to which the SOV item belongs.

.PARAMETER quantity
The quantity of the SOV item.

.PARAMETER unitPrice
The unit price of the SOV item.

.PARAMETER unit
The unit of measure of the SOV item.

.PARAMETER amount
The total price of the SOV item.

.PARAMETER quantityPerBulk
The quantity conversion ratio of the SOV item.

.PARAMETER bulkUnitPrice
The unit price of the converted SOV item quantity.

.PARAMETER bulk
The converted quantity of the SOV item.

.PARAMETER exchangeRate
The exchange rate that applies to the SOV item’s base currency price. For example, provide the value 0.7455 for a foreign currency that’s worth 0.7455 of your base currency.

.EXAMPLE
Add-APSCostScheduleOfValues -ProjectID $ProjectID -code "SOV21212" -name "Test SOV" -parentId $rootSOV

Creates an SOV with the given parameters under the root schedule of values $rootSOV in the project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-schedule-of-values-POST/
#>
function Add-APSCostScheduleOfValues {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$code,
        [Parameter(Mandatory = $true)]
        [string]$name,

        # Add all optional parameters, must include type
        [string]$id,
        [string]$parentId,
        [string]$contractId,
        [string]$budgetId,
        [int]$quantity,
        [decimal]$unitPrice,
        [string]$unit,
        $amount,
        [int]$quantityPerBulk,
        [decimal]$bulkUnitPrice,
        [int]$bulk,
        $exchangeRate
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/schedule-of-values"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget POST
    # $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Add query string parameters
    # if ($force) { $Body["force"] = $force }

    # Set all mandatory parameters
    $Body["code"] = $code
    $Body["name"] = $name

    # Initialize all optional parameters
    if ($id) { $Body["id"] = $id }
    #NOTE: Have tried allowing a $null value to be passed regardless, can be done by
    #taking out the if ($parentId) block. Errors out as it does not seem to accept type null.
    if ($parentId) { $Body["parentId"] = $parentId } else { $Body["parentId"] = $null }
    if ($contractId) { $Body["contractId"] = $contractId }
    if ($budgetId) { $Body["budgetId"] = $budgetId }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($amount) { $Body["amount"] = $amount }
    if ($quantityPerBulk) { $Body["quantityPerBulk"] = $quantityPerBulk }
    if ($bulkUnitPrice) { $Body["bulkUnitPrice"] = $bulkUnitPrice }
    if ($bulk) { $Body["bulk"] = $bulk }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}