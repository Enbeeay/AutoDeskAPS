
<#
.SYNOPSIS
List the actions that can execute on the specified item according to the item’s current state.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationType
The type of the item with which the actions are associated. Possible values: Budget, Contract, FormInstance, CostItem, Payment, MainContract, BudgetPayment.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.EXAMPLE
$(Get-APSCostAction -ProjectID $ProjectID -associationType "FormInstance" -associationId $COID)[0] | Out-GridView

Gets a raw DT of possible actions to be performed on the change order $COID, then unravels via indexing and outputs it in a gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-actions-GET/
#>
function Get-APSCostAction {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [Parameter(Mandatory = $true)]
        $associationType,
        [Parameter(Mandatory = $true)]
        $associationId
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $CostActionsUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/workflows/$($associationType)/$($associationId)/actions"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $CostActions = Invoke-Restmethod -Method GET -Uri $CostActionsUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CostActions
    #>
}


