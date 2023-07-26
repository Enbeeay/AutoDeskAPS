
<#
.SYNOPSIS
Query all partner companies.

.DESCRIPTION
Retrieves the account ID from the API and uses it to retrieve all partner companies associated with said ID, returning response directly.

.PARAMETER DesiredColumns
The desired columns to be returned for the Fields table. Must match the names of fields from the API to be autofilled in the returned DT.

.PARAMETER limit
The maximum number of records that this endpoint may return per page.

.PARAMETER offset
Offset of response array

.PARAMETER sort
The sort order for items. Fields can be sorted in either 'asc' (default) or 'desc' order.

.PARAMETER field
Comma-separated fields to include in response

.EXAMPLE
$(Get-APSCompany)[0] | Out-Gridview

Returns a list of 10 companies as a gridview

.NOTES
Currently performs a request to retrieve the account ID that is then used in the main request, making this function perform two different API calls.
Autodesk API Documentation -    https://aps.autodesk.com/en/docs/data/v2/reference/http/hubs-GET/
                                https://aps.autodesk.com/en/docs/bim360/v1/reference/http/companies-GET/
#>
function Get-APSCompany {
    Param(
        #Change default column names for request
        [string[]] $DesiredColumns = ("id", "account_id", "name", "trade", "address_line_1", "address_line_2",
            "city", "state_or_province", "postal_code", "country", "phone", "website_url", "description", "erp_id", "tax_id"),

        # Add filter params on API, differing behaviors (Bulk vs Update), etc.
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

    # Use the helper function New-APSDT to create a datatable for the Company data
    [System.Data.DataTable]$CompanyTable = New-APSDT -DesiredColumns $DesiredColumns

    # Initialize and fill out query string parameters
    $Body = @{}
    if ($limit) { $Body["limit"] = $limit }
    if ($offset) { $Body["offset"] = $offset }
    if ($sort) { $Body["sort"] = $sort }
    if ($field) { $Body["field"] = $field }

    # Obtain the list of all Company Info
    $CompanyListUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$($hubID.Substring(2))/companies"
    $CompanyList = Invoke-Restmethod -Method GET -Uri $CompanyListUrl -Header @{ "Authorization" = "Bearer $($2LegTok)" } -Body $Body

    # Fill out table with metadata
    foreach ($Company in $CompanyList) {
        # Populate DT
        $row = $CompanyTable.NewRow()
        foreach ($column in $CompanyTable.Columns) {
            $row[$column] = $Company.$column
        }
        $CompanyTable.Rows.Add($row)
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $CompanyTable
}


