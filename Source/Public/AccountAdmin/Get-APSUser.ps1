<#
.SYNOPSIS
Retrieves user data

.DESCRIPTION
Sends a GET request to the APS API to retrieve user data for a given account

.PARAMETER AccountID
The ID of the Account that contains the users

.PARAMETER DesiredColumns
The columns of data that the requester wishes to retrieve (defaults to all columns)

.PARAMETER sort
The column that the user wishes to sort by

.EXAMPLE
Get-APSUser -AccountID $AccountID

.NOTES
"User_ID"(alias for 'id'),
"Account_ID",
"Role",
"Status",
"Company_ID",
"Company_Name",
"Last_Sign_In",
"Email",
"Display_Name"(alias for 'name'),
"Nickname",
"First_name",
"Last_Name",
"UID",
"Image_Url",
"Address_Line_1",
"Address_Line_2",
"City",
"State_Or_Province",
"Postal_Code",
"Country",
"Phone",
"Company",
"Job_Title",
"Industry",
"About_Me",
"Created_At",
"Updated_At"
#>

function Get-APSUser {
    Param(
        [Alias("account_id")]
        [Parameter(Mandatory = $true)]
        $AccountID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("User_ID"<#Alias for 'id'#>, "Account_ID", "Role", "Status", "Company_ID", "Company_Name",
            "Last_Sign_In", "Email", "Display_Name"<#Alias for 'name'#>, "Nickname", "First_name", "Last_Name", "UID", "Image_Url",
            "Address_Line_1", "Address_Line_2", "City", "State_Or_Province", "Postal_Code", "Country", "Phone", "Company", "Job_Title",
            "Industry", "About_Me", "Created_At", "Updated_At"),


        $sort
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/users-GET/

    # Retrieve access token information stored in the PasswordState API
    $2LegTok = Get-APS2LegAuth

    # Retrieve data from API, put into $UserArray
    $UserUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountID/users"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ "limit" = "100" }

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
            $row["User_ID"] = $user.id
            $row["Display_Name"] = $user.name
            # Add populated row to the datatable
            $UserTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $UserTable

}