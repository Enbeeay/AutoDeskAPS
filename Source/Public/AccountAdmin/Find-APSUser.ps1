<#
.SYNOPSIS
Retrieves user data with search parameters

.DESCRIPTION
Sends a GET request to the APS API to retrieve user data for a given account based off of filters

.PARAMETER AccountID
The ID of the Account that contains the users

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER name
User name to match

.PARAMETER email
User email to match

.PARAMETER company_name
User company to match

.PARAMETER operator
Boolean operator to use: OR (default) or AND

.PARAMETER partial
If true (default), perform a fuzzy match

.PARAMETER sort
Comma-separated fields to sort by in ascending order

Prepending a field with - sorts in descending order.
Invalid fields and whitespaces will be ignored.

.EXAMPLE
Find-APSUser -AccountID $AccountID -email jbezos@amazon.com -company_name Amazon

.NOTES
Alternative to Get-APSUser
#>
function Find-APSUser {
    Param(
        [Parameter(Mandatory = $true)]
        $AccountID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("User_ID"<#Alias for 'id'#>, "Account_ID", "Role", "Status", "Company_ID", "Company_Name",
            "Last_Sign_In", "Email", "Display_Name"<#Alias for 'name'#>, "Nickname", "First_name", "Last_Name", "UID", "Image_Url",
            "Address_Line_1", "Address_Line_2", "City", "State_Or_Province", "Postal_Code", "Country", "Phone", "Company", "Job_Title",
            "Industry", "About_Me", "Created_At", "Updated_At"),

        $name,
        $email,
        $company_name,
        $operator,
        $partial,
        $sort

    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/users-search-GET/

    # Retrieve access token information stored in the PasswordState API
    $2LegTok = Get-APS2LegAuth

    # Retrieve data from API, put into $UserArray

    # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
    $UserUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$($AccountID)/users/search"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "100" }

    # Include all query string parameters that are 'filters' and any other necessary parameters
    # FOR FILTERS -             if($parameterName) { $Body["parameterName]"] = $parameterName}
    # FOR OTHER PARAMETERS -    if($parameterName) { $Body["parameterName"] = $parameterName}
    # Example Initialization    Notes: Always convert datetime attributes to strings
    if($name) { $Body["name"] = $name
    }
    if($email) { $Body["email"] = $email
    }
    if($company_name) { $Body["company_name"] = $company_name
    }
    if($operator) { $Body["operator"] = $operator
    }
    if($partial) { $Body["partial"] = $partial
    }
    if($sort) { $Body["sort"] = $sort
    }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialUser = Invoke-Restmethod -Method GET -Uri $UserUrl -Header @{ "Authorization" = "Bearer $($2LegTok)" } -Body $Body

    # Initialize an ArrayList for the response
    $UserArray = [System.Collections.ArrayList]::new()
    [void]$UserArray.Add($initialUser)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempUser = $initialUser
    while(![string]::IsNullOrWhiteSpace($tempUser.pagination.nextUrl)) {
        $tempUser = Invoke-Restmethod -Method GET -Uri $tempUser.pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
        [void]$UserArray.Add($tempUser)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $UserArray
    [System.Data.DataTable]$UserTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the UserArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach($UserPage in $UserArray) {
        # Iterate through the pages of the ArrayList
        foreach($User in $UserPage) {
            # Iterate through each individual User and create rows
            $row = $UserTable.NewRow()
            foreach($column in $UserTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $User.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id
            $row["User_ID"] = $user.id
            $row["Display_Name"] = $user.name
            # Add populated row to the datatable
            $UserTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $UserTable
    #>
}


