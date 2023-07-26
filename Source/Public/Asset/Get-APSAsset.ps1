<#
.SYNOPSIS
Retrieves asset data

.DESCRIPTION
Sends a GET request to the APS API to retrieve asset data for a given project

.PARAMETER ProjectID
The ID of the Project

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER categoryId
The ID of the category to which the asset belongs.

.PARAMETER statusLabel
The label which describes the status of an asset E.G. Delivered, active

.PARAMETER statusId
The ID of the status assigned to the asset. The status must belong to the status set specified by the asset’s category.

.PARAMETER searchText
The keyword that the user wishes to search with

.PARAMETER updatedAt
A string that specifies a date and time or a date and time range at which all returned objects mast have been updated. A single date and time takes this format: YYYY-MM-DDThh:mm:ss.SSSZ, A date and time range takes this format: YYYY-MM-DDThh:mm:ss.SSSZ..YYYY-MM-DDThh:mm:ss.SSSZ. Range queries can be closed or open in either direction: YYYY-MM-DDThh:mm:ss.SSSZ.. or ..YYYY-MM-DDThh:mm:ss.SSSZ.

.PARAMETER sort
The column that the user wishes to sort by

.EXAMPLE
Get-APSAsset -ProjectID 346e1541-4ad5-486f-b210-60debea373f6 -searchText "Conduit" -sort "CreatedAt"

.NOTES
Columns included by default :
"ProjectID",
"AssetID",
"CreatedAt",
"CreatedBy",
"UpdatedAt",
"UpdatedBy",
"IsActive",
"Description",
"ClientAssetID",
"CategoryID",
"StatusID"

#>
function Get-APSAsset {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = @("ProjectID", "AssetID", "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "IsActive",
            "Description", "ClientAssetID", "CategoryID", "StatusID"),

        $categoryId,
        $statusLabel,
        $statusId,
        $searchText,
        $updatedAt,
        $sort
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-assets-v2-GET/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $AssetArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $AssetUrl = "https://developer.api.autodesk.com/construction/assets/v2/projects/$($ProjectID)/assets"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "200" }

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($categoryId) { $body["filter[categoryId]"] = $categoryId
    }
    if ($statusLabel) { $body["filter[statusLabel]"] = $statusLabel
    }
    if ($statusId) { $body["filter[statusId]"] = $statusId
    }
    if ($searchText) { $body["filter[searchText]"] = $searchText
    }
    if ($updatedAt) { $body["filter[updatedAt]"] = ([datetime]$updatedAt).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.")
    }
    if ($sort) { $body["sort"] = $sort
    }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialAsset = Invoke-Restmethod -Method GET -Uri $AssetUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $AssetArray = [System.Collections.ArrayList]::new()
    [void]$AssetArray.Add($initialAsset.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempAsset = $initialAsset
    while (![string]::IsNullOrWhiteSpace($tempAsset.pagination.nextUrl)) {
        $tempAsset = Invoke-Restmethod -Method GET -Uri $tempAsset.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$AssetArray.Add($tempAsset.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $AssetArray
    [System.Data.DataTable]$AssetTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the AssetArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($AssetPage in $AssetArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Asset in $AssetPage) {
            # Iterate through each individual Asset and create rows
            $row = $AssetTable.NewRow()
            foreach ($column in $AssetTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Asset.$column
            }
            $row["assetId"] = $asset.id
            $row["ProjectID"] = $ProjectID
            # Add populated row to the datatable
            $AssetTable.Rows.Add($row)
        }
    }
    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $AssetTable
}


