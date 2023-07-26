
<#
.SYNOPSIS
Retrieves the details of all contracts in the specified project.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER id
Return only the items that are identified by the provided list of item IDs. Separate multiple IDs with commas.

.PARAMETER code
Return only items that are identified by the specified codes (separated by commas).

.PARAMETER status
Return only items with the specified statuses. Separate multiple values with commas.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.EXAMPLE
$(Get-APSCostContract -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all Contracts in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-contracts-GET/
#>
function Get-APSCostContract {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "code", "name", "description", "companyId", "type", "contactId", "signedBy", "ownerId",
            "mainContractId", "retentionCap", "status", "currency", "exchangeRate", "forecastExchangeRate", "forecastExchangeRateUpdatedAt",
            "changedBy", "creatorId", "awarded", "originalBudget", "internalAdjustment", "approvedOwnerChanges", "pendingOwnerChanges",
            "approvedChangeOrders", "approvedInScopeChangeOrders", "pendingChangeOrders", "reserves", "actualCost", "uncommitted", "revised",
            "projectedCost", "projectedBudget", "forecastFinalCost", "forecastVariance", "forecastCostComplete", "varianceTotal", "awardedAt",
            "statusChangedAt", "documentGeneratedAt", "sentAt", "respondedAt", "responseDue", "returnedAt", "onsiteAt", "offsiteAt", "procuredAt",
            "approvedAt", "scopeOfWork", "note", "compounded", "paymentDue", "paymentDueType", "budgets", "scheduleOfValues",
            "externalId", "externalSystem", "externalMessage", "lastSyncTime", "integrationState", "integrationStateChangedAt",
            "integrationStateChangedBy", "createdAt", "updatedAt"),

        <# SQL Naming - Not Being Used
        [string[]] $DesiredColumns = ("ContractID", "Code", "ContractName", "Description", "CompanyID", "Type", "ContactID", "SignedBy", "OwnerID", "MainContractID", "RetentionCap", "Status",
        "Currency", "ExchangeRate", "ForecastExchangeRate", "ForecastExchangeRateUpdatedAt", "ChangedBy", "CreatorID", "Awarded", "OriginalBudget", "InternalAdjustment",
        "ApprovedOwnerChanges", "PendingOwnerChanges", "ApprovedChangeOrders", "ApprovedInScopeChangeOrders", "PendingChangeOrders", "Reserves", "ActualCost", "Uncommitted",
        "Revised", "ProjectedCost", "ProjectedBudget", "ForecastFinalCost", "ForecastVariance", "ForecastCostComplete", "VarianceTotal", "AwardedAt", "StatusChangedAt", "DocumentGeneratedAt",
        "SentAt", "RespondedAt", "ResponseDue", "ReturnedAt", "OnsiteAt", "OffsiteAt", "ProcuredAt", "ApprovedAt", "ScopeOfWork", "Note", "Compounded", "PaymentDue", "PaymentDueType", "ExternalID",
        "ExternalSystem", "ExternalMessage", "LastSyncTime", "IntegrationState", "IntegrationStateChangedBy", "CreatedAt", "UpdatedAt" ),#>
        $id,
        $code,
        $status,
        $externalSystem,
        $externalId,
        $lastModifiedSince
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $ContractArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $ContractUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/contracts"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = 200 }
    if ($id) { $body["filter[id]"] = $id }
    if ($code) { $body["filter[code]"] = $code }
    if ($status) { $body["filter[status]"] = $status }
    if ($externalSystem) { $body["filter[externalSystem]"] = $externalSystem }
    if ($externalId) { $body["filter[externalId]"] = $externalId }
    if ($lastModifiedSince) { $body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialContract = Invoke-Restmethod -Method GET -Uri $ContractUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $ContractArray = [System.Collections.ArrayList]::new()
    [void]$ContractArray.Add($initialContract.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempContract = $initialContract
    while (![string]::IsNullOrWhiteSpace($tempContract.pagination.nextUrl)) {
        $tempContract = Invoke-Restmethod -Method GET -Uri $tempContract.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$ContractArray.Add($tempContract.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $ContractArray
    [System.Data.DataTable]$ContractTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the ContractArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($ContractPage in $ContractArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Contract in $ContractPage) {
            # Iterate through each individual Contract and create rows
            $row = $ContractTable.NewRow()
            foreach ($column in $ContractTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Contract.$column
            }
            #$row["ContractName"] = $Contract.name
            #$row["ContractID"] = $Contract.id

            # Add populated row to the datatable
            $ContractTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $ContractTable
}


