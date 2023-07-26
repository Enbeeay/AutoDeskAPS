
<#
.SYNOPSIS
Updates the specified contract.

.DESCRIPTION
Sends a PATCH request to the APS API to edit the given item.

.PARAMETER ProjectID
The ID of the cost container for the project, AKA the ID for the project.

.PARAMETER ContractID
The contract ID.

.PARAMETER code
Code of the contract.

.PARAMETER name
The name of the item.

.PARAMETER description
A detailed description of the item.

.PARAMETER companyId
The ID of a supplier company. This is the ID of a company managed by BIM 360 Admin.

.PARAMETER type
Type of the contract. For example, consultant or purchase order. Type is customizable by the project admin.

.PARAMETER contactId
Default contact of the supplier. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER signedBy
The user who signed the contract. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER ownerId
The user who is responsible for the purchase. This is the ID of a user managed by BIM 360 Admin.

.PARAMETER mainContractId
The ID of the main contract with which this item is associated.

.PARAMETER retentionCap
The maximum percentage of the total contract amount which can be used as the retention amount.

.PARAMETER status
The status of this contract. Possible values: draft, pending, submitted, revise, sent, signed, executed, closed, inReview

.PARAMETER currency
The code of the currency specified for the contract if it’s awarded in a foreign currency.

.PARAMETER exchangeRate
The final exchange rate for the specified currency, applied as a multiplier of the contract’s base currency. For example, 1 base currency = 0.7455 foreign currency.

.PARAMETER forecastExchangeRate
The forecast exchange rate. Default value is null.

.PARAMETER forecastExchangeRateUpdatedAt
The last time that the forecast exchange rate was updated, in ISO 8601 format.

.PARAMETER integrationState
The lock state of this item in an optional integration of an ERP system (such as SignNow).

.EXAMPLE
Add-APSCostContract -ProjectID $ProjectID -code "MAIN" -name "Test Post Contract" -description "Desc" -type "Unit Price"

Adds a contract to the project $ProjectID with the specified details.

.NOTES
Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/cost-contracts-contractId-PATCH/
#>
function Edit-APSCostContract {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        [string]$ProjectID,
        [Parameter(Mandatory = $true)]
        [string]$ContractID,

        # Add all optional parameters, must include type
        [string]$code,
        [string]$name,
        [string]$description,
        [string]$companyId,
        [string]$type,
        [string]$contactId,
        [string]$signedBy,
        [string]$ownerId,
        [string]$mainContractId,
        [int]$retentionCap,
        [string]$status,
        [string]$currency,
        $exchangeRate,
        $forecastExchangeRate,
        [datetime]$forecastExchangeRateUpdatedAt,
        [string]$integrationState
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft PATCH message
    # Set the URL per APS docs
    $PATCHUrl = "https://developer.api.autodesk.com/cost/v1/containers/$($ProjectID)/contracts/$($ContractID)"

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
    if ($companyId) { $Body["companyId"] = $companyId }
    if ($type) { $Body["type"] = $type }
    if ($contactId) { $Body["contactId"] = $contactId }
    if ($signedBy) { $Body["signedBy"] = $signedBy }
    if ($ownerId) { $Body["ownerId"] = $ownerId }
    if ($mainContractId) { $Body["mainContractId"] = $mainContractId }
    if ($retentionCap) { $Body["retentionCap"] = $retentionCap }
    if ($status) { $Body["status"] = $status }
    if ($currency) { $Body["currency"] = $currency }
    if ($exchangeRate) { $Body["exchangeRate"] = $exchangeRate }
    if ($forecastExchangeRate) { $Body["forecastExchangeRate"] = $forecastExchangeRate }
    if ($forecastExchangeRateUpdatedAt) { $Body["forecastExchangeRateUpdatedAt"] = $forecastExchangeRateUpdatedAt.ToString("o") }
    if ($integrationState) { $Body["integrationState"] = $integrationState }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the PATCH request using the created header and body
    Invoke-Restmethod -Method PATCH -Uri $PATCHUrl -Header $Header -Body $Body
}