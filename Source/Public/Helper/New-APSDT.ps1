
<#
.SYNOPSIS
Creates a DT with the desired columns.

.DESCRIPTION
Helper function that takes an array of column names as input, and returns a DataTable with said columns.

.PARAMETER DesiredColumns
The desired columns to be present in the returned DT.

.EXAMPLE
$DesiredColumns = ("id", "name", "type", "actAs", "position", "workflowType", "createdAt", "updatedAt")

Example setting the $DesiredColumns variable.

.EXAMPLE
[System.Data.DataTable]$COTable = New-APSDT -DesiredColumns $DesiredColumns

Stores a DataTable with the columns specified in $DesiredColumns into the variable $COTable.

.NOTES
For use in API calls and autofilling like Get-APSForm, the input $DesiredColumns must match
the names of fields from the API to be autofilled later in the returned DT.
#>
function New-APSDT {
    Param(
        [Parameter(Mandatory = $true)]
        [string[]] $DesiredColumns
    )
    #Creates a DT for the Asset data
    ###Creating a new DataTable###
    $tempTable = New-Object System.Data.DataTable

    ###Populating the DT with columns###
    $dataColumns = New-Object System.Data.DataColumn[]::new($DesiredColumns.Length)
    for (($i = 0); $i -lt $DesiredColumns.Length ; $i++) {

        $dataColumns[$i] = New-Object System.Data.DataColumn($DesiredColumns[$i])

        $tempTable.Columns.Add($dataColumns[$i]);

    }
    return , $tempTable
}