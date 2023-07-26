
<#
.SYNOPSIS
Retrieves a list of all change orders in a specified project, including PCO (potential change orders), RFQ (requests for quote), SCO (supplier change orders), RCO (requests for change order), and OCO (owner change orders). The fields returned in the response vary according to the type of change order.

Note that requests for change order (RCO) may be referred to as “change order requests” (COR) in some Construction Cloud contexts. These two terms are interchangeable.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER manualFlag
Must set this to true if passing in $DesiredColumns AND also using $COType

.PARAMETER COType
The change order type. Possible values: pco, rfq, rco, oco, sco.

.EXAMPLE
$(Get-APSCostChangeOrder -ProjectID $ProjectID -COType "pco")[0] | Out-GridView

Outputs a DT of all "pco" change orders in a project via a gridview.

.EXAMPLE
$(Get-APSCostChangeOrder -ProjectID $ProjectID)[0] | Out-GridView

Outputs a DT of all root change orders (pco, rfq, rco, oco, sco) in a project via a gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-change-orders-GET/

#>
function Get-APSCostChangeOrder {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "name", "type", "actAs", "position", "workflowType", "createdAt", "updatedAt"),

        #Must set this to true if passing in $DesiredColumns and also using $COType
        $manualFlag,

        #Optional parameter
        [Alias("changeOrder")]
        [string]$COType

        <# SQL Naming - Not Being Used
        [string[]] $DesiredColumns = ("COID", "COName", "Type", "ActAs", "Position", "WorkflowType", "CreatedAt", "UpdatedAt")#>
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $ChangeOrderArray
    if ($COType) {
        # Path of execution to gain specific change orders associated with a type
        if (-not $manualFlag) {
            # Changes $DesiredColumns to fit this path of execution
            $DesiredColumns = ("id", "number", "name", "description", "type", "scope", "creatorId", "ownerId", "changedBy", "budgetStatus",
                "costStatus", "estimated", "proposed", "submitted", "approved", "committed", "scopeOfWork", "note", "sourceId", "externalId",
                "externalSystem", "externalMessage", "lastSyncTime", "integrationState", "integrationStateChangedAt", "integrationStateChangedBy",
                "createdAt", "updatedAt", "costItems")
        }

        # Sets the URL
        $ChangeOrderUrl = "	https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/change-orders/$($COType)"

        # Initialize the Body of the GET request, including some universal preferences like max limit
        $Body = @{}

        # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
        $initialChangeOrder = Invoke-Restmethod -Method GET -Uri $ChangeOrderUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

        # Initialize an ArrayList for the response
        $ChangeOrderArray = [System.Collections.ArrayList]::new()
        [void]$ChangeOrderArray.Add($initialChangeOrder.results)


        # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
        $tempChangeOrder = $initialChangeOrder
        while (![string]::IsNullOrWhiteSpace($tempChangeOrder.pagination.nextUrl)) {
            $tempChangeOrder = Invoke-Restmethod -Method GET -Uri $tempChangeOrder.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
            [void]$ChangeOrderArray.Add($tempChangeOrder.results)
        }
    }
    else {
        # Default Path
        # Sets the URL
        $ChangeOrderUrl = "	https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/change-orders"
        # Initialize the Body of the GET request, including some universal preferences like max limit
        $Body = @{}

        # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
        $initialChangeOrder = Invoke-Restmethod -Method GET -Uri $ChangeOrderUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body
        # Initialize an ArrayList for the response
        $ChangeOrderArray = [System.Collections.ArrayList]::new()
        [void]$ChangeOrderArray.Add($initialChangeOrder)


        # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
        $tempChangeOrder = $initialChangeOrder
        while (![string]::IsNullOrWhiteSpace($tempChangeOrder.pagination.nextUrl)) {
            $tempChangeOrder = Invoke-Restmethod -Method GET -Uri $tempChangeOrder.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
            [void]$ChangeOrderArray.Add($tempChangeOrder)
        }
    }



    # Use the helper function New-APSDT to create a datatable for the data in $ChangeOrderArray
    [System.Data.DataTable]$ChangeOrderTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the ChangeOrderArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($ChangeOrderPage in $ChangeOrderArray) {
        # Iterate through the pages of the ArrayList
        foreach ($ChangeOrder in $ChangeOrderPage) {
            # Iterate through each individual ChangeOrder and create rows
            $row = $ChangeOrderTable.NewRow()
            foreach ($column in $ChangeOrderTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $ChangeOrder.$column
            }
            #$row["COID"] = $ChangeOrder.id
            #$row["COName"] = $ChangeOrder.name

            # Add populated row to the datatable
            $ChangeOrderTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $ChangeOrderTable
}


