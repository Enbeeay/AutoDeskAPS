
<#
.SYNOPSIS
Perform a specified action on an item.

.DESCRIPTION
Sends a POST request to the APS API to perform a specified action on a given object.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationId
The ID of the item on which to perform the action. For example, change order ID.

.PARAMETER associationType
The type of the item on which to perform the action. For example, FormInstance for change orders.

.PARAMETER action
Name of the action to perform. The possible actions are from Get-APSCostAction.

.PARAMETER options
Extra data required by the action. Typically in hashtable format.

.EXAMPLE
Add-APSCostAction -ProjectID $ProjectID -associationId $COID -associationType "FormInstance" -action "reject"

Performs the "reject" action on the change order identified by $COID within the project in $ProjectID, thus setting budgetStatus and costStatus to "rejected".

.NOTES
The actions that can be performed on an object depend both on the type and current state of an object, thus one must make sure to use Get-APSCostAction to know the possible actions for a given object.
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-actions-POST/
#>
function Add-APSCostAction {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        $associationId,
        [Parameter(Mandatory = $true)]
        $associationType,
        [Parameter(Mandatory = $true)]
        $action,

        $options
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/workflows/actions"

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

    # Set all mandatory parameters
    $Body["action"] = $action
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType

    # Initialize all optional parameters
    if ($options) { $Body["options"] = $options }

    # Convert the hashtable into JSON
    $Body = @($Body)
    $Body = ConvertTo-Json -InputObject $Body

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}