# TEMPLATE ADD/POST FUNCTION
function Add-APSItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID

        <# Add other mandatory parameters
        [Parameter(Mandatory=$true)]
        [string]$code,
        [Parameter(Mandatory=$true)]
        [string]$name,
        #>

        <# Add all optional parameters, must include type
        [string]$parentId,
        [int]$quantity,
        [int]$inputQuantity,
        [string]$description,
        ...
        [string]$integrationState
        #>
    )
    # Autodesk API Documentation - [INSERT API DOCS LINK]

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "[REPLACE WITH URL]"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget POST
    # $code = $code.PadRight(20)

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Add query string parameters
    # if ($force) { $Body["force"] = $force }

    # Set all mandatory parameters
    $Body["mandatoryParam1"] = $mandatoryParam1
    $Body["mandatoryParam2"] = $mandatoryParam2

    # Initialize all optional parameters
    if ($optionalParam1) { $Body["optionalParam1"] = $optionalParam1 }
    if ($optionalParam2) { $Body["optionalParam2"] = $optionalParam2 }
    if ($optionalParam3) { $Body["optionalParam3"] = $optionalParam3 }
    if ($optionalParam4) { $Body["optionalParam4"] = $optionalParam4 }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}