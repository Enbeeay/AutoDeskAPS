
<#
.SYNOPSIS
Create a new actual cost in a specific project.

.DESCRIPTION
Sends a POST request to the APS API to create an Actual Cost with the provided info attached to the given budget.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER budgetId
The ID of the Budget to which the actual cost belongs.

.PARAMETER name
Name of the Actual Cost.

.PARAMETER id
Unique identifier of the actual cost to create.

.PARAMETER contractID
The ID of the Contract to which the actual cost belongs.

.PARAMETER quantity
Quantity of labor, material, etc. planned for a budget.

.PARAMETER unitPrice
Unit price of a budget.

.PARAMETER unit
Unit of measures used in the budget.

.PARAMETER exchangeRate
Exchange rate. Default value is 1, if multi-currency is not enabled, it will also be 1.

.EXAMPLE
Add-APSCostActualCost -ProjectID $ProjectID -budgetId $BudgetID -name "TEMP" -quantity 300

Adds an Actual Cost object with quantity 300 and name "TEMP" to the budget specified by $BudgetId in the project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-actions-POST/
#>
function Add-APSCostActualCost {
    Param(
        [Alias('containerId')]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$budgetId,
        [Parameter(Mandatory = $true)]
        [string]$name,

        # Add all optional parameters, must include type
        [string]$id,
        [string]$contractID,
        [int]$quantity,
        $unitPrice,
        [string]$unit,
        $exchangeRate
    )
    #Autodesk API Documentation - https://aps.autodesk.com/en/docs/bim360/v1/reference/http/cost-actual-costs-POST/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/actual-costs"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget POST
    # $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ 'Authorization' = "Bearer $($PWStateObject.Password)" }
    $Header['Content-Type'] = 'application/json'

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body['budgetId'] = $budgetId
    $Body['name'] = $name

    # Initialize all optional parameters
    if ($id) {
        $Body['id'] = $id 
    }
    if ($contractID) {
        $Body['contractID'] = $contractID 
    }
    if ($quantity) {
        $Body['quantity'] = $quantity 
    }
    if ($unitPrice) {
        $Body['unitPrice'] = $unitPrice 
    }
    if ($unit) {
        $Body['unit'] = $unit 
    }
    if ($exchangeRate) {
        $Body['exchangeRate'] = $exchangeRate 
    }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-RestMethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}