# TEMPLATE GET FUNCTION
function Get-APSNode {
    Param(
        [Parameter(Mandatory = $true)]
        $ProjectID,
        [Parameter(Mandatory = $true)]
        $TreeID,
        #Change default column names for request
        [string[]] $DesiredColumns = ('NodeID'<#Alias for 'id'#>, 'ParentID', 'Type', 'Name', 'Description', 'Barcode', 'Order', 'DocumentCount', 'Path'),
        [string[]] $ID
    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/locations-nodes-GET/

    # Retrieve access token information stored in the PasswordState API
    $PWStateObject = Get-PWTokObject
    $PWStateObject.DecryptPassword()

    # Retrieve data from API, put into $NodeArray
    $NodeUrl = "https://developer.api.autodesk.com/construction/locations/v2/projects/$($ProjectID)/trees/$($TreeID)/nodes"

    # Initialize the Body of the GET request, including some universal preferences like max limit
    $Body = @{ 'limit' = '10000' }

    if($ID) {
        $Body['filter[ID]'] = $ID
    }

    # Send off the GET request, using the Access Token stored in the PWStateObject's Password field and $Body
    $initialNode = Invoke-RestMethod -Method GET -Uri $NodeUrl -Header @{ 'Authorization' = "Bearer $($PWStateObject.Password)" } -Body $Body

    # Initialize an ArrayList for the response
    $NodeArray = [System.Collections.ArrayList]::new()
    [void]$NodeArray.Add($initialNode.results)


    # Initialize a "temporary" variable that iterates through all pages of pagination and adds to ArrayList
    $tempNode = $initialNode
    while(![string]::IsNullOrWhiteSpace($tempNode.pagination.nextUrl)) {
        $tempNode = Invoke-RestMethod -Method GET -Uri $tempNode.pagination.nextUrl -Header @{ 'Authorization' = "Bearer $($PWStateObject.Password)" }
        [void]$NodeArray.Add($tempNode.results)
    }

    # Use the helper function New-APSDT to create a datatable for the data in $NodeArray
    [System.Data.DataTable]$NodeTable = New-APSDT -DesiredColumns $DesiredColumns

    # Populate the new table with data from the NodeArray
    # NOTE: Column names must match JSON's fields, or you must do a custom fill or each change
    foreach($NodePage in $NodeArray) {
        # Iterate through the pages of the ArrayList
        foreach($Node in $NodePage) {
            # Iterate through each individual Node and create rows
            $row = $NodeTable.NewRow()
            foreach($column in $NodeTable.Columns) {
                # Iterate through the columns to populate each cell
                $row[$column] = $Node.$column
            }
            # Custom fill example to change generic name of column 'id' to 'AssetID'
            $row['NodeID'] = $Node.id

            # Add populated row to the datatable
            $NodeTable.Rows.Add($row)
        }
    }

    # Return the datatable intact using the -NoEnumerate option
    Write-Output -NoEnumerate $NodeTable

}
