
<#
.SYNOPSIS
Edits an existing APS Webhook

.DESCRIPTION
Sends a PATCH request to edit an APS Webhook

.PARAMETER system
The system the hook monitors.
For example: 'data' for Data Management

.PARAMETER eventType
The type of event the hook monitors.

.PARAMETER hook_id
The ID of the webhook.

.PARAMETER status
active if webhook is active; otherwise inactive

.PARAMETER filter
JsonPath expression that can be used by you to filter the callbacks you receive.

.PARAMETER hookAttribute
A user-defined JSON object, which you can use to store/set some custom information. The maximum size of the JSON object (content) should be less than 1KB

.PARAMETER token
A secret token that is used to generate a hash signature, which is passed along with notification requests to the callback URL

.PARAMETER autoReactivateHook
Flag to enable the hook for the automatic reactivation flow.

.PARAMETER hookExpiry
ISO8601 formatted date and time when the hook should expire and automatically be deleted.

.EXAMPLE
Edit-APSWebhook -system 'cost' -eventType "budget.created-1.0" -hook_id $webhook -status 'inactive'

Deactivates the hook $webhook monitoring budget creations.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/systems-system-events-event-hooks-hook_id-PATCH/
#>
function Edit-APSWebhook {
    Param(
        [Parameter(Mandatory = $true)]
        $system,
        [Parameter(Mandatory = $true)]
        $eventType,
        [Alias("hookId")]
        [Parameter(Mandatory = $true)]
        $hook_id,

        [string]$status,
        [string]$filter,
        $hookAttribute,
        [string]$token,
        [bool]$autoReactivateHook,
        [string]$hookExpiry
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/webhooks/v1/systems/$($system)/events/$($eventType)/hooks/$($hook_id)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Initialize all optional parameters
    if ($status) { $Body["status"] = $status }
    if ($filter) { $Body["filter"] = $filter }
    if ($hookAttribute) { $Body["hookAttribute"] = $hookAttribute }
    if ($token) { $Body["token"] = $token }
    if ($autoReactivateHook) { $Body["autoReactivateHook"] = $autoReactivateHook }
    if ($hookExpiry) { $Body["hookExpiry"] = $hookExpiry }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}