<#
.SYNOPSIS
Writes Table data to the SQL server

.DESCRIPTION
Utilizes DBATools to send table data to a SQL table for analysis, meant to be piped together with the Get-APS scripts

.PARAMETER InputObject
Pipeline value parameter that accepts System.Data.DataTable objects

.PARAMETER TableName
The name of the table you wish to write to

.EXAMPLE
Get-APSAsset -ProjectID $ProjectID | Write-APSItem

.NOTES
Will not write to a table that does not exist
#>
function Write-APSItem{
    [CmdletBinding()]
    Param(

        [Parameter(ValueFromPipeline = $true)]
        [System.Data.DataTable]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$TableName,
        [Parameter(Mandatory = $true)]
        [string]$database

    )
    Write-DbaDataTable -SqlInstance $SQLInstance -InputObject $InputObject -Database $database -Table $TableName
}