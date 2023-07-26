<#
.SYNOPSIS
Edits a node's name or barcode

.DESCRIPTION
Sends a PATCH request to the Autodesk API to edit the name and/or barcode for a specified ProjectID, TreeID, and NodeID

.PARAMETER ProjectID
The identifier of the project that contains your locations tree.

.PARAMETER TreeID
Must be default. Currently a project can contain only the default tree.

.PARAMETER NodeID
The unique identifier of an LBS node.

.PARAMETER Name
The name of the specified LBS node to update. Note that you must specify name, barcode, or both for this endpoint to succeed.

.PARAMETER Barcode
The barcode of the specified LBS node to update. This value must be unique per project. Note that you must specify barcode, name, or both for this endpoint to succeed.

.EXAMPLE
Edit-APSNode -ProjectID "fedsjkefio325nrew-efwefn43u3" -TreeID "default" -NodeID "9ed2948d-872f-4e7b-9904-a3703f5908c6" -name "Suite 200"

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/locations-nodesnodeid-PATCH/
#>
function Edit-APSItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$TreeID,
        [Parameter(Mandatory = $true)]
        [string]$NodeID,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Barcode

    )
    # Autodesk API Documentation - [INSERT API DOCS LINK]

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/construction/locations/v2/projects/$($ProjectID)/trees/$($TreeID)/nodes/$($NodeID)"

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Set all mandatory parameters
    $Body["Name"] = $Name
    $Body["Barcode"] = $Barcode

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}