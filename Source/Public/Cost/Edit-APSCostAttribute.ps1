
<#
.SYNOPSIS
Updates the existing values of multi custom attributes associated with an item such as a cost item, PCO, and so on.

.DESCRIPTION
Sends a POST request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.PARAMETER propertyDefinitionId
ID of the custom attribute definition.

.PARAMETER value
Value of the custom attribute associated to an item.

.EXAMPLE
Edit-APSCostAttribute -ProjectID $ProjectID -associationId $budgetId -associationType "Budget" -propertyDefinitionId $property -value "1000"

Edits the custom property $property (obtained through Get-APSCostAttribute) for the budget $budgetId in the project $ProjectID to the value "1000"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-property-valuesbatch-update-POST/
#>
function Edit-APSCostAttribute {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$associationId, # ID of Object
        [Parameter(Mandatory = $true)]
        [string]$associationType, # Type of Object (i.e. Budget)
        [Parameter(Mandatory = $true)]
        [string]$propertyDefinitionId, # ID of Property, obtained through Get-APSCostAttribute and filters

        # Is basically mandatory, but defaults to null
        $value
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/property-values:batch-update"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType
    $Body["propertyDefinitionId"] = $propertyDefinitionId
    if ($value) { $Body["value"] = $value } else { $Body["value"] = $null }

    # Convert the hashtable into JSON
    $Body = @($Body)
    $Body = ConvertTo-Json -InputObject $Body

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}