
<#
.SYNOPSIS
Updates an expense item in the specified expense of a given project.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER expenseId
The unique ID of the expense to which the expense item belongs. You can obtain this ID from the response to the POST expenses or GET expenses endpoint.

.PARAMETER itemId
The object ID of the expense item.

.PARAMETER name
The name of the item.

.PARAMETER budgetId
The ID of the budget to which the expense item belongs.

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

.PARAMETER lockedField
The expense item field to lock if you’re recalculating the item’s price.

.PARAMETER aggregateBy
The aggregate type of the expense item. Possible values: workCompleted, workCompletedQty, materialsOnSite

.PARAMETER exchangeRate
The exchange rate that applies to the expense item’s base currency price. For example, provide the value 0.7455 for a foreign currency that’s worth 0.7455 of your base currency. Default:1. It’s also 1 if multi-currency is not enabled.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalMessage
A message that explains the sync status of the ERP integration with the BIM 360 Cost module.

.EXAMPLE
Edit-APSCostExpenseItem -ProjectID $ProjectID -expenseId $expense -itemId $item -description "DESC2"

Edits the description of $item under $expense to be "DESC2"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-expenseId-items-id-PATCH/
#>
function Edit-APSCostExpenseItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [Parameter(Mandatory = $true)]
        $expenseId,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$itemId,

        # Add all optional parameters, must include type
        [string]$name,
        [string]$budgetId,
        [string]$description,
        [string]$note,
        $tax,
        [string]$scope,
        $quantity,
        $unitPrice,
        [string]$unit,
        $amount,
        $lockedField,
        [string]$aggregateBy,
        $exchangeRate,
        [string]$externalId,
        [string]$externalSystem,
        [string]$externalMessage
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses/$expenseId/items/$itemId"

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Initialize all optional parameters
    if ($name) { $Body["name"] = $name }
    if ($budgetId) { $Body["budgetId"] = $budgetId }
    if ($description) { $Body["description"] = $description }
    if ($note) { $Body["note"] = $note }
    if ($tax) { $Body["tax"] = $tax }
    if ($scope) { $Body["scope"] = $scope }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($amount) { $Body["amount"] = $amount }
    if ($lockedField) { $Body["lockedField"] = $lockedField }
    if ($aggregateBy) { $Body["aggregateBy"] = $aggregateBy }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }
    if ($externalId) { $Body["externalId"] = $externalId }
    if ($externalSystem) { $Body["externalSystem"] = $externalSystem }
    if ($externalMessage) { $Body["externalMessage"] = $externalMessage }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}