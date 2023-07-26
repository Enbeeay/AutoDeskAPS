
<#
.SYNOPSIS
Updates a budget.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER BudgetID
The budget ID.

.PARAMETER force
This request forces an override of locking so the request can succeed.

.PARAMETER code
Unique code compliant with the budget code template defined by the project admin.

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER quantity
Unique code compliant with the budget code template defined by the project admin.

.PARAMETER inputQuantity
The input quantity planned for the budget.

.PARAMETER unitPrice
Unit price of a budget.

.PARAMETER unit
Unit of measures used in the budget.

.PARAMETER actualQuantity
Actual quantity of labor, material, etc. planned for a budget.

.PARAMETER actualUnitPrice
Actual unit price of a budget.

.PARAMETER actualCost
Total amount of actual cost of the budget.

.PARAMETER lockedField
The locked budget item field. You can lock the budget item’s amount (originalAmount), quantity (quantity), or unit cost (unitPrice) when calculating a budget.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Add-APSCostBudget -ProjectID $ProjectID -code "CCCC2222" -name "Budgets for SOVs" -quantity "10"

Adds a budget with the code "CCCC2222" and given parameters to the project $ProjectID.

.NOTES
Code is automatically padded to 20 characters to allow for variable length codes without inconvenience of code segments.
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-budgets-budgetId-PATCH/
#>

function Edit-APSCostBudget {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$BudgetID,


        # Query String Parameters
        $force,

        # Optional parameters
        [string]$code,
        [string]$name,
        [string]$description,
        [int]$quantity,
        [int]$inputQuantity,
        $unitPrice,
        [string]$unit,
        [int]$actualQuantity,
        $actualUnitPrice,
        $actualCost,
        [string]$lockedField,
        [string]$integrationState

        # NOTE: Use Edit-APSCostAttribute to change property values
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/budgets/$($BudgetID)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    if ($code) { $code = $code.PadRight(20) }

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Add query string parameters
    if ($force) { $Body["force"] = $force }

    # Initialize all optional parameters
    if ($code) { $Body["code"] = $code }
    if ($name) { $Body["name"] = $name }
    if ($description) { $Body["description"] = $description }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($inputQuantity) { $Body["inputQuantity"] = $inputQuantity }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($actualQuantity) { $Body["actualQuantity"] = $actualQuantity }
    if ($actualUnitPrice) { $Body["actualUnitPrice"] = $actualUnitPrice }
    if ($actualCost) { $Body["actualCost"] = $actualCost }
    if ($lockedField) { $Body["lockedField"] = $lockedField }
    if ($integrationState) { $Body["integrationState"] = $integrationState }
    if ($properties) { $Body["properties"] = $properties }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}