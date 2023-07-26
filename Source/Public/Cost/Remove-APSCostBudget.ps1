
<#
.SYNOPSIS
Deletes a budget.

.DESCRIPTION
Sends a DELETE request to the APS API to remove the specified item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER budgetId
ID of the budget to be removed.

.PARAMETER force
This request forces an override of locking so the request can succeed.

.EXAMPLE
Remove-APSCostBudget -ProjectID $ProjectID -budgetId $budget

Deletes the specified Budget object in the project.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-budgets-budgetId-DELETE/
#>
function Remove-APSCostBudget {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$budgetId,

        $force
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft DELETE message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/budgets/$($budgetId)"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }

    # Initialize the Body of the POST request
    $Body = @{}

    # Add query string parameters
    if ($force) { $Body["force"] = $force }

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method DELETE -Uri $POSTUrl -Header $Header -Body $Body
}