<#
.SYNOPSIS
Retrieves Asset Status Data

.DESCRIPTION
Sends a GET request to the APS API to retrieve asset data for a given project

.PARAMETER ProjectID
The ID of the Project

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER updatedAt
A string that specifies a date and time or a date and time range at which all returned objects mast have been updated. A single date and time takes this format: YYYY-MM-DDThh:mm:ss.SSSZ, A date and time range takes this format: YYYY-MM-DDThh:mm:ss.SSSZ..YYYY-MM-DDThh:mm:ss.SSSZ. Range queries can be closed or open in either direction: YYYY-MM-DDThh:mm:ss.SSSZ.. or ..YYYY-MM-DDThh:mm:ss.SSSZ.

.EXAMPLE
Get-APSAssetStatus -ProjectID 346e1541-4ad5-486f-b210-60debea373f6 -updatedAt "2014-11-25T09:00:00.0000"

.NOTES
Columns included by default :
"StatusID",
"CreatedAt",
"CreatedBy",
"UpdatedAt",
"UpdatedBy",
"IsActive",
"Label",
"Description",
"Color",
"Bucket",
"StatusSetId",
"ProjectID"

#>
function Get-APSAssetStatus {
    Param(
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("StatusID", "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "IsActive", "Label",
            "Description", "Color", "Bucket", "StatusSetId", "ProjectID"),

        $updatedAt
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-asset-statuses-GET/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $StatusArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $StatusUrl = "https://developer.api.autodesk.com/construction/assets/v1/projects/$($ProjectID)/asset-statuses"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "200" }

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($updatedAt) { $body["filter[updatedAt]"] = ([datetime]$updatedAt).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") 
    }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialStatus = Invoke-Restmethod -Method GET -Uri $StatusUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $StatusArray = [System.Collections.ArrayList]::new()
    [void]$StatusArray.Add($initialStatus.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempStatus = $initialStatus
    while (![string]::IsNullOrWhiteSpace($tempStatus.pagination.nextUrl)) {
        $tempStatus = Invoke-Restmethod -Method GET -Uri $tempStatus.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$StatusArray.Add($tempStatus.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $StatusArray
    [System.Data.DataTable]$StatusTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the StatusArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($StatusPage in $StatusArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Status in $StatusPage) {
            # Iterate through each individual Status and create rows
            $row = $StatusTable.NewRow()
            foreach ($column in $StatusTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Status.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            $row["statusId"] = $status.id
            $row["statusSetId"] = $status.statusStepSetId

            # Add populated row to the datatable
            $StatusTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $StatusTable
}



