
<#
.SYNOPSIS
Retrieves one or more schedule of values (SOV) items in the given project.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER BudgetID
The ID of the budget. Separate multiple IDs with commas.

.PARAMETER ContractID
Return only items associated with the contracts identified on this list of IDs. Separate multiple IDs with commas.

.PARAMETER IncludeChangeOrders
true if you need all sovs. false filter items which are sco. Lowercase only.

.PARAMETER Sort
The sort order for items. Each attribute can be sorted in either asc (default) or desc order.

.EXAMPLE
$(Get-APSCostScheduleOfValues -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all SOVs in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-schedule-of-values-GET/
#>
function Get-APSCostScheduleOfValues {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "parentId", "contractId", "budgetId", "code", "name", "quantity", "unitPrice", "unit",
            "amount", "allocatedAmount", "quantityPerBulk", "bulkUnitPrice", "bulk", "associationId", "associationType", "exchangeRate", "createdAt", "updatedAt"),

        <# SQL Naming - Not Being Used
        [string[]] $DesiredColumns = ("ProjectID", "ContractID", "SOVID", "BudgetID", "ParentID", "SOVName", "Code", "Quantity", "UnitPrice",
        "Unit", "Amount", "AllocatedAmount", "QuantityPerBulk", "BulkUnitPrice", "Bulk", "AssociationID", "AssociationType", "ExchangeRate", "CreatedAt", "UpdatedAt"),#>
        $BudgetID,
        $ContractID,
        $IncludeChangeOrders,
        $Sort
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $ScheduleOfValuesArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $ScheduleOfValuesUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/schedule-of-values"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = 100 }
    if ($BudgetID) { $Body["filter[BudgetID]"] = $BudgetID }
    if ($ContractID) { $Body["filter[ContractID]"] = $ContractID }
    if ($IncludeChangeOrders) { $Body["filter[IncludeChangeOrders]"] = $IncludeChangeOrders }
    if ($Sort) { $Body["sort"] = $Sort }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialScheduleOfValues = Invoke-Restmethod -Method GET -Uri $ScheduleOfValuesUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $ScheduleOfValuesArray = [System.Collections.ArrayList]::new()
    [void]$ScheduleOfValuesArray.Add($initialScheduleOfValues.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempScheduleOfValues = $initialScheduleOfValues
    while (![string]::IsNullOrWhiteSpace($tempScheduleOfValues.pagination.nextUrl)) {
        $tempScheduleOfValues = Invoke-Restmethod -Method GET -Uri $tempScheduleOfValues.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$ScheduleOfValuesArray.Add($tempScheduleOfValues.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $ScheduleOfValuesArray
    [System.Data.DataTable]$ScheduleOfValuesTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the ScheduleOfValuesArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($ScheduleOfValuesPage in $ScheduleOfValuesArray) {
        # Iterate through the pages of the ArrayList
        foreach ($ScheduleOfValues in $ScheduleOfValuesPage) {
            # Iterate through each individual ScheduleOfValues and create rows
            $row = $ScheduleOfValuesTable.NewRow()
            foreach ($column in $ScheduleOfValuesTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $ScheduleOfValues.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id
            #$row["ProjectID"] = $ScheduleOfValues.containerid
            #$row["SOVID"] = $ScheduleOfValues.id
            #$row["SOVName"] = $ScheduleOfValues.name

            # Add populated row to the datatable
            $ScheduleOfValuesTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $ScheduleOfValuesTable
}


