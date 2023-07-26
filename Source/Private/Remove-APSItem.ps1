# TEMPLATE REMOVE/DELETE FUNCTION
function Remove-APSItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID
        <# Other URI Parameters like ID of Item
        [Parameter(Mandatory = $true)]
        [string]$id
        #>

        <# Query String Parameters
        $force
        #>
    )
    # Autodesk API Documentation - [INSERT API DOCS LINK]

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "[REPLACE WITH URL]"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Add query string parameters
    if ($force) { $Body["force"] = $force }

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}