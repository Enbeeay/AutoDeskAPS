
<#
.SYNOPSIS
Retrieves all of the attachments associated with an item such as a budget, contract, or cost item. You can also retrieve certain nested resources related to the returned attachments.

.DESCRIPTION
Sends a GET request to the APS API and populates a created datatable with the returned information on the desired items.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.PARAMETER lastModifiedSince
Return only items that were modified since the specified date and time, in ISO 8601 format. For example, -lastModifiedSince "2020-03-01T13:00:00Z".

.PARAMETER include
A list of the nested resources related to the attachment to include in the response. Possible values: complianceRequirement.

.EXAMPLE
$(Get-APSCostAttachment -ProjectID $ProjectID)[0] | Out-Gridview

Obtains a DT of attachments in the specified project, then unravels and outputs it in a gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-attachments-GET/
#>
function Get-APSCostAttachment {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "folderId", "urn", "type", "name", "replaceIfExists",
            "associationId", "associationType", "createdAt", "updatedAt"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $associationId,
        $associationType,
        $lastModifiedSince,
        $include
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $AttachmentArray
    $AttachmentUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/attachments"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($associationId) { $Body["filter[associationId]"] = $associationId }
    if ($associationType) { $Body["filter[associationType]"] = $associationType }
    if ($lastModifiedSince) { $Body["filter[lastModifiedSince]"] = ([datetime]$lastModifiedSince).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
    if ($include) { $Body["include"] = $include }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialAttachment = Invoke-Restmethod -Method GET -Uri $AttachmentUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $AttachmentArray = [System.Collections.ArrayList]::new()
    [void]$AttachmentArray.Add($initialAttachment)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempAttachment = $initialAttachment
    while (![string]::IsNullOrWhiteSpace($tempAttachment.pagination.nextUrl)) {
        $tempAttachment = Invoke-Restmethod -Method GET -Uri $tempAttachment.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$AttachmentArray.Add($tempAttachment)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $AttachmentArray
    [System.Data.DataTable]$AttachmentTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the AttachmentArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($AttachmentPage in $AttachmentArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Attachment in $AttachmentPage) {
            # Iterate through each individual Attachment and create rows
            $row = $AttachmentTable.NewRow()
            foreach ($column in $AttachmentTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Attachment.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $AttachmentTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $AttachmentTable
}


