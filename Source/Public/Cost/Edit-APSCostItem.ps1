
<#
.SYNOPSIS
Updates an existing cost item

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER costItemId
ID of the cost item.

.PARAMETER scope
The scope of the cost item, usually by change order type. Possible values: rfq, sco, pco, rco, oco

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER type
The type of the cost item. It is customizable by the project admin.

.PARAMETER estimated
Rough estimation of this item without a quotation.

.PARAMETER proposed
Quoted cost of the cost item.

.PARAMETER submitted
Amount sent to the owner for approval.

.PARAMETER approved
Amount approved by the owner.

.PARAMETER committed
Amount committed to the supplier.

.PARAMETER inputQuantity
The input quantity of the cost item.

.PARAMETER quantity
The quantity of the cost item.

.PARAMETER unit
The unit of the cost item.

.PARAMETER budgetId
The ID of the budget that the cost item is linked to.

.PARAMETER contractId
The ID of the contract that the cost item is linked to.

.PARAMETER proposedExchangeRate
The exchange rate for the proposed cost. If multi-currency is not enabled, this value is set to 1 regardless of what you specify here. Default value is 1.

.PARAMETER committedExchangeRate
The exchange rate for the committed cost. If multi-currency is not enabled, this value is set to 1 regardless of what you specify here. Default value is 1.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Edit-APSCostItem -ProjectID $ProjectID -costItemId $item -name "Patch"

Edits the name of the Cost Item $item to "Patch"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-cost-items-costItemId-PATCH/

#>
function Edit-APSCostItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$costItemId,

        # Add all optional parameters, must include type
        [string]$scope,
        [string]$name,
        [string]$description,
        [string]$type,
        $estimated,
        $proposed,
        $submitted,
        $approved,
        $committed,
        [int]$inputQuantity,
        [int]$quantity,
        [string]$unit,
        [string]$budgetId,
        [string]$contractId,
        $proposedExchangeRate,
        $committedExchangeRate,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/cost-items/$($costItemId)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Add query string parameters
    if ($scope) { $Body["scope"] = $scope }

    # Initialize all optional parameters
    if ($name) { $Body["name"] = $name }
    if ($description) { $Body["description"] = $description }
    if ($type) { $Body["type"] = $type }
    if ($estimated) { $Body["estimated"] = $estimated }
    if ($proposed) { $Body["proposed"] = $proposed }
    if ($submitted) { $Body["submitted"] = $submitted }
    if ($approved) { $Body["approved"] = $approved }
    if ($committed) { $Body["committed"] = $committed }
    if ($inputQuantity) { $Body["inputQuantity"] = $inputQuantity }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unit) { $Body["unit"] = $unit }
    if ($budgetId) { $Body["budgetId"] = $budgetId }
    if ($contractId) { $Body["contractId"] = $contractId }
    if ($proposedExchangeRate) { $Body["proposedExchangeRate"] = $proposedExchangeRate }
    if ($committedExchangeRate) { $Body["committedExchangeRate"] = $committedExchangeRate }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}