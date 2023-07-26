
<#
.SYNOPSIS
Returns a paginated list of forms and fields in a project. Forms are sorted by updatedAt, most recent first.

.DESCRIPTION
Sends a GET request to the APS API and populates two created datatables with the returned information on both Forms and their respective Fields.

.PARAMETER ProjectID
The ID for the project.

.PARAMETER DesiredColumns
The desired columns to be returned for the Forms table. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER DesiredColumnsField
The desired columns to be returned for the Fields table. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER updatedAfter
Filter parameter to return Forms updated after a specified time.

.EXAMPLE
$(Get-APSForm -ProjectID $ProjectID)[0] | Out-GridView

Outputs a DT of all forms in the project in a gridview, not including fields.

.EXAMPLE
$(Get-APSForm -ProjectID $ProjectID)[1] | Out-GridView

Outputs a DT of all fields in the project in a gridview, not including forms.

.EXAMPLE
$temp = Get-APSForm -ProjectID $ProjectID;  $temp[0] | Out-GridView;    $temp[1] | Out-GridView

Outputs a DT of all forms in the project in a gridview and a separate gridview of fields.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/forms-forms-GET/
#>
function Get-APSForm {
    Param(
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [string[]] $DesiredColumns = ("ProjectID", "FormID", "FormName", "FormNum", "CreatedAt", "CreatedBy", "UpdatedAt", "Status", "Description" ),
        [string[]] $DesiredColumnsField = ("ProjectID", "FormID", "FieldID", "ItemLabel", "SectionLabel", "Notes", "ValueName", "TextVal", "ArrayVal", "ChoiceVal", "ToggleVal", "NumberVal", "DateVal"),
        $updatedAfter
    )

    # Retrieve access token inFormation stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()
    # Retrieve data from API, put into $FormArray
    $FormUrl = "https://developer.api.autodesk.com/construction/forms/v1/projects/$($ProjectId)/forms"
    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($updatedAfter) { $Body["filter[updatedAfter]"] = $updatedAfter.ToString("o") }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password Field and $Body
    $initialForm = Invoke-Restmethod -Method GET -Uri $FormUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $FormArray = [System.Collections.ArrayList]::new()
    [void]$FormArray.Add($initialForm.data)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempForm = $initialForm
    while (![string]::IsNullOrWhiteSpace($tempForm.pagination.nextUrl)) {
        $tempForm = Invoke-Restmethod -Method GET -Uri $tempForm.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$FormArray.Add($tempForm.data)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $FormArray
    [System.Data.DataTable]$FormTable = New-APSDT -DesiredColumns $DesiredColumns
    [System.Data.DataTable]$FieldTable = New-APSDT -DesiredColumns $DesiredColumnsField

    # Populate the new tables with data from the FormArray
    foreach ($FormPage in $FormArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Form in $FormPage) {
            # Iterate through each individual Form and create rows
            $row = $FormTable.NewRow()
            foreach ($column in $FormTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Form.$column
            }
            $row["FormID"] = $Form.id
            $row["FormName"] = $Form.FormTemplate.name

            # Add populated row to the datatable
            $FormTable.Rows.Add($row)

            # Populate the "inner" table using similar method
            foreach ($Field in $Form.customValues) {
                $row = $FieldTable.NewRow()
                foreach ($column in $FieldTable.Columns) {
                    $row[$column] = $Field.$column
                }
                $row["FormId"] = $Form.id
                $row["ProjectId"] = $Form.projectId
                $FieldTable.Rows.Add($row)
            }
        }
    }
    # Return the datatable intact using the comma
    Write-Output -NoEnumerate $FormTable
    Write-Output -NoEnumerate $FieldTable
}




