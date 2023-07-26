
<#
.SYNOPSIS
Returns a list of projects.

.DESCRIPTION
Due to there not being a specific function to GET all projects for an ACC project,
the function obtains a list of all projects and sends a metadata request for each project
to obtain a datatable filled out with the desired metadata.

.PARAMETER DesiredColumns
The desired columns to be returned for the Fields table. Must match the names of fields from the API to be autofilled in the returned DT.

.EXAMPLE
$(Get-APSProject)[0] | Out-Gridview

Outputs the list of all projects as a gridview.

.NOTES
Currently performs a request to retrieve the account ID that is then used in the main request, making this function perform two different API calls.
Autodesk API Documentation -    https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET/
                                https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-hub_id-projects-GET/
                                https://aps.autodesk.com/en/docs/bim360/v1/reference/http/projects-:project_id-GET/
#>
function Get-APSProject {
    Param(
        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "job_number", "name", "created_at", "updated_at")

        <# Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $optionalParam1,
        $optionalParam2,
        $optionalParam3,
        ...
        $optionalParam4
        #>
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Obtain 2-Legged Authentication Token
    $2LegTok = Get-APS2LegAuth

    # Retrieve Hub UD from API, put into $hubId
    # Set the URL per APS docs
    $hubUrl = "https://developer.api.autodesk.com/project/v1/hubs"
    $hubData = Invoke-Restmethod -Method GET -Uri $hubUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $hubID = $hubData.data.id

    # Use the helper function New-APSDT to create a datatable for the project data
    [System.Data.DataTable]$ProjectTable = New-APSDT -DesiredColumns $DesiredColumns

    # Obtain a list of all project IDs
    $projectListUrl = "https://developer.api.autodesk.com/project/v1/hubs/$($hubId)/projects"
    $projectList = Invoke-Restmethod -Method GET -Uri $projectListUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Iterate through all project IDs and fill out table with metadata
    foreach ($project in $projectList.data) {
        # Substring to remove the 'b.' prefixes
        $projUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$($hubID.Substring(2))/projects/$($project.id.Substring(2))"
        $projData = Invoke-Restmethod -Method GET -Uri $projUrl -Header @{ "Authorization" = "Bearer $($2LegTok)" }

        # Populate DT
        $row = $ProjectTable.NewRow()
        foreach ($column in $ProjectTable.Columns) {
            $row[$column] = $projData.$column
        }
        $ProjectTable.Rows.Add($row)
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $ProjectTable
}


