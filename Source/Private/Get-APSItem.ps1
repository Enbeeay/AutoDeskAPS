# TEMPLATE GET FUNCTION
function Get-APSItem {
    Param(
        [Alias("containerId")]
        [Parameter(Mandatory = $true)]
        $ProjectID,

        #Change default column names for request
        [string[]] $DesiredColumns = ("ExampleCol1", "ExampleCol2", "ExampleCol3")

        <# Add filter params on API, differing behaviors (Bulk vs Update), etc.
        $optionalParam1,
        $optionalParam2,
        $optionalParam3,
        ...
        $optionalParam4
        #>
    )
    # Autodesk API Documentation - [INSERT API DOCS LINK]

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $[Item]Array
    <# Uncomment code lines and replace instances of [Item] and .results with
        appropriate SINGULAR terminology (i.e. Form, Asset, Contract, etc.) and
        appropriate data field of the returned JSON (i.e. .data, .results, .etc) respectively #>

    <#
        # Visit Autodesk API Documentation for your endpoint's api link (i.e. https://aps.autodesk.com/en/docs/acc/v1/reference/http/)
        $[Item]Url = "[REPLACE WITH URL]"

        # Initialize the Body of the GET request, including some universal preferences like max limit
        $Body =  @{ "limit" = "200" }

        # Include all query string parameters that are 'filters' and any other necessary parameters
        # FOR FILTERS -             if($parameterName) { $Body["filter[parameterName]"] = $parameterName}
        # FOR OTHER PARAMETERS -    if($parameterName) { $Body["parameterName"] = $parameterName}
        # Example Initialization    Notes: Always convert datetime attributes to strings
        # if($optionalParam1) { $Body["filter[optionalParam1]"]=$optionalParam1 }
        # if($optionalParam2) { $Body["filter[optionalParam2]"]=$optionalParam2 }
        # if($optionalParam3) { $Body["filter[optionalParam3]"]=([datetime]$optionalParam3).ToString("yyyy-MM-ddThh:mm:ss.fffZ\.\.") }
        # if($optionalParam4) { $Body["optionalParam4"]=$optionalParam4 }

        # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
        $initial[Item] = Invoke-Restmethod -Method GET -Uri $[Item]Url -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" } -Body $Body

        # Initialize an ArrayList for the response
        $[Item]Array = [System.Collections.ArrayList]::new()
        [void]$[Item]Array.Add($initial[Item].results)


        # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
        $temp[Item] = $initial[Item]
        while(![string]::IsNullOrWhiteSpace($temp[Item].pagination.nextUrl)) {
            $temp[Item] = Invoke-Restmethod -Method GET -Uri $temp[Item].pagination.nextUrl -Header @{ "Authorization" = "Bearer $($PWStateObject.Password)" }
            [void]$[Item]Array.Add($temp[Item].results)
        }

    # Use the helper function New-APSDT to create a datatable for the data in $[Item]Array
    [System.Data.DataTable]$[Item]Table = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the [Item]Array
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach($[Item]Page in $[Item]Array) {
        # Iterate through the pages of the ArrayList
        foreach($[Item] in $[Item]Page) {
            # Iterate through each individual [Item] and create rows
            $row = $[Item]Table.NewRow()
            foreach($column in $[Item]Table.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $[Item].$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            # $row["assetId"] = $asset.id

            # Add populated row to the datatable
            $[Item]Table.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $[Item]Table
    #>
}


