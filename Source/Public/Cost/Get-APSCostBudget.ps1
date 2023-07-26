
<#
.SYNOPSIS
Returns all the budgets in a specific project.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER rootId
Query related sub-items for the given root item ID. Separate multiple IDs with commas.

.PARAMETER id
Return only the items that are identified by the provided list of item IDs. Separate multiple IDs with commas.

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER code
Return only items that are identified by the specified codes (separated by commas).

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.EXAMPLE
$(Get-APSCostBudget -ProjectID $ProjectID)[0] | Out-Gridview

Outputs a DT of all budgets in the project in a gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-budgets-GET/
#>
function Get-APSCostBudget {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        [string[]] $DesiredColumns = ("id", "parentId", "code", "scope", "subItems", "budgetCode", "budgetCodeId", "name", "description", "quantity", "inputQuantity",
            "ratio", "unitPrice", "unit", "originalAmount", "milestoneId", "internalAdjustment", "approvedOwnerChanges", "pendingOwnerChanges", "originalCommitment",
            "approvedChangeOrders", "approvedInScopeChangeOrders", "pendingChangeOrders", "reserves", "actualQuantity", "actualUnitPrice", "actualCost", "mainContractId",
            "locations", "locationPaths", "plannedStartDate", "plannedEndDate", "actualStartDate", "actualEndDate", "durationDays", "uncommitted", "revised", "projectedCost",
            "projectedBudget", "forecastFinalCost", "forecastVariance", "forecastCostComplete", "varianceTotal", "externalId", "externalSystem", "externalMessage", "lastSyncTime",
            "integrationState", "integrationStateChangedAt", "integrationStateChangedBy", "createdAt", "updatedAt"),

        <# SQL Naming - Not Being Used
        [string[]] $DesiredColumns = ("ProjectID", "BudgetID", "ParentID", "BudgetName", "Code", "Scope", "Description", "BudgetCode", "SubItems",
         "QuantityOfLabor", "InputQuantity", "Ratio", "UnitPrice", "Unit", "OriginalAmount", "MilestoneId", "InternalAdjustment",
        "ApprovedOwnerChanges", "PendingOwnerChanges", "OriginalCommitment", "ApprovedChangeOrders", "ApprovedInScopeChangeOrders", "PendingChangeOrders", "Reserves", "ActualQuantity", "ActualUnitPrice", "ActualCost",
        "MainContractId", "Locations", "LocationPaths", "Uncommited", "Revised", "ProjectedCost", "ProjectedBudget", "ForecastFinalCost", "ForecastVariance", "ForecastCostComplete", "VarianceTotal",
        "ExternalId", "ExternalSystem", "ExternalMessage", "LastSyncTime", "IntegrationState", "IntegrationStateChangedAt", "IntegrationStateChangedBy", "CreatedAt", "UpdatedAt" ),#>
        $rootId,
        $id,
        $lastModifiedSince,
        $externalSystem,
        $externalId,
        $code,
        $sort
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $BudgetArray
    $BudgetUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/budgets"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = 200 }

    if ($rootId) { $Body["filter[rootId]"] = $rootId }
    if ($id) { $Body["filter[id]"] = $id }
    if ($lastModifiedSince) { $Body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($externalSystem) { $Body["filter[externalSystem]"] = $externalSystem }
    if ($externalId) { $Body["filter[externalId]"] = $externalId }
    if ($code) { $Body["filter[code]"] = $optionalParam4 }
    if ($sort) { $Body["sort"] = $sort }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialBudget = Invoke-Restmethod -Method GET -Uri $BudgetUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $BudgetArray = [System.Collections.ArrayList]::new()
    [void]$BudgetArray.Add($initialBudget.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempBudget = $initialBudget
    while (![string]::IsNullOrWhiteSpace($tempBudget.pagination.nextUrl)) {
        $tempBudget = Invoke-Restmethod -Method GET -Uri $tempBudget.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$BudgetArray.Add($tempBudget.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $BudgetArray
    [System.Data.DataTable]$BudgetTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the BudgetArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($BudgetPage in $BudgetArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Budget in $BudgetPage) {
            # Iterate through each individual Budget and create rows
            $row = $BudgetTable.NewRow()
            foreach ($column in $BudgetTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Budget.$column
            }

            <#
            $row["projectId"] = $budget.containerid
            $row["budgetId"] = $budget.id
            $row["budgetName"] = $budget.name
            $row["quantityOfLabor"] = $budget.quantity#>

            $BudgetTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the comma
    Write-Output -NoEnumerate $BudgetTable

}


