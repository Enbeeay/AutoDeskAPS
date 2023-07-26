<#
.SYNOPSIS
Retrieves Asset Status Set data

.DESCRIPTION
Sends a GET request to the APS API to retrieve asset status set data for a given project

.PARAMETER ProjectID
The ID of the Project

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER DesiredValueColumns
The columns of data that the requester wishes to retrieve for the values subtable (defaults to all columns)

.PARAMETER updatedAt
A string that specifies a date and time or a date and time range at which all returned objects mast have been updated. A single date and time takes this format: YYYY-MM-DDThh:mm:ss.SSSZ, A date and time range takes this format: YYYY-MM-DDThh:mm:ss.SSSZ..YYYY-MM-DDThh:mm:ss.SSSZ. Range queries can be closed or open in either direction: YYYY-MM-DDThh:mm:ss.SSSZ.. or ..YYYY-MM-DDThh:mm:ss.SSSZ.

.EXAMPLE
Get-APSAssetStatusSet -ProjectID 346e1541-4ad5-486f-b210-60debea373f6 -updatedAt "2014-11-25T09:00:00.0000"


.NOTES
Columns included by default(main table):
"StatusSetID",
"CreatedAt",
"CreatedBy",
"UpdatedAt",
"UpdatedBy",
"IsActive",
"Name",
"Description",
"IsDefault",
"ProjectID"

Columns included by default (values table) :
"ValueID",
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
"ProjectId"

#>
function Get-APSAssetStatusSet {
    Param(
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("StatusSetID", "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "IsActive", "Name",
            "Description", "IsDefault", "ProjectID"),
        [string[]] $DesiredColumnsValue = ("ValueID", "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "IsActive", "Label",
            "Description", "Color", "Bucket", "StatusSetId", "ProjectId"),

        $updatedAt
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-status-step-sets-GET/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $StatusSetArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $StatusSetUrl = "https://developer.api.autodesk.com/construction/assets/v1/projects/$($projectId)/status-step-sets"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "200" }

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($updatedAt) { $body["filter[updatedAt]"] = ([datetime]$updatedAt).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") 
    }


    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialStatusSet = Invoke-Restmethod -Method GET -Uri $StatusSetUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $StatusSetArray = [System.Collections.ArrayList]::new()
    [void]$StatusSetArray.Add($initialStatusSet.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempStatusSet = $initialStatusSet
    while (![string]::IsNullOrWhiteSpace($tempStatusSet.pagination.nextUrl)) {
        $tempStatusSet = Invoke-Restmethod -Method GET -Uri $tempStatusSet.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$StatusSetArray.Add($tempStatusSet.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $StatusSetArray
    [System.Data.DataTable]$StatusSetTable = New-APSDT -DesiredColumns $DesiredColumns
    [System.Data.DataTable]$ValueTable = New-APSDT -DesiredColumns $DesiredColumnsValue

    # Populate the new table with data from the StatusSetArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($StatusSetPage in $StatusSetArray) {
        # Iterate through the pages of the ArrayList
        foreach ($StatusSet in $StatusSetPage) {
            # Iterate through each individual StatusSet and create rows
            $row = $StatusSetTable.NewRow()
            foreach ($column in $StatusSetTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $StatusSet.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            $row["statusSetId"] = $StatusSet.id

            # Add populated row to the datatable
            $StatusSetTable.Rows.Add($row)

            # Iterate through the subtable Values and populate
            foreach ($Value in $StatusSet.Values) {
                $row = $ValueTable.NewRow()
                foreach ($column in $ValueTable.Columns) {
                    $row[$column] = $Value.$column
                }
                $row["statusSetId"] = $Value.statusStepSetId
                $row["ValueId"] = $Value.id
                $ValueTable.Rows.Add($row)
            }
        }
    }

    # Return the datatables intact using the -NoEnumerate option
    Write-Output -NoEnumerate $StatusSetTable
    Write-Output -NoEnumerate $ValueTable
}



