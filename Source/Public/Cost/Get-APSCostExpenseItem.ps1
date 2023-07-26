
<#
.SYNOPSIS
Retrieves the expense items and subitems of the specified expenses for a given project.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER expenseId
The unique ID of the expense to which the expense item belongs. You can obtain this ID from the response to the POST expenses or GET expenses endpoint.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER id
Return only the items that are identified by the provided list of item IDs. Separate multiple IDs with commas.

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER include
A list of the nested expense resources to include in the response with the expense items.
Possible values: budget, contract, attributes.

.PARAMETER offset
The number of objects resulting from this request to skip before returning a page of records. To return the subsequent page, increment this number by the value of limit in the next request.
NOTE: Usually not needed/not functional due to iterating through pagination.

.PARAMETER limit
The maximum number of records that this endpoint may return per page.

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.EXAMPLE
$(Get-APSCostExpenseItem -ProjectID $ProjectID -expenseId $expense)[0] | Out-Gridview

Obtains a DT containing a list of all Expense Items under $expense, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-expenseId-items-GET/
#>
function Get-APSCostExpenseItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [Parameter(Mandatory = $true)]
        $expenseId,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "budgetId", "contractId", "number", "name", "description",
            "note", "tax", "scope", "quantity", "unitPrice", "unit", "amount", "aggregateBy", "exchangeRate",
            "originalExchangeRate", "realizedGainOrLoss", "externalId", "externalSystem", "externalMessage",
            "lastSyncTime", "createdAt", "updatedAt"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $id,
        $lastModifiedSince,

        # Other optional params
        $include,
        $offset,
        $limit,
        $sort
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $CostExpenseItemArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $CostExpenseItemUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses/$expenseId/items"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($id) { $Body["filter[id]"] = $id }
    if ($lastModifiedSince) { $Body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($include) { $Body["include"] = $include }
    if ($offset) { $Body["offset"] = $offset }
    if ($limit) { $Body["limit"] = $limit }
    if ($sort) { $Body["sort"] = $sort }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialCostExpenseItem = Invoke-Restmethod -Method GET -Uri $CostExpenseItemUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $CostExpenseItemArray = [System.Collections.ArrayList]::new()
    [void]$CostExpenseItemArray.Add($initialCostExpenseItem.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempCostExpenseItem = $initialCostExpenseItem
    while (![string]::IsNullOrWhiteSpace($tempCostExpenseItem.pagination.nextUrl)) {
        $tempCostExpenseItem = Invoke-Restmethod -Method GET -Uri $tempCostExpenseItem.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$CostExpenseItemArray.Add($tempCostExpenseItem.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $CostExpenseItemArray
    [System.Data.DataTable]$CostExpenseItemTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the CostExpenseItemArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($CostExpenseItemPage in $CostExpenseItemArray) {
        # Iterate through the pages of the ArrayList
        foreach ($CostExpenseItem in $CostExpenseItemPage) {
            # Iterate through each individual CostExpenseItem and create rows
            $row = $CostExpenseItemTable.NewRow()
            foreach ($column in $CostExpenseItemTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $CostExpenseItem.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $CostExpenseItemTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CostExpenseItemTable
}


