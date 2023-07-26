
<#
.SYNOPSIS
Retrieves payment items in the given project based on associationId and paymentId.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER offset
The number of objects resulting from this request to skip before returning a page of records. To return the subsequent page, increment this number by the value of limit in the next request.
NOTE: Usually not needed/not functional due to iterating through pagination.

.PARAMETER limit
The maximum number of records that this endpoint may return per page.

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.PARAMETER paymentId
Return only the payment items that are associated with the payments identified by the provided list of payment IDs. Separate multiple IDs with commas.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.EXAMPLE
$(Get-APSCostPaymentItem -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all Payment Items in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-payment-items-GET/
#>
function Get-APSCostPaymentItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("associationType", "billingPeriodId", "associationId", "mainContractId", "budgetPaymentId", "paymentId",
            "startDate", "endDate", "dueDate", "number", "name", "description", "note", "approvedAt", "calculatedAt", "calculatedBy",
            "companyId", "contactId", "creatorId", "status", "paidAt", "forecastDistributionAt", "submittedAt", "contractAmount",
            "originalAmount", "amount", "previousAmount", "completedWorkRetention", "materialsOnStoreRetention", "materialsRetention",
            "previousRetention", "netRetention", "materialsOnStore", "previousMaterialsOnStore", "materialsBilled", "previousMaterialsBilled",
            "netMaterialsOnStore", "approvedChangeOrders", "previousApprovedChangeOrders", "netAmount", "aggregateBy", "hasItemRejected",
            "hasItemReviewed", "exchangeRate", "previousExchangeRate", "previousAmountForeignCurrency", "previousClaimedAmountForeignCurrency",
            "contractAmountForeignCurrency", "originalAmountForeignCurrency", "approvedChangeOrdersForeignCurrency",
            "previousApprovedChangeOrdersForeignCurrency", "completedWorkRetentionForeignCurrency", "previousRetentionForeignCurrency",
            "previousMaterialsBilledForeignCurrency", "recipients", "netAmountForeignCurrency", "claimedAmount", "previousClaimedAmount",
            "integrationState", "integrationStateChangedAt", "integrationStateChangedBy", "createdAt", "updatedAt"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $offset,
        $limit,
        $sort,
        $paymentId,
        $associationId,
        $associationType
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $PaymentItemArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $PaymentItemUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/payment-items"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($associationId) { $Body["filter[associationId]"] = $associationId }
    if ($paymentId) { $Body["filter[paymentId]"] = $paymentId }
    if ($associationType) { $Body["filter[associationType]"] = $associationType }
    if ($offset) { $Body["offset"] = $offset }
    if ($limit) { $Body["limit"] = $limit }
    if ($sort) { $Body["sort"] = $sort }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialPaymentItem = Invoke-Restmethod -Method GET -Uri $PaymentItemUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $PaymentItemArray = [System.Collections.ArrayList]::new()
    [void]$PaymentItemArray.Add($initialPaymentItem.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempPaymentItem = $initialPaymentItem
    while (![string]::IsNullOrWhiteSpace($tempPaymentItem.pagination.nextUrl)) {
        $tempPaymentItem = Invoke-Restmethod -Method GET -Uri $tempPaymentItem.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$PaymentItemArray.Add($tempPaymentItem.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $PaymentItemArray
    [System.Data.DataTable]$PaymentItemTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the PaymentItemArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($PaymentItemPage in $PaymentItemArray) {
        # Iterate through the pages of the ArrayList
        foreach ($PaymentItem in $PaymentItemPage) {
            # Iterate through each individual PaymentItem and create rows
            $row = $PaymentItemTable.NewRow()
            foreach ($column in $PaymentItemTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $PaymentItem.$column
            }
            # Custom fill example to change generic name of column 'associationType' to 'AssetID'
            # $row["assetId"] = $asset.associationType

            # Add populated row to the datatable
            $PaymentItemTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $PaymentItemTable
}


