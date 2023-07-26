
<#
.SYNOPSIS
Deletes an expense item from the specified expense of a given project.

.DESCRIPTION
Sends a DELETE request to the APS API to remove the specified item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER expenseId
The unique ID of the expense to which the expense item belongs. You can obtain this ID from the response to the POST expenses or GET expenses endpoint.

.PARAMETER itemId
The object ID of the expense item.

.EXAMPLE
Remove-APSCostExpenseItem -ProjectID $ProjectID -expenseId $expense -itemId $item

Deletes the expense item $item under the expense $expense in the project.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-expenseId-items-id-DELETE/
#>
function Remove-APSCostExpenseItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$expenseId,

        # Other URI Parameters like ID of CostExpenseItem
        [Parameter(Mandatory = $true)]
        [string]$itemId
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses/$expenseId/items/$itemId"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}