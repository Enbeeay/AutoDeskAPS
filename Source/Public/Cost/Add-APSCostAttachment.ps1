
<#
.SYNOPSIS
Creates an attachment in a specific project.

.DESCRIPTION
Sends a POST request to the APS API to link an attachment urn to a given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER name
Name of the attachment.

.PARAMETER urn
Version URN from BIM 360 Docs after the attachment is uploaded.

.PARAMETER associationId
The object ID of the item with which the actions are associated — a budget, contract, or cost item for example.

.PARAMETER associationType
The type of the item. List of types are on APS Docs.

.PARAMETER folderId
Folder ID retrieved from attachment-folder

.EXAMPLE
Add-APSCostAttachment -ProjectID $ProjectID -name "Architecture" -urn $urn -associationId $associationId -associationType "Budget"

Adds the attachment with the name "Architecture" specified by the urn to the budget identified by $associationId in the project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-attachments-POST/
#>
function Add-APSCostAttachment {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$name,
        [Parameter(Mandatory = $true)]
        [string]$urn,
        [Parameter(Mandatory = $true)]
        $associationId,
        [Parameter(Mandatory = $true)]
        $associationType,

        # Add all optional parameters, must include type
        $folderId
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/attachments"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["name"] = $name
    $Body["urn"] = $urn
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType

    # Initialize all optional parameters
    if ($folderId) { $Body["folderId"] = $folderId }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}