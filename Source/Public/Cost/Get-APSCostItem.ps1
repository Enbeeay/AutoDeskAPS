
<#
.SYNOPSIS
Retrieves the expense items and subitems of the specified expenses for a given project.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER scope
The scope of the cost item, usually by change order type. Possible values: rfq, sco, pco, rco, oco

.PARAMETER id
Return only the items that are identified by the provided list of item IDs. Separate multiple IDs with commas.

.PARAMETER number
Return only the items that are identified by the provided list of auto-generated sequence numbers.

.PARAMETER changeOrderId
The change order ID. Separate multiple IDs with commas.

.PARAMETER budgetId
The ID of the budget. Separate multiple IDs with commas

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER contractId
Return only items associated with the contracts identified on this list of IDs. Separate multiple IDs with commas.

.PARAMETER budgetStatus
Return only the items that are linked to budgets that have the specified status codes. Separate multiple codes with commas.

.PARAMETER costStatus
Return only the items that have the specified status codes. Separate multiple codes with commas.

.PARAMETER offset
The number of objects resulting from this request to skip before returning a page of records. To return the subsequent page, increment this number by the value of limit in the next request.
NOTE: Usually not needed/not functional due to iterating through pagination.

.PARAMETER limit
The maximum number of records that this endpoint may return per page.

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.PARAMETER include
A list of resources related to the returned cost items to include in the response.
Possible values: budget, changeOrders, subCostItems, attributes.

.EXAMPLE
$(Get-APSCostCostItem -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all Cost Items in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-cost-items-GET/
#>
function Get-APSCostItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "number", "name", "description",
            "budgetStatus", "costStatus", "scope", "type", "isMarkup", "estimated",
            "proposed", "submitted", "approved", "committed", "inputQuantity", "quantity",
            "unit", "scopeOfWork", "note", "proposedExchangeRate", "committedExchangeRate",
            "locations", "locationPaths", "integrationState", "integrationStateChangedAt",
            "integrationStateChangedBy", "createdAt", "updatedAt"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        [string]$scope,
        [string[]]$id,
        [string[]]$number,
        [string[]]$changeOrderId,
        [string[]]$budgetId,
        [string[]]$externalSystem,
        [string[]]$externalId,
        [datetime]$lastModifiedSince,
        [string[]]$contractId,
        [string[]]$budgetStatus,
        [string[]]$costStatus,
        [int]$offset,
        [int]$limit,
        [string]$sort,
        [string[]]$include
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $CostItemArray
    $CostItemUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/cost-items"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    if ($limit) { $Body = @{ "limit" = $limit } } else { $Body = @{ "limit" = "200" } }

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($id) { $Body["filter[id]"] = $id }
    if ($number) { $Body["filter[number]"] = $number }
    if ($changeOrderId) { $Body["filter[changeOrderId]"] = $changeOrderId }
    if ($budgetId) { $Body["filter[budgetId]"] = $budgetId }
    if ($externalSystem) { $Body["filter[externalSystem]"] = $externalSystem }
    if ($externalId) { $Body["filter[externalId]"] = $externalId }
    if ($lastModifiedSince) { $Body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($contractId) { $Body["filter[contractId]"] = $contractId }
    if ($budgetStatus) { $Body["filter[budgetStatus]"] = $budgetStatus }
    if ($costStatus) { $Body["filter[costStatus]"] = $costStatus }
    if ($offset) { $Body["offset"] = $offset }
    if ($sort) { $Body["sort"] = $sort }
    if ($include) { $Body["include"] = $include }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialCostItem = Invoke-Restmethod -Method GET -Uri $CostItemUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $CostItemArray = [System.Collections.ArrayList]::new()
    [void]$CostItemArray.Add($initialCostItem.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempCostItem = $initialCostItem
    while (![string]::IsNullOrWhiteSpace($tempCostItem.pagination.nextUrl)) {
        $tempCostItem = Invoke-Restmethod -Method GET -Uri $tempCostItem.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$CostItemArray.Add($tempCostItem.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $CostItemArray
    [System.Data.DataTable]$CostItemTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the CostItemArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($CostItemPage in $CostItemArray) {
        # Iterate through the pages of the ArrayList
        foreach ($CostItem in $CostItemPage) {
            # Iterate through each individual CostItem and create rows
            $row = $CostItemTable.NewRow()
            foreach ($column in $CostItemTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $CostItem.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $CostItemTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CostItemTable
}


