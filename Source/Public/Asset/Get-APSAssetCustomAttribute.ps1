<#
.SYNOPSIS
Retrieves asset custom attribute data

.DESCRIPTION
Sends a GET request to the APS API to retrieve asset custom attribute data for a given project

.PARAMETER ProjectID
The ID of the Project

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER DesiredValueColumns
The columns of data that the requester wishes to retrieve for the values subtable (defaults to all columns)

.PARAMETER updatedAt
A string that specifies a date and time or a date and time range at which all returned objects mast have been updated. A single date and time takes this format: YYYY-MM-DDThh:mm:ss.SSSZ, A date and time range takes this format: YYYY-MM-DDThh:mm:ss.SSSZ..YYYY-MM-DDThh:mm:ss.SSSZ. Range queries can be closed or open in either direction: YYYY-MM-DDThh:mm:ss.SSSZ.. or ..YYYY-MM-DDThh:mm:ss.SSSZ

.EXAMPLE
Get-APSAssetCustomAttribute -ProjectID 346e1541-4ad5-486f-b210-60debea373f6 -updatedAt "2014-11-25T09:00:00.0000"

.NOTES
Columns included by default(main table):
"DisplayName",
"Description",
"EnumValues",
"RequiredOnIngress",
"MaxLengthOnIngress",
"DefaultValue",
"DataType",
"CAID" (Alias for 'id'),
"CreatedAt",
"CreatedBy",
"UpdatedAt",
"UpdatedBy",
"DeletedAt",
"DeletedBy",
"IsActive",
"Version",
"ProjectID",
"name"

Columns included by default(value subtable):
"ValueID"(Alias for 'id')
"CreatedAt"
"CreatedBy"
"UpdatedAt"
"UpdatedBy"
"DeletedAt"
"DeletedBy"
"IsActive"
"Version"
"ProjectID"
"CustomAttributeID"
"DisplayName"

#>
function Get-APSAssetCustomAttribute {
    Param(
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("DisplayName", "Description", "EnumValues", "RequiredOnIngress", "MaxLengthOnIngress", "DefaultValue",
            "DataType", "CAID"<#Alias for 'id'#>, "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "DeletedAt", "DeletedBy", "IsActive", "Version", "ProjectID",
            "name"),
        [string[]] $DesiredValueColumns = ("ValueID"<#Alias for 'id'#>, "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy", "DeletedAt", "DeletedBy", "IsActive",
            "Version", "ProjectID", "CustomAttributeID", "DisplayName"),
        $updatedAt
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/assets-custom-attributes-GET/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $CustomAttributeArray
    $CustomAttributeUrl = "https://developer.api.autodesk.com/construction/assets/v1/projects/$($ProjectID)/custom-attributes"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "200" }

    if ($updatedAt) { $body["filter[updatedAt]"] = ([datetime]$updatedAt).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") 
    }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialCustomAttribute = Invoke-Restmethod -Method GET -Uri $CustomAttributeUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $CustomAttributeArray = [System.Collections.ArrayList]::new()
    [void]$CustomAttributeArray.Add($initialCustomAttribute.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempCustomAttribute = $initialCustomAttribute
    while (![string]::IsNullOrWhiteSpace($tempCustomAttribute.pagination.nextUrl)) {
        $tempCustomAttribute = Invoke-Restmethod -Method GET -Uri $tempCustomAttribute.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$CustomAttributeArray.Add($tempCustomAttribute.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $CustomAttributeArray
    [System.Data.DataTable]$CustomAttributeTable = New-APSDT -DesiredColumns $DesiredColumns
    [System.Data.Datatable]$ValueTable = New-APSDT -DesiredColumns $DesiredValueColumns
    # Populate the new table with data from the CustomAttributeArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($CustomAttributePage in $CustomAttributeArray) {
        # Iterate through the pages of the ArrayList
        foreach ($CustomAttribute in $CustomAttributePage) {
            # Iterate through each individual CustomAttribute and create rows
            $row = $CustomAttributeTable.NewRow()
            foreach ($column in $CustomAttributeTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $CustomAttribute.$column
            }
            $row["CAID"] = $CustomAttribute.id
            $CustomAttributeTable.Rows.Add($row)

            foreach ($value in $CA.values) {
                $row = $valueTable.NewRow()
                foreach ($column in $valueTable.Columns) {
                    $row[$column] = $value.$column
                }
                $row["CAId"] = $value.customAttributeId
                $row["valueId"] = $value.id
                $valueTable.Rows.Add($row)
            }
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CustomAttributeTable
    Write-Output -NoEnumerate $ValueTable

}


