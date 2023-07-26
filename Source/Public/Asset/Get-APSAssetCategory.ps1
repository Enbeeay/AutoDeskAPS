<#
.SYNOPSIS
Retrieves Asset Category Data

.DESCRIPTION
Sends a GET request to the APS API to retrieve asset category data for a given project

.PARAMETER ProjectID
The ID of the Project

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER isActive
Specifies whether or not to return categories that are active. If true, return only active categories. If false, return only inactive categories. Default is to return both active and inactive categories, to ensure full tree structure is returned (conversely, full tree structure is not guaranteed when filtering active or inactive categories).

.PARAMETER parentId
Specifies the parent category ID of returned categories. The query returns only categories that are direct child categories of the specified category.

.PARAMETER maxDepth
Specifies the depth of the category tree to return, starting with the root category. Depth 0 means to return only the root category. Depth 4, for example, means to return only the root category and categories that are four levels of inheritance deep, but not to return categories that are five or more levels deep.
Note that this can be used in conjunction with filter[parentId], but that the depth is still computed from the root category, not the parent category specified by the filter.

.PARAMETER updatedAt
A string that specifies a date and time or a date and time range at which all returned objects mast have been updated. A single date and time takes this format: YYYY-MM-DDThh:mm:ss.SSSZ, A date and time range takes this format: YYYY-MM-DDThh:mm:ss.SSSZ..YYYY-MM-DDThh:mm:ss.SSSZ. Range queries can be closed or open in either direction: YYYY-MM-DDThh:mm:ss.SSSZ.. or ..YYYY-MM-DDThh:mm:ss.SSSZ.

.PARAMETER includeUid
If provided, and set to true, the globally-unique category uid field will be present in the response. The globally unique category ID is used with the (upcoming) v3 category APIs. The option to include the globally-unique ID with the v1 category APIs is to help consumers transition to the new IDs.

.EXAMPLE
Get-APSAssetCategory -ProjectID 346e1541-4ad5-486f-b210-60debea373f6 -isActive $true -ParentID 34

.NOTES
Columns included by default
"CategoryID",
"CreatedAt",
"CreatedBy",
"UpdatedAt",
"UpdatedBy",
"IsActive",
"Name",
"Description",
"IsRoot",
"IsLeaf",
"CategoryUID",
"ParentID"
#>
function Get-APSAssetCategory {
    Param(
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("CategoryID", "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "IsActive", "Name",
            "Description", "IsRoot", "IsLeaf", "CategoryUID", "ParentID"),

        $isActive,
        $parentId,
        $maxDepth,
        $updatedAt,
        $includeUid
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-categories-GET/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $CategoryArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $CategoryUrl = "https://developer.api.autodesk.com/construction/assets/v1/projects/$($ProjectID)/categories"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "200" }

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($isActive) { $body["filter[isActive]"] = $isActive 
    }
    if ($parentId) { $body["filter[parentId]"] = $parentId 
    }
    if ($maxDepth) { $body["filter[maxDepth]"] = $maxDepth 
    }
    if ($updatedAt) { $body["filter[updatedAt]"] = ([datetime]$updatedAt).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") 
    }
    if ($includeUid) { $body["includeUid"] = $includeUid 
    }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialCategory = Invoke-Restmethod -Method GET -Uri $CategoryUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $CategoryArray = [System.Collections.ArrayList]::new()
    [void]$CategoryArray.Add($initialCategory.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempCategory = $initialCategory
    while (![string]::IsNullOrWhiteSpace($tempCategory.pagination.nextUrl)) {
        $tempCategory = Invoke-Restmethod -Method GET -Uri $tempCategory.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$CategoryArray.Add($tempCategory.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $CategoryArray
    [System.Data.DataTable]$CategoryTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the CategoryArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($CategoryPage in $CategoryArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Category in $CategoryPage) {
            # Iterate through each individual Category and create rows
            $row = $CategoryTable.NewRow()
            foreach ($column in $CategoryTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Category.$column
            }
            $row["CategoryID"] = $Category.id
            $row["CategoryUID"] = $Category.uid

            # Add populated row to the datatable
            $CategoryTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CategoryTable

}


