
<#
.SYNOPSIS
Updates the specified change order.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given change order.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER COType
The current change order type. Possible values: pco, rfq, rco, oco, sco.

.PARAMETER id
The change order ID.

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER type
The type of the change order. It is customizable by the project admin.

.PARAMETER scope
The scope of the change order. Possible values are out, in, tbd, budgetOnly and contingency.

.PARAMETER ownerId
The user who is responsible for the purchase. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER scopeOfWork
Scope of work of the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER note
Additional notes to the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER exchangeRate
A new currency exchange rate for the change order. Note that:
If the changeOrder parameter value is rfq, this value updates the proposed exchange rate for all cost items under this RFQ.
If the changeOrder parameter value is sco, this value updates the committed exchange rate for all cost items under this SCO.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Edit-APSCostChangeOrder -ProjectID $ProjectID -COType 'pco' -ID $CO -name "Test Patch CO"

Edits the name field of the given change order $CO to the provided value.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-change-orders-changeOrder-id-PATCH/
#>
function Edit-APSCostChangeOrder {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Alias("changeOrder")]
        [Parameter(Mandatory = $true)]
        [string]$COType,
        [Parameter(Mandatory = $true)]
        [string]$id,

        # Add all optional parameters, must include type
        [string]$name,
        [string]$description,
        [string]$type,
        [string]$scope,
        [string]$ownerId,
        [string]$scopeOfWork,
        [string]$note,
        [string]$exchangeRate,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/change-orders/$($COType)/$($id)"

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
    if ($name) { $Body["name"] = $name }
    if ($description) { $Body["description"] = $description }
    if ($type) { $Body["type"] = $type }
    if ($scope) { $Body["scope"] = $scope }
    if ($ownerId) { $Body["ownerId"] = $ownerId }
    if ($scopeOfWork) { $Body["scopeOfWork"] = $scopeOfWork }
    if ($note) { $Body["note"] = $note }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}