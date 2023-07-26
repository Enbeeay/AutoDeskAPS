
<#
.SYNOPSIS
Find an attachment folder in BIM 360 Docs for a given item. That folder will save local files as attachments to the item. Files are saved using the Storage service.

.DESCRIPTION
Sends a GET request to the APS API and Returns response directly.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values:

.EXAMPLE
Get-APSCostCompanyFolder -ProjectID $ProjectID -associationId $budget -associationType "Budget"

Returns the JSON response of folders related to $budget.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-company-folders-GET/
#>
function Get-APSCostCompanyFolder {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [Parameter(Mandatory = $true)]
        $associationId,
        [Parameter(Mandatory = $true)]
        $associationType
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $CompanyFolderArray
    $CompanyFolderUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/company-folders"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{}

    # Initialize mandatory parameters
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    Invoke-Restmethod -Method GET -Uri $CompanyFolderUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body
}


