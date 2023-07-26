

<#
.SYNOPSIS
Initializes an APS Webhook

.DESCRIPTION
Combines the two different POST requests for initializing a webhook monitoring one event or all.

.PARAMETER requestType
Type of POST request, either a global hook ("All") or an event-based hook ("Event")

.PARAMETER system
The system for the hook to monitor.
For example: 'data' for Data Management

.PARAMETER eventType
The type of event to monitor. Mandatory for requestType 'Event'

.PARAMETER callbackUrl
Callback URL registered for the webhook.

.PARAMETER scope
An object that represents the extent to where the event is monitored.
Please refer to the individual event specification pages on APS Docs for valid scopes.

.PARAMETER hookAttribute
A user-defined JSON object, which you can use to store/set some custom information.
The maximum size of the JSON object (content) should be less than 1KB.

.PARAMETER filter
JsonPath expression that can be used by you to filter the callbacks you receive.

.PARAMETER hubId
Hub ID corresponds to an account ID in the BIM 360 API, prefixed by “b.”

.PARAMETER ProjectID
Project ID corresponds to the project ID in the BIM 360 API, prefixed by “b.”

.PARAMETER tenant
The tenant that the event is from.
If the tenant is specified on the hook, then either the tenant or the scopeValue of the event must match the tenant of the hook.

.PARAMETER autoReactivateHook
Optional. Flag to enable the hook for the automatic reactivation flow.

.PARAMETER hookExpiry
Optional. ISO8601 formatted date and time when the hook should expire and automatically be deleted.
Not providing this parameter means the hook never expires.

.PARAMETER callbackWithEventPayloadOnly
Optional. If “true”, the callback request payload only contains the event payload, without additional information on the hook.
Hook attributes will not be accessible if this is “true”. Defaults to “false”.

.EXAMPLE
Add-APSWebhook -requestType "All" -system "cost" -callbackUrl $callback -scope $(@{"project" = $ProjectID })

Initializes a project-wide webhook that activates upon any event in the cost management system and sends to the url $callback.

.NOTES
Autodesk API Documentation -    https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/systems-system-events-event-hooks-POST/
                                https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/systems-system-hooks-POST/
#>
function Add-APSWebhook {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Event", "All")]
        $requestType,
        [Parameter(Mandatory = $true)]
        $system,
        $eventType, # Mandatory for Event

        # Other Mandatory Parameters
        [Parameter(Mandatory = $true)]
        $callbackUrl,
        [Parameter(Mandatory = $true)]
        $scope, #Pass in a hashtable

        # Optional parameters
        $hookAttribute,
        [string]$filter,
        [string]$hubId,
        [Alias("containerId")]
        [string]$ProjectID,
        [string]$tenant,
        [bool]$autoReactivateHook,
        [string]$hookExpiry,
        [bool]$callbackWithEventPayloadOnly
    )

    if ($system -eq "cost") { $system = "autodesk.construction.cost" }

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Enter one of the two execution paths
    if ($requestType -eq "Event") {
        if (!$event) {
            Write-Error "The parameter 'event' is required to be initialized for requestType 'Event'"
            return
        }

        # Event Request
        $POSTUrl = "https://developer.api.autodesk.com/webhooks/v1/systems/$($system)/events/$($eventType)/hooks"
    }
    else {
        # All events Request
        $POSTUrl = "https://developer.api.autodesk.com/webhooks/v1/systems/$($system)/hooks"
    }

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["callbackUrl"] = $callbackUrl
    $Body["scope"] = $scope

    # Initialize all optional parameters
    if ($hookAttribute) { $Body["hookAttribute"] = $hookAttribute }
    if ($filter) { $Body["filter"] = $filter }
    if ($hubId) { $Body["hubId"] = $hubId }
    if ($ProjectID) { $Body["ProjectID"] = $ProjectID }
    if ($tenant) { $Body["tenant"] = $tenant }
    if ($autoReactivateHook) { $Body["autoReactivateHook"] = $autoReactivateHook }
    if ($hookExpiry) { $Body["hookExpiry"] = $hookExpiry }
    if ($callbackWithEventPayloadOnly) { $Body["callbackWithEventPayloadOnly"] = $callbackWithEventPayloadOnly }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}