
<#
.SYNOPSIS
Retrieves a paginated list of webhooks.

.DESCRIPTION
Returns a DataTable containing information on webhooks either globally, for a specified system, or for a specified event.
Combines the three different GET requests for obtaining a list of all hooks for specific scopes

.PARAMETER requestType
Selects the type of GET request to send off.
Possible values: SystemEvent, System, All

.PARAMETER system
The system the hook monitors.
For example: 'data' for Data Management

.PARAMETER eventType
The type of event the hook monitors.

.PARAMETER scopeName
Scope name used to create hook. For example: folder

.PARAMETER scopeValue
Scope value used to create hook.
If scopeValue is present then scopeName must be present, otherwise scopeValue would be ignored.

.PARAMETER pageState
Base64 encoded string used to return the next page of the list of webhooks.

.PARAMETER status
Status of the hooks. Options: ‘active’, ‘inactive’

.PARAMETER DesiredColumns
The desired columns to be returned for the datatable.
Must match the names of fields from the API to be autofilled in the returned DT.

.EXAMPLE
$(Get-APSWebhookList -requestType "All")[0] | Out-GridView

Outputs a DT of all webhooks in a gridview.

.EXAMPLE
$(Get-APSWebhookList -requestType "System" -system 'cost')[0] | Out-GridView

Outputs a DT of all webhooks in the cost management system as a gridview.

.EXAMPLE
$(Get-APSWebhookList -requestType "SystemEvent" -system 'cost' -eventType 'budget.created-1.0')[0] | Out-GridView

Outputs a DT of webhooks in the cost management system monitoring budget creation as a gridview.

.NOTES
 Autodesk API Documentation -   https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/systems-system-events-event-hooks-GET/
                                https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/systems-system-hooks-GET/
                                https://aps.autodesk.com/en/docs/webhooks/v1/reference/http/webhooks/hooks-GET/
#>
function Get-APSWebhookList {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("SystemEvent", "System", "All")]
        $requestType,

        $system, # Mandatory for SystemEvent and System
        $eventType, # Mandatory for SystemEvent

        # Optional Parameters,
        $scopeName, # Only for SystemEvent
        $scopeValue, # Only for SystemEvent
        $pageState,
        $status,

        # Change default column names for request
        [string[]] $DesiredColumns = ("hookId", "callbackUrl", "createdBy", "createdDate", "lastUpdatedDate", "event",
            "scope", "status", "urn", "autoReactivateHook", "hubId", "projectId", "hookExpiry", "__self__")
    )

    if ($system -eq "cost") { $system = "autodesk.construction.cost" }

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Initialize the Body of the GET request
    $Body = @{}

    # Enter one of the three execution paths
    if ($requestType -eq "SystemEvent") {
        if (!$system -or !$event) {
            Write-Error "The parameters 'system' and 'event' are required to be initialized for requestType 'SystemEvent'"
            return
        }

        # SystemEvent Request
        $WebhookListUrl = "https://developer.api.autodesk.com/webhooks/v1/systems/$($system)/events/$($eventType)/hooks"

        # Initialize the optional parameters specific to SystemEvent
        if ($scopeName) { $Body["scopeName"] = $scopeName }
        if ($scopeValue) { $Body["scopeValue"] = $scopeValue }
    }
    elseif ($requestType -eq "System") {
        if (!$system) {
            Write-Error "The parameter 'system' is required to be initialized for requestType 'System'"
            return
        }

        # System Request
        $WebhookListUrl = "https://developer.api.autodesk.com/webhooks/v1/systems/$($system)/hooks"
    }
    else {
        # All Request
        $WebhookListUrl = "https://developer.api.autodesk.com/webhooks/v1/hooks"
    }

    # Initialize the universal optional parameters
    if ($pageState) { $Body["pageState"] = $pageState }
    if ($status) { $Body["status"] = $status }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialWebhookList = Invoke-Restmethod -Method GET -Uri $WebhookListUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $WebhookListArray = [System.Collections.ArrayList]::new()
    [void]$WebhookListArray.Add($initialWebhookList.data)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempWebhookList = $initialWebhookList
    while (![string]::IsNullOrWhiteSpace($tempWebhookList.pagination.nextUrl)) {
        $tempWebhookList = Invoke-Restmethod -Method GET -Uri $tempWebhookList.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$WebhookListArray.Add($tempWebhookList.data)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $WebhookListArray
    [System.Data.DataTable]$WebhookListTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the WebhookListArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($WebhookListPage in $WebhookListArray) {
        # Iterate through the pages of the ArrayList
        foreach ($WebhookList in $WebhookListPage) {
            # Iterate through each individual WebhookList and create rows
            $row = $WebhookListTable.NewRow()
            foreach ($column in $WebhookListTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $WebhookList.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $WebhookListTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $WebhookListTable
}


