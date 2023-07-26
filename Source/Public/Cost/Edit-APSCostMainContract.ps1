
<#
.SYNOPSIS
Edits the main contract item in a specified project

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER mainContractId
ID of the main contract.

.PARAMETER code
Code of the main contract.

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER type
Type of the main contract, unknown possible values.

.PARAMETER contactId
Default contact of the supplier. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER ownerId
The user who is responsible for the purchase. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER ownerCompanyId
Further information unavailable.

.PARAMETER ownerContactId
Further information unavailable.

.PARAMETER contractorCompanyId
Further information unavailable.

.PARAMETER contractorContactId
Further information unavailable.

.PARAMETER architectCompanyId
Further information unavailable.

.PARAMETER architectContactId
Further information unavailable.

.PARAMETER notaryCompanyId
Further information unavailable.

.PARAMETER notaryContactId
Further information unavailable.

.PARAMETER signedBy
The user who signed the contract. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER amount
Further information unavailable.

.PARAMETER retentionCap
The maximum percentage of the total contract amount which can be used as the retention amount.

.PARAMETER status
Status of the main contract, unknown possible values.

.PARAMETER creatorId
Further information unavailable.

.PARAMETER revised
Further information unavailable.

.PARAMETER scopeOfWork
Scope of work of the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER note
Additional notes to the item. This is a Draftjs formatted rich text (https://draftjs.org/).

.PARAMETER submitted
Further information unavailable.

.PARAMETER received
Further information unavailable.

.PARAMETER unReceived
Further information unavailable.

.PARAMETER remaining
Further information unavailable.

.PARAMETER paid
Further information unavailable.

.PARAMETER paymentsCount
Further information unavailable.

.PARAMETER paymentDue
The payment due date of the item.

.PARAMETER paymentDueType
Further information unavailable.

.PARAMETER recipients
Further information unavailable.

.PARAMETER executedDate
Further information unavailable.

.PARAMETER startDate
Further information unavailable.

.PARAMETER plannedCompletionDate
Further information unavailable.

.PARAMETER actualCompletionDate
Further information unavailable.

.PARAMETER externalId
The ID of the item in its original external system. You can use this ID to track the source of truth or to look up the data in an integrated system.

.PARAMETER externalSystem
The name of the external system. You can use this name to track the source of truth or to search in an integrated system.

.PARAMETER externalMessage
A message that explains the sync status of the ERP integration with the BIM 360 Cost module.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.PARAMETER isDefault
Toggles whether this main contract is the default or not.

.PARAMETER locked
Further information unavailable.

.PARAMETER allowOverbilling
Further information unavailable.

.EXAMPLE
Edit-APSCostMainContract  -ProjectID $ProjectID -mainContractId $main -name "Test PATCH"

Edits the main contract $main to have the name "Test PATCH"

.NOTES
Autodesk API Documentation - no documentation exists (as of 06/21/2023)
All parameters are entirely experimental, rigorous testing was not performed :)
#>
function Edit-APSCostMainContract {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$mainContractId,

        # Add all optional parameters (These are educated guesses at best)
        [string]$code,
        [string]$name,
        [string]$description,
        [string]$type,
        [string]$contactId,
        [string]$ownerId,
        [string]$ownerCompanyId,
        [string]$ownerContactId,
        [string]$contractorCompanyId,
        [string]$contractorContactId,
        [string]$architectCompanyId,
        [string]$architectContactId,
        [string]$notaryCompanyId,
        [string]$notaryContactId,
        [string]$signedBy,
        $amount,
        [int]$retentionCap,
        [string]$status,
        $creatorId,
        $revised,
        $scopeOfWork,
        $note,
        $submitted,
        $received,
        $unReceived,
        $remaining,
        $paid,
        $paymentsCount,
        $paymentDue,
        $paymentDueType,
        $recipients,
        [datetime]$executedDate,
        [datetime]$startDate,
        [datetime]$plannedCompletionDate,
        [datetime]$actualCompletionDate,
        [string]$externalId,
        [string]$externalSystem,
        [string]$externalMessage,
        [string]$integrationState,
        $isDefault,
        $locked,
        $allowOverbilling
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/main-contracts/$($mainContractId)"

    # Perform any compatibility functions if applicable, such as the below padding
    # Pad the code to 20 characters to work with Budget PATCH
    # $code = $code.PadRight(20)

    # Initialize the header of the PATCH request
    $Header = @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the PATCH request
    $Body = @{}

    # Initialize all optional parameters
    if ($code) { $Body["code"] = $code }
    if ($name) { $Body["name"] = $name }
    if ($description) { $Body["description"] = $description }
    if ($type) { $Body["type"] = $type }
    if ($contactId) { $Body["contactId"] = $contactId }
    if ($ownerId) { $Body["ownerId"] = $ownerId }
    if ($ownerCompanyId) { $Body["ownerCompanyId"] = $ownerCompanyId }
    if ($ownerContactId) { $Body["ownerContactId"] = $ownerContactId }
    if ($contractorCompanyId) { $Body["contractorCompanyId"] = $contractorCompanyId }
    if ($contractorContactId) { $Body["contractorContactId"] = $contractorContactId }
    if ($architectCompanyId) { $Body["architectCompanyId"] = $architectCompanyId }
    if ($architectContactId) { $Body["architectContactId"] = $architectContactId }
    if ($notaryCompanyId) { $Body["notaryCompanyId"] = $notaryCompanyId }
    if ($notaryContactId) { $Body["notaryContactId"] = $notaryContactId }
    if ($signedBy) { $Body["signedBy"] = $signedBy }
    if ($amount) { $Body["amount"] = $amount }
    if ($retentionCap) { $Body["retentionCap"] = $retentionCap }
    if ($status) { $Body["status"] = $status }
    if ($creatorId) { $Body["creatorId"] = $creatorId }
    if ($revised) { $Body["revised"] = $revised }
    if ($scopeOfWork) { $Body["scopeOfWork"] = $scopeOfWork }
    if ($note) { $Body["note"] = $note }
    if ($submitted) { $Body["submitted"] = $submitted }
    if ($received) { $Body["received"] = $received }
    if ($unReceived) { $Body["unReceived"] = $unReceived }
    if ($remaining) { $Body["remaining"] = $remaining }
    if ($paid) { $Body["paid"] = $paid }
    if ($paymentsCount) { $Body["paymentsCount"] = $paymentsCount }
    if ($paymentDue) { $Body["paymentDue"] = $paymentDue }
    if ($paymentDueType) { $Body["paymentDueType"] = $paymentDueType }
    if ($recipients) { $Body["recipients"] = $recipients }
    if ($executedDate) { $Body["executedDate"] = $executedDate.ToString("o") }
    if ($startDate) { $Body["startDate"] = $startDate.ToString("o") }
    if ($plannedCompletionDate) { $Body["plannedCompletionDate"] = $plannedCompletionDate.ToString("o") }
    if ($actualCompletionDate) { $Body["actualCompletionDate"] = $actualCompletionDate.ToString("o") }
    if ($externalId) { $Body["externalId"] = $externalId }
    if ($externalSystem) { $Body["externalSystem"] = $externalSystem }
    if ($externalMessage) { $Body["externalMessage"] = $externalMessage }
    if ($integrationState) { $Body["integrationState"] = $integrationState }
    if ($isDefault) { $Body["isDefault"] = $isDefault }
    if ($locked) { $Body["locked"] = $locked }
    if ($allowOverbilling) { $Body["allowOverbilling"] = $allowOverbilling }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}