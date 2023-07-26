<#
.SYNOPSIS
Deletes a location from a specified project

.DESCRIPTION
Makes a DELETE call to the autodesk api to delete a location from a specified project, filtered by ProjectID, TreeID, and NodeID

.PARAMETER ProjectID
The identifier of the project that contains your locations tree.

.PARAMETER TreeID
Must be default. Currently a project can contain only the default tree.

.PARAMETER NodeID
The unique identifier of an LBS node.

.EXAMPLE
Remove-APSNode -ProjectID "fedsjkefio325nrew-efwefn43u3" -TreeID "default" -NodeID "9ed2948d-872f-4e7b-9904-a3703f5908c6"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/locations-nodes-POST/
#>
function Remove-APSNode {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [string]$TreeID,
        [string]$NodeID
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/locations-nodesnodeid-DELETE/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "https://developer.api.autodesk.com/construction/locations/v2/projects/$($ProjectID)/trees/$($TreeID)/nodes/$($NodeID)"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}
