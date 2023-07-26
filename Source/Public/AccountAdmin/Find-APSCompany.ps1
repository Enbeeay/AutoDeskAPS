
<#
.SYNOPSIS
Returns a list of filtered companies.

.DESCRIPTION
Search partner companies in a specific BIM 360 account by name and other such parameters.

.PARAMETER DesiredColumns
The desired columns to be returned for the Fields table. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER name
Company name should be unique under an account

.PARAMETER trade
Trade type based on specialization

.PARAMETER operator
Boolean operator to use: OR (default) or AND

.PARAMETER partial
If true (default), perform a fuzzy match

.PARAMETER limit
Response array’s size
Default value: 10
Max limit: 100

.PARAMETER offset
Offset of response array
Default value: 0

.PARAMETER sort
Comma-separated fields to sort by in ascending order

Prepending a field with - sorts in descending order.
Invalid fields and whitespaces will be ignored.

.PARAMETER field
Comma-separated fields to include in response
id will always be returned.

.EXAMPLE
$(Find-APSCompany -name "IS" -limit 100) | Out-GridView

Outputs a list of up to 100 company entries with "IS" in the name as a gridview.

.NOTES
Currently performs a request to retrieve the account ID that is then used in the main request, making this function perform two different API calls.
Autodesk API Documentation -  https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET/
                              https://aps.autodesk.com/en/docs/acc/v1/reference/http/companies-search-GET/
#>
function Find-APSCompany {
    Param(
        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "account_id", "name", "trade", "address_line_1", "address_line_2",
            "city", "state_or_province", "postal_code", "country", "phone", "website_url", "description", "created_at", "updated_at", "erp_id", "tax_id"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $name,
        $trade,
        $operator,
        $partial,
        $limit,
        $offset,
        $sort,
        $field
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

    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $CompanyUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$($hubID)/companies/search"

    # Initialize the Body of the GET request
    $Body = @{}

    # Include all query string parameters that are 'filters' and any other necessary parameters
    if ($name) { $Body["name"] = $name }
    if ($trade) { $Body["trade"] = $trade }
    if ($operator) { $Body["operator"] = $operator }
    if ($partial) { $Body["partial"] = $partial }
    if ($limit) { $Body["limit"] = $limit }
    if ($offset) { $Body["offset"] = $offset }
    if ($sort) { $Body["sort"] = $sort }
    if ($field) { $Body["field"] = $field }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialCompany = Invoke-Restmethod -Method GET -Uri $CompanyUrl -Header @{ "Authorization" = "Bearer $($2LegTok)" } -Body $Body

    # Initialize an ArrayList for the response
    $CompanyArray = [System.Collections.ArrayList]::new()
    [void]$CompanyArray.Add($initialCompany)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempCompany = $initialCompany
    while (![string]::IsNullOrWhiteSpace($tempCompany.pagination.nextUrl)) {
        $tempCompany = Invoke-Restmethod -Method GET -Uri $tempCompany.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$CompanyArray.Add($tempCompany)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $CompanyArray
    [System.Data.DataTable]$CompanyTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the CompanyArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach ($CompanyPage in $CompanyArray) {
        # Iterate through the pages of the ArrayList
        foreach ($Company in $CompanyPage) {
            # Iterate through each individual Company and create rows
            $row = $CompanyTable.NewRow()
            foreach ($column in $CompanyTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Company.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $CompanyTable.Rows.Add($row)
        }
    }
    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CompanyTable
}