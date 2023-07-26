
<#
.SYNOPSIS
Lists all the attribute definitions created to define custom attributes for a given module.

.DESCRIPTION
Sends a GET request to the APS API and returns the response directly.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER name
The name of the item.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values: Budget, Contract, CostItem, FormDefinition, CostPayment, BudgetPayment, Expense, ExpenseItem.

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.PARAMETER limit
The maximum number of records that this endpoint may return per page.

.EXAMPLE
Get-APSCostAttribute -ProjectID $ProjectID -associationType "Budget"

Directly returns the response containing a list of all attributes related to Budgets.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-properties-GET/

#>
function Get-APSCostAttribute {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $name,
        $associationId,
        $associationType,
        $lastModifiedSince,
        $sort,
        $limit
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Sets URL
    $AttributeInfoUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/properties"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($name) { $Body["filter[name]"] = $name }
    if ($associationId) { $Body["filter[associationId]"] = $associationId }
    if ($associationType) { $Body["filter[associationType]"] = $associationType }
    if ($lastModifiedSince) { $Body["lastModifiedSince"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($sort) { $Body["sort"] = $sort }
    if ($limit) { $Body["limit"] = $limit }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field
    Invoke-Restmethod -Method GET -Uri $AttributeInfoUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body
}


