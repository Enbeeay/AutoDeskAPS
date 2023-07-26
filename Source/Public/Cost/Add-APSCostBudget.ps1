
<#
.SYNOPSIS
Creates a budget in the specified project.

.DESCRIPTION
Sends a POST request to the APS API to create a budget with the specified info in the given project.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER code
Unique code compliant with the budget code template defined by the project admin.

.PARAMETER name
Name of the budget.

.PARAMETER force
This request forces an override of locked budgeting so the request can succeed.

.PARAMETER parentId
ID of the parent budget, used only when creating sub budgets.

.PARAMETER quantity
The quantity of labor, material, and other items planned for the budget.

.PARAMETER inputQuantity
The input quantity planned for the budget.

.PARAMETER description
Detail description of the budget.

.PARAMETER unitPrice
Unit price of a budget.

.PARAMETER unit
Unit of measures used in the budget.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalMessage
A message that explains the sync status of the ERP integration with the BIM 360 Cost module.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.PARAMETER properties
Undocumented parameter only available in budget creation (otherwise, must use Edit-APSCostAttribute) that allows for the setting of properties. Expects Hashtable.

.EXAMPLE
Add-APSCostBudget -ProjectID $ProjectID -code "TEST" -name "TNAME" -properties @(@{"name" = "Cost_Type"; "value" = "TTYPE" })

Adds a budget with code "TEST", name "TNAME", and with the Cost_Type property set to "TTYPE" to the project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-budgets-POST/
#>
function Add-APSCostBudget {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$code,
        [Parameter(Mandatory = $true)]
        [string]$name,

        # Query String Parameters
        $force,

        # Optional parameters
        [string]$parentId,
        [int]$quantity,
        [int]$inputQuantity,
        [string]$description,
        $unitPrice,
        [string]$unit,
        [string]$externalId,
        [string]$externalSystem,
        [string]$externalMessage,
        [string]$integrationState,

        # Have to pass in an array of hash tables, such as:
        #       [{"name":"Job_Number","value":"[INSERT]"},
        #       {"name":"Cost_Type","value":"[INSERT]"}]
        $properties
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()


    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/budgets"

    # Pad the code to 20 characters to work with POST
    $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the mandatory Body of the POST request
    $Body = @{"code" = $code; "name" = $name }

    # Add query string parameters
    if ($force) { $Body["force"] = $force }

    # Initialize all optional parameters
    if ($parentId) { $Body["parentId"] = $parentId }
    if ($quantity) { $Body["quantity"] = $quantity }
    if ($inputQuantity) { $Body["inputQuantity"] = $inputQuantity }
    if ($description) { $Body["description"] = $description }
    if ($unitPrice) { $Body["unitPrice"] = $unitPrice }
    if ($unit) { $Body["unit"] = $unit }
    if ($externalId) { $Body["externalId"] = $externalId }
    if ($externalSystem) { $Body["externalSystem"] = $externalSystem }
    if ($externalMessage) { $Body["externalMessage"] = $externalMessage }
    if ($integrationState) { $Body["integrationState"] = $integrationState }
    if ($properties) { $Body["properties"] = $properties }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}