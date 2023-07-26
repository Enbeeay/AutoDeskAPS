
<#
.SYNOPSIS
Updates the specified expense.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER expenseId
ID of the expense to be edited.

.PARAMETER budgetPaymentId
ID of the Budget Pay App to which the expense belongs.

.PARAMETER supplierId
The supplier for the expense. This is the ID of a company managed by BIM 360 Admin.

.PARAMETER supplierName
The supplier company name for the expense. Any company can be used regardless the ones added in Account Administration. Required if supplierId is not set.

.PARAMETER number
The auto-generated sequence number for the expense.

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER note
Additional notes to the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER term
The term of the expense. This is customizable by the project administrator.

.PARAMETER referenceNumber
The user-provided reference number of the expense.

.PARAMETER type
The type of the expense. This is customizable by the project administrator.

.PARAMETER scope
The applicable scope of the expense. Possible values: full, partial.

.PARAMETER purchasedBy
The user who purchased the expense. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER status
The applicable scope of the expense. Possible values: full, partial.

.PARAMETER paymentDue
The payment due date of the item.

.PARAMETER issuedAt
The date and time when the expense was issued.

.PARAMETER receivedAt
The date and time when the expense was received.

.PARAMETER paymentType
The payment type of the payment application. It could be something like Check, Cheque, or Electronic Transfer and is provided by the integrated ERP system.

.PARAMETER paymentReference
The check/cheque number or electronic transfer number of the payment associated with this expense.

.PARAMETER aggregateBy
The aggregate type of the expense. Possible values: workCompleted, materialsOnSite, workCompletedQty.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalMessage
A message that explains the sync status of the ERP integration with the BIM 360 Cost module.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Add-APSCostExpense -ProjectID $ProjectID -name "POST Exp" -supplierName "TestSupplier" -description "DESC"

Adds an expense to the given project under the supplier name "TestSupplier", which is not linked to a supplier account.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-expenses-id-PATCH/

#>
function Edit-APSCostExpense {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,

        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$expenseId,

        # Add all optional parameters, must include type
        [string]$budgetPaymentId,
        [string]$supplierId,
        [string]$supplierName,
        [string]$number,
        [string]$name,
        [string]$description,
        [string]$note,
        [string]$term,
        [string]$referenceNumber,
        [string]$type,
        [string]$scope,
        [string]$purchasedBy,
        [string]$status,
        [string]$paymentDue,
        [string]$issuedAt,
        [string]$receivedAt,
        [string]$paymentType,
        [string]$paymentReference,
        [string]$aggregateBy,
        [string]$externalId,
        [string]$externalSystem,
        [string]$externalMessage,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "	https://developer.api.autodesk.com/cost/v1/containers/$ProjectID/expenses/$expenseId"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Initialize all optional parameters
    if ($budgetPaymentId) { $Body["budgetPaymentId"] = $budgetPaymentId }
    if ($supplierId) { $Body["supplierId"] = $supplierId }
    if ($supplierName) { $Body["supplierName"] = $supplierName }
    if ($number) { $Body["number"] = $number }
    if ($name) { $Body["name"] = $name }
    if ($description) { $Body["description"] = $description }
    if ($note) { $Body["note"] = $note }
    if ($term) { $Body["term"] = $term }
    if ($referenceNumber) { $Body["referenceNumber"] = $referenceNumber }
    if ($type) { $Body["type"] = $type }
    if ($scope) { $Body["scope"] = $scope }
    if ($purchasedBy) { $Body["purchasedBy"] = $purchasedBy }
    if ($status) { $Body["status"] = $status }
    if ($paymentDue) { $Body["paymentDue"] = $paymentDue }
    if ($issuedAt) { $Body["issuedAt"] = $issuedAt }
    if ($receivedAt) { $Body["receivedAt"] = $receivedAt }
    if ($paymentType) { $Body["paymentType"] = $paymentType }
    if ($paymentReference) { $Body["paymentReference"] = $paymentReference }
    if ($aggregateBy) { $Body["aggregateBy"] = $aggregateBy }
    if ($externalId) { $Body["externalId"] = $externalId }
    if ($externalSystem) { $Body["externalSystem"] = $externalSystem }
    if ($externalMessage) { $Body["externalMessage"] = $externalMessage }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}