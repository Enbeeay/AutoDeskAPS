
<#
.SYNOPSIS
Retrieves payments in the given project based on the specified query criteria

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

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER id
Return only the items that are identified by the provided list of item IDs. Separate multiple IDs with commas.

.PARAMETER number
Return only the items that are identified by the provided list of auto-generated sequence numbers. Separate multiple numbers with commas.

.PARAMETER budgetPaymentId
Return only the payments associated with the budget payments (used to query the related cost payments or expenses) that are identified on this list of IDs. Separate multiple IDs with commas.

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER include
Include nested resources in the response.
Possible values: paymentReferences, attributes.

.EXAMPLE
$(Get-APSCostPayment -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all Payments in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-payments-GET/
#>
function Get-APSCostPayment {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "billingPeriodId", "associationId", "mainContractId", "budgetPaymentId", "associationType",
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
        $associationType,
        $associationId,
        $id,
        $number,
        $budgetPaymentId,
        $lastModifiedSince,
        $include
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $PaymentArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $PaymentUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/payments"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($offset) { $Body["offset"] = $offset }
    if ($limit) { $Body["limit"] = $limit }
    if ($sort) { $Body["sort"] = $sort }
    if ($include) { $Body["include"] = $include }
    if ($associationType) { $Body["filter[associationType]"] = $associationType }
    if ($associationId) { $Body["filter[associationId]"] = $associationId }
    if ($id) { $Body["filter[id]"] = $id }
    if ($number) { $Body["filter[number]"] = $number }
    if ($budgetPaymentId) { $Body["filter[budgetPaymentId]"] = $budgetPaymentId }
    if ($lastModifiedSince) { $Body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialPayment = Invoke-Restmethod -Method GET -Uri $PaymentUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $PaymentArray = [System.Collections.ArrayList]::new()
    [void]$PaymentArray.Add($initialPayment.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempPayment = $initialPayment
    while (![string]::IsNullOrWhiteSpace($tempPayment.pagination.nextUrl)) {
        $tempPayment = Invoke-Restmethod -Method GET -Uri $tempPayment.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$PaymentArray.Add($tempPayment.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $PaymentArray
    [System.Data.DataTable]$PaymentTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the PaymentArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($PaymentPage in $PaymentArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Payment in $PaymentPage) {
            # Iterate through each individual Payment and create rows
            $row = $PaymentTable.NewRow()
            foreach ($column in $PaymentTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Payment.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $PaymentTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $PaymentTable
}


