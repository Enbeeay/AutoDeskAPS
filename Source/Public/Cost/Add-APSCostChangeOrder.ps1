
<#
.SYNOPSIS
Create a new change order (typically a PCO) to initiate a change.

.DESCRIPTION
Sends a POST request to the APS API to create a change order in the given project.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER COType
The change order type. Possible values: pco, rfq, rco, oco, sco.

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER scope
The scope of the change order. Possible values are out, in, tbd, budgetOnly and contingency.

.PARAMETER scopeOfWork
Scope of work of the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER note
Additional notes to the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalMessage
A message that explains the sync status of the ERP integration with the BIM 360 Cost module.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Add-APSCostChangeOrder -ProjectID $ProjectID -COType 'pco' -name "TEST" -description "CODesc" -scope 'tbd'

Adds a change order of type 'pco' and scope 'tbd' with the given name and description under the project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-change-orders-changeOrder-POST/
#>
function Add-APSCostChangeOrder {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$COType,

        # Add all optional parameters, must include type
        [string]$name,
        [string]$description,
        [string]$scope,
        [string]$scopeOfWork,
        [string]$note,
        [string]$externalId,
        [string]$externalSystem,
        [string]$externalMessage,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/change-orders/$($COType)"

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

    # Initialize all optional parameters
    if ($name) { $Body["name"] = $name }
    if ($description) { $Body["description"] = $description }
    if ($scope) { $Body["scope"] = $scope }
    if ($scopeOfWork) { $Body["scopeOfWork"] = $scopeOfWork }
    if ($note) { $Body["note"] = $note }
    if ($externalId) { $Body["externalId"] = $externalId }
    if ($externalSystem) { $Body["externalSystem"] = $externalSystem }
    if ($externalMessage) { $Body["externalMessage"] = $externalMessage }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}