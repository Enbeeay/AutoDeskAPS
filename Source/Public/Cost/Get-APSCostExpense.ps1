
<#
.SYNOPSIS
Retrieves the requested set of expenses in the specified project.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER id
Return only the items that are identified by the provided list of item IDs. Separate multiple IDs with commas.

.PARAMETER number
The auto-generated sequence number for the expense.

.PARAMETER status
Return only items with the specified statuses. Separate multiple values with commas.

.PARAMETER mainContractId
The ID of the main contract with which this item is associated.

.PARAMETER budgetPaymentId
ID of the Budget Pay App to which the expense belongs.

.PARAMETER createdAt
Filter data by its create date (Must be in ISO 8601 format).

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER include
A list of the nested expense resources to include in the response with the expenses. Possible values: expenseItems, mainContract, attributes.

.PARAMETER offset
The number of objects resulting from this request to skip before returning a page of records.
To return the subsequent page, increment this number by the value of limit in the next request.
NOTE: Usually not needed/not functional due to iterating through pagination.

.PARAMETER limit
The maximum number of records that this endpoint may return per page.

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.EXAMPLE
$(Get-APSCostExpense -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all Expenses in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-GET/

#>
function Get-APSCostExpense {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "supplierId", "supplierName", "mainContractId", "budgetPaymentId",
            "number", "name", "description", "note", "term", "referenceNumber", "type", "scope", "creatorId",
            "changedBy", "purchasedBy", "status", "amount", "paymentDue", "issuedAt", "receivedAt", "approvedAt",
            "paidAt", "forecastDistributionAt", "paymentType", "paymentReference", "externalId", "externalSystem",
            "externalMessage", "lastSyncTime", "integrationState", "integrationStateChangedAt",
            "integrationStateChangedBy", "createdAt", "updatedAt"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $id,
        $number,
        $status,
        $mainContractId,
        $budgetPaymentId,
        $createdAt,
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

    # Retrieve data from API, put into $CostExpenseArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $CostExpenseUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($id) { $Body["filter[id]"] = $id }
    if ($number) { $Body["filter[number]"] = $number }
    if ($number) { $Body["filter[number]"] = $number }
    if ($status) { $Body["filter[status]"] = $status }
    if ($mainContractId) { $Body["filter[mainContractId]"] = $mainContractId }
    if ($budgetPaymentId) { $Body["filter[budgetPaymentId]"] = $budgetPaymentId }
    if ($createdAt) { $Body["filter[createdAt]"] = ([datetime]$createdAt).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($lastModifiedSince) { $Body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($include) { $Body["include"] = $include }
    if ($offset) { $Body["offset"] = $offset }
    if ($limit) { $Body["limit"] = $limit }
    if ($sort) { $Body["sort"] = $sort }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialCostExpense = Invoke-Restmethod -Method GET -Uri $CostExpenseUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $CostExpenseArray = [System.Collections.ArrayList]::new()
    [void]$CostExpenseArray.Add($initialCostExpense.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempCostExpense = $initialCostExpense
    while (![string]::IsNullOrWhiteSpace($tempCostExpense.pagination.nextUrl)) {
        $tempCostExpense = Invoke-Restmethod -Method GET -Uri $tempCostExpense.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$CostExpenseArray.Add($tempCostExpense.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $CostExpenseArray
    [System.Data.DataTable]$CostExpenseTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the CostExpenseArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($CostExpensePage in $CostExpenseArray) {
        # Iterate through the pages of the ArrayList
        foreach ($CostExpense in $CostExpensePage) {
            # Iterate through each individual CostExpense and create rows
            $row = $CostExpenseTable.NewRow()
            foreach ($column in $CostExpenseTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $CostExpense.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $CostExpenseTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CostExpenseTable
}


