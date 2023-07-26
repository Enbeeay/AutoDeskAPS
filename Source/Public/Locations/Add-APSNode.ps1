function Add-APSNode {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$TreeID,
        [string]$TargetNodeID,
        [string]$InsertOption,
        [string]$ParentID,
        [string]$type,
        [string]$name,
        [string]$description,
        [string]$barcode
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/locations-nodes-POST/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/construction/locations/v2/projects/$($ProjectID)/trees/$($TreeID)/nodes"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Add query string parameters
    if ($TargetNodeID) { $Body["TargetNodeID"] = $TargetNodeID
    }
    if ($InsertOption) { $Body["InsertOption"] = $InsertOption
    }

    # Set all mandatory parameters
    $Body["ParentID"] = $ParentID
    $Body["Type"] = $Type
    $Body["Name"] = $Name

    # Initialize all optional parameters
    if ($description) { $Body["description"] = $description
    }
    if ($Barcode) { $Body["Barcode"] = $Barcode
    }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}

