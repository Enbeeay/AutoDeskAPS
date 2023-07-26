
<#
.SYNOPSIS
Creates/Finds an attachment folder

.DESCRIPTION
Find or create an attachment folder in BIM 360 Docs for a given item. That folder will save local files as attachments to the item. Files are saved using the Storage service.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER associationId
The object ID of the item associated to. For example, ID of the budget, contract or cost item.

.PARAMETER associationType
The type of the item with which the attachment is associated. Possible Values: Budget, Contract, FormInstance, CostItem, Payment, MainContract, BudgetPayment.

.EXAMPLE
Add-APSCostCompanyFolder -ProjectID $ProjectID -associationId $budgetId -associationType "Budget"

Finds/Creates an attachment folder associated with the budget $budgetId in project $ProjectID

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-attachment-folders-POST/
#>
function Add-APSCostCompanyFolder {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        $associationId,
        [Parameter(Mandatory = $true)]
        $associationType
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/attachment-folders"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["associationId"] = $associationId
    $Body["associationType"] = $associationType

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}