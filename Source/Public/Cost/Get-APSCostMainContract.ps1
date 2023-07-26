
<#
.SYNOPSIS
Retrieves the main contract item in the specified project

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.EXAMPLE
$(Get-APSCostMainContract -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT containing a list of all Main Contracts in a project, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - no documentation exists (as of 06/21/2023), good luck :)
#>
function Get-APSCostMainContract {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "code", "name", "description", "type", "createdAt", "updatedAt", "contactId", "signedBy",
            "ownerId", "ownerCompanyId", "ownerContactId", "contractorCompanyId", "contractorContactId", "architectCompanyId",
            "architectContactId", "notaryCompanyId", "notaryContactId", "amount", "retentionCap", "status", "changedBy",
            "creatorId", "revised", "scopeOfWork", "note", "submitted", "received", "unReceived", "remaining", "paid", "billToDate",
            "paymentsCount", "recipients", "executedDate", "startDate", "plannedCompletionDate", "actualCompletionDate", "closeDate",
            "paymentDue", "paymentDueType", "externalId", "externalSystem", "externalMessage", "lastSyncTime", "isDefault",
            "integrationState", "integrationStateChangedAt", "integrationStateChangedBy", "locked", "lockedBy", "lockedAt", "allowOverbilling")

        #Filter parameters are unknown
    )


    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $MainContractArray
    $MainContractUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/main-contracts"

    # Initialize the Body of the GET request
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialMainContract = Invoke-Restmethod -Method GET -Uri $MainContractUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $MainContractArray = [System.Collections.ArrayList]::new()
    [void]$MainContractArray.Add($initialMainContract.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempMainContract = $initialMainContract
    while (![string]::IsNullOrWhiteSpace($tempMainContract.pagination.nextUrl)) {
        $tempMainContract = Invoke-Restmethod -Method GET -Uri $tempMainContract.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$MainContractArray.Add($tempMainContract.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $MainContractArray
    [System.Data.DataTable]$MainContractTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the MainContractArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($MainContractPage in $MainContractArray) {
        # Iterate through the pages of the ArrayList
        foreach ($MainContract in $MainContractPage) {
            # Iterate through each individual MainContract and create rows
            $row = $MainContractTable.NewRow()
            foreach ($column in $MainContractTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $MainContract.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $MainContractTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $MainContractTable
}


