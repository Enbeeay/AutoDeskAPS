
<#
.SYNOPSIS
Connects a budget to a contract.

.DESCRIPTION
Sends a POST request to the APS API to connect a budget and a contract.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER contractId
ID of the contract.

.PARAMETER budgetIdArray
Array of budget IDs.

.EXAMPLE
Join-APSCostContractBudget -ProjectID $ProjectID -contractId $contract -budgetIdArray @($id1, $id2)

Joins the two budgets identified by $id1 and $id2  with the contract $contract.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/bim360/v1/tutorials/cost/link-budgets-and-contract/
#>
function Join-APSCostContractBudget {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$contractId,
        [Parameter(Mandatory = $true)]
        [string[]]$budgetIdArray
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft PATCH message
    # Set the URL per APS docs
    $JOINUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/contracts/$($contractId)"

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize array of hashtables for budget ids
    $budgetArrHash = @()
    foreach ($id in $budgetIdArray) {
        $budgetArrHash += @{"id" = $id }
    }
    # Initialize the Body of the PATCH request
    $Body = @{}
    $Body["budgets"] = $budgetArrHash
    $Body = $Body | ConvertTo-Json


    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $JOINUrl -Header $Header -Body $Body
}