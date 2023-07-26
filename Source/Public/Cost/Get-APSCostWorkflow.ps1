
<#
.SYNOPSIS
List the current workflow that can execute on the specified item according to the item’s current state.

.DESCRIPTION
Sends a GET request to the APS API and returns response directly as JSON.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.EXAMPLE
Get-APSCostWorkflow -ProjectID $ProjectID -associationId $budget -associationType "Budget"

Returns the response containing a list of all Workflows related to $budget.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-workflows-GET/
#>
function Get-APSCostWorkflow {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        # Other Mandatory Params
        [Parameter(Mandatory = $true)]
        $associationId,
        [Parameter(Mandatory = $true)]
        $associationType
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $WorkflowArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $WorkflowUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/workflows"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Initialize all mandatory parameters
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    Invoke-Restmethod -Method GET -Uri $WorkflowUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body
}


