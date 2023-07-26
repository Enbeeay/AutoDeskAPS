
<#
.SYNOPSIS
Create a new partner company.

.DESCRIPTION
Sends a POST request to the APS API to create a new company with the specified parameters.

.PARAMETER name
Company name should be unique under an account

.PARAMETER trade
Trade type based on specialization

.PARAMETER address_line_1
Company address line 1

.PARAMETER address_line_2
Company address line 2

.PARAMETER city
City in which company is located

.PARAMETER state_or_province
State or province in which company is located

.PARAMETER postal_code
Postal code for the company location

.PARAMETER country
Postal code for the company location

.PARAMETER phone
Business phone number for the company

.PARAMETER website_url
Company website

.PARAMETER description
Short description or overview for company

.PARAMETER erp_id
Used to associate a company in BIM 360 with the company data in an ERP system

.PARAMETER tax_id
Used to associate a company in BIM 360 with the company data in an ERP system

.EXAMPLE
Add-APSCompany -name "ACME" -trade "Industry-Specific Manufacturing Processing" -description "Generic Company"

Adds the company "ACME" with the shown parameters to the account. (Untested due to API Call Limit)

.NOTES
Currently performs a request to retrieve the account ID that is then used in the main request, making this function perform two different API calls.
Autodesk API Documentation -    https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET/
                                https://aps.autodesk.com/en/docs/acc/v1/reference/http/companies-POST/
#>
function Add-APSCompany {
    Param(
        # Add other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$name,
        [Parameter(Mandatory = $true)]
        [string]$trade,

        # Add all optional parameters, must include type
        [string]$address_line_1,
        [string]$address_line_2,
        [string]$city,
        $state_or_province,
        [string]$postal_code,
        $country,
        [string]$phone,
        [string]$website_url,
        [string]$description,
        [string]$erp_id,
        [string]$tax_id
    )

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Obtain 2-Legged Authentication Token
    $2LegTok = Get-APS2LegAuth

    # Retrieve Hub UD from API, put into $hubId
    # Set the URL per APS docs
    $hubUrl = "https://developer.api.autodesk.com/project/v1/hubs"
    $hubData = Invoke-Restmethod -Method GET -Uri $hubUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
    $hubID = $hubData.data.id

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$($hubID)/companies"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($2LegTok)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Set all mandatory parameters
    $Body["name"] = $name
    $Body["trade"] = $trade

    # Initialize all optional parameters
    if ($address_line_1) { $Body["address_line_1"] = $address_line_1 }
    if ($address_line_2) { $Body["address_line_2"] = $address_line_2 }
    if ($city) { $Body["city"] = $city }
    if ($state_or_province) { $Body["state_or_province"] = $state_or_province }
    if ($postal_code) { $Body["postal_code"] = $postal_code }
    if ($country) { $Body["country"] = $country }
    if ($phone) { $Body["phone"] = $phone }
    if ($website_url) { $Body["website_url"] = $website_url }
    if ($description) { $Body["description"] = $description }
    if ($erp_id) { $Body["erp_id"] = $erp_id }
    if ($tax_id) { $Body["tax_id"] = $tax_id }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}