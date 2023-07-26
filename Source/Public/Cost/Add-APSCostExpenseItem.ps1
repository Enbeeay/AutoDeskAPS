
<#
.SYNOPSIS
Creates an expense item in the specified expense of a given project.

.DESCRIPTION
Sends a POST request to the APS API to create an expense item in the specified expense of a given project.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER expenseId
The unique ID of the expense to which the expense item belongs. You can obtain this ID from the response to the POST expenses or GET expenses endpoint.

.PARAMETER name
The name of the item.

.PARAMETER id
The unique identifier of the expense item.

.PARAMETER budgetId
The ID of the budget to which the expense item belongs.

.PARAMETER budgetCode
The code of an existing budget.

.PARAMETER description
A detailed description of the item.

.PARAMETER note
Additional notes to the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER tax
The total amount of tax that applies to the expense item, in the same currency as the expense item.

.PARAMETER scope
The applicable scope of the expense item. Possible values: full, partial.

.PARAMETER quantity
The number of units of the expense item.

.PARAMETER unitPrice
The price per unit of the expense item.

.PARAMETER unit
The expense item’s unit of measure.

.PARAMETER amount
The total price of the expense item.

.PARAMETER aggregateBy
Not relevant

.PARAMETER exchangeRate
The exchange rate that applies to the expense item’s base currency price. For example, provide the value 0.7455 for a foreign currency that’s worth 0.7455 of your base currency. Default: 1. It’s also 1 if multi-currency is not enabled.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalMessage
A message that explains the sync status of the ERP integration with the BIM 360 Cost module.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Add-APSCostExpenseItem -ProjectID $ProjectID -expenseId $expense -name "POST Item" -description "DESC" -quantity 30

Adds a cost item to the given expense $expense with the provided parameters in the project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-expenseId-items-POST/
#>
function Add-APSCostExpenseItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [Parameter(Mandatory = $true)]
        $expenseId,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$name,

        # Add all optional parameters, must include type
        [string]$id,
        [string]$budgetId,
        [string]$budgetCode,
        [string]$description,
        [string]$note,
        $tax,
        [string]$scope,
        $quantity,
        $unitPrice,
        [string]$unit,
        $amount,
        [string]$aggregateBy,
        $exchangeRate,
        [string]$externalId,
        [string]$externalSystem,
        [string]$externalMessage,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses/$expenseId/items"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget POST
    # $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["name"] = $name

    # Initialize all optional parameters
    if ($id) { $Body["id"] = $id }
    if ($budgetId) { $Body["budgetId"] = $budgetId }
    if ($budgetCode) { $Body["budgetCode"] = $budgetCode }
    if ($description) { $Body["description"] = $description }
    if ($note) { $Body["note"] = $note }
    if ($tax) { $Body["tax"] = $tax }
    if ($scope) { $Body["scope"] = $scope }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($amount) { $Body["amount"] = $amount }
    if ($aggregateBy) { $Body["aggregateBy"] = $aggregateBy }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }
    if ($externalId) { $Body["externalId"] = $externalId }
    if ($externalSystem) { $Body["externalSystem"] = $externalSystem }
    if ($externalMessage) { $Body["externalMessage"] = $externalMessage }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}