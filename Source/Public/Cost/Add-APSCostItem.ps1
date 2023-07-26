
<#
.SYNOPSIS
Creates a new cost item in the specified project.

.DESCRIPTION
Sends a POST request to the APS API to create a cost item with the given parameters in the specified project

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER name
The name of the item.

.PARAMETER scope
The scope of the cost item, usually by change order type. Possible values: rfq, sco, pco, rco, oco

.PARAMETER changeOrderId
The ID of the change order that the cost item is created in.

.PARAMETER description
A detailed description of the item.

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

.PARAMETER proposedExchangeRate
The exchange rate for the proposed cost. If multi-currency is not enabled, this value is set to 1 regardless of what you specify here. Default value is 1.

.PARAMETER committedExchangeRate
The exchange rate for the committed cost. If multi-currency is not enabled, this value is set to 1 regardless of what you specify here. Default value is 1.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Add-APSCostItem -ProjectID $ProjectID -name "TEST"

Adds a cost item with the name "TEST" to the project $ProjectID

.EXAMPLE
Add-APSCostItem -ProjectID $ProjectID -name "TEST" -changeOrderId $CO

Adds a cost item with the name "TEST" to the project $ProjectID under the change order $CO

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-cost-items-POST/
#>
function Add-APSCostItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$name,

        # Add all optional parameters, must include type
        [string]$scope,
        [string]$changeOrderId,
        [string]$description,
        $estimated,
        $proposed,
        $submitted,
        $approved,
        $committed,
        [int]$inputQuantity,
        [int]$quantity,
        [string]$unit,
        [string]$budgetId,
        $proposedExchangeRate,
        $committedExchangeRate,
        [string]$integrationState
    )


    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/cost-items"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget POST
    # $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Add query string parameters
    if ($scope) { $Body["scope"] = $scope }

    # Set all mandatory parameters
    $Body["name"] = $name

    # Initialize all optional parameters
    if ($changeOrderId) { $Body["changeOrderId"] = $changeOrderId }
    if ($description) { $Body["description"] = $description }
    if ($estimated) { $Body["estimated"] = $estimated }
    if ($proposed) { $Body["proposed"] = $proposed }
    if ($submitted) { $Body["submitted"] = $submitted }
    if ($approved) { $Body["approved"] = $approved }
    if ($committed) { $Body["committed"] = $committed }
    if ($inputQuantity) { $Body["inputQuantity"] = $inputQuantity }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unit) { $Body["unit"] = $unit }
    if ($budgetId) { $Body["budgetId"] = $budgetId }
    if ($proposedExchangeRate) { $Body["proposedExchangeRate"] = $proposedExchangeRate }
    if ($committedExchangeRate) { $Body["committedExchangeRate"] = $committedExchangeRate }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}