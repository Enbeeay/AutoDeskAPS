
<#
.SYNOPSIS
Returns information on an APS Webhook.

.DESCRIPTION
Obtains the information of a specific webhook by ID, returns response directly instead of usual DataTable format.

.PARAMETER system
The system the hook monitors.
For example: 'data' for Data Management

.PARAMETER event
The type of event the hook monitors.

.PARAMETER hook_id
The ID of the webhook to obtain information on.

.EXAMPLE
Get-APSWebhookInfo -system 'cost' -event "budget.created-1.0" -hook_id $webhook | Out-Gridview

Obtains information regarding the budget creation hook $webhook and outputs it as a gridview.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/systems-system-events-event-hooks-hook_id-GET/
#>
function Get-APSWebhookInfo {
    Param(
        [Parameter(Mandatory = $true)]
        $system,
        [Parameter(Mandatory = $true)]
        $event,
        [Alias("hookId")]
        [Parameter(Mandatory = $true)]
        $hook_id
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Sets URL
    $WebhookInfoUrl = "https://developer.api.autodesk.com/webhooks/v1/systems/$($system)/events/$($event)/hooks/$($hook_id)"

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field
    Invoke-Restmethod -Method GET -Uri $WebhookInfoUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
}


