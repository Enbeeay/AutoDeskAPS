Import-Module -Force -Name 'C:\Users\nallie\Repos\AutoDeskAPS\0.0.0\AutoDeskAPS.psm1'
$AccountID = '5dd08f6a-f677-435c-0000-9abb162e8588'
$testEmail = 'bob@contoso.com'
$UserID = '34ae1541-46d5-486f-b210-10debea373f6'

#Edit-APSUser -ProjectID $AccountID -AccountID $AccountID -UserID $UserID -status "active"
#Add-APSUser -AccountID $AccountID -email $testEmail -first_name "Buggs" -last_name "Bunny" -nickname "Doc"
#Get-APSUser -AccountID $AccountID
#Get-Help Get-APSCostItem -ShowWindow
Get-APSNode -ProjectID 'c7a5ba1f-3a0b-0000-8aae-fe56104a751e' -TreeId 'default'
<#
$UserTable = Get-APSUser -AccountID $AccountID
$SQLInstance = Connect-DbaInstance -SqlInstance SQLSERVER -TrustServerCertificate

#Invoke-DbaQuery -SqlInstance $SQLInstance -Query "SELECT * FROM Sandbox.dbo.TempAssetTable"

Write-DbaDataTable -SqlInstance $SQLInstance -InputObject $UserTable -Table Sandbox.dbo.TempUserTable -AutoCreateTable

#>