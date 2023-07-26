
<#
.SYNOPSIS
Gets generated documents.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER latest
This is deprecated.

.PARAMETER signed
This is deprecated.

.EXAMPLE
$(Get-APSCostDocument -ProjectID $ProjectID -associationId $budget -associationType "Budget")[0] | Out-Gridview

Obtains a DT containing a list of all Documents related to $budget, then unravels and outputs as gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-documents-GET/
#>
function Get-APSCostDocument {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        # Other Mandatory Params
        [Parameter(Mandatory = $true)]
        $associationId,
        [Parameter(Mandatory = $true)]
        $associationType,

        # Change default column names for request
        [string[]] $DesiredColumns = ("id", "recipientId", "signedBy", "urn", "pdfUrn", "status",
            "jobId", "errorInfo", "associationId", "associationType", "createdAt", "updatedAt"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $latest,
        $signed
    )


    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $DocumentArray
    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $DocumentUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/documents"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Initialize all mandatory parameters
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($latest) { $Body["filter[latest]"] = $latest }
    if ($signed) { $Body["filter[signed]"] = $signed }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialDocument = Invoke-Restmethod -Method GET -Uri $DocumentUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $DocumentArray = [System.Collections.ArrayList]::new()
    [void]$DocumentArray.Add($initialDocument)

    <# If desired, add behavior here to obtain "all" documents using the offset parameter automatically similar to the pagination shown below
    $tempDocument = $initialDocument
    while(![string]::IsNullOrWhiteSpace($tempDocument.pagination.nextUrl)) {
        $tempDocument = Invoke-Restmethod -Method GET -Uri $tempDocument.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$DocumentArray.Add($tempDocument)
    }
    #>

    # Use the helper function New-APSDT to create a datatable for the data in $DocumentArray
    [System.Data.DataTable]$DocumentTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the DocumentArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($DocumentPage in $DocumentArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Document in $DocumentPage) {
            # Iterate through each individual Document and create rows
            $row = $DocumentTable.NewRow()
            foreach ($column in $DocumentTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Document.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $DocumentTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $DocumentTable
}


