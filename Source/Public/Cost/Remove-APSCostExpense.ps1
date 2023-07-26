
<#
.SYNOPSIS
Deletes a contract item specified by ID.

.DESCRIPTION
Sends a DELETE request to the APS API to remove the specified item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER expenseId
ID of the expense to be removed.

.EXAMPLE
Remove-APSCostExpense -ProjectID $ProjectID -expenseId

Deletes the specified Expense object in the project.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-id-DELETE/
#>
function Remove-APSCostExpense {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        # Other URI Parameters like ID of CostExpense
        [Parameter(Mandatory = $true)]
        [string]$expenseId
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft DELETE message
    # Set the URL per APS docs
    $DELETEUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses/$expenseId"

    # Initialize the header of the DELETE request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the DELETE request
    $Body = @{}

    # Add query string parameters
    if ($force) { $Body["force"] = $force }

    # Send off the DELETE request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $DELETEUrl -Header $Header -Body $Body
}