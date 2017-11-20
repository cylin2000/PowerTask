function Invoke-Sql {
    
    <#
    .SYNOPSIS
        Invoke a SQL command
    .DESCRIPTION 
        This task execute a SQL command
    .EXAMPLE     
        Invoke-Sql 'Server=localhost;Database=MY_DB;Integrated Security=True' 'select * from TestTable'
    #>

    Param (
        [Parameter(Mandatory=$True)][String] $ConnectionString,
        [Parameter(Mandatory=$True)][String] $Sql
    )

    $Connection = new-object system.data.SqlClient.SqlConnection($ConnectionString);
    $dataSet = new-object "System.Data.DataSet" "MyDataSet"
    $dataAdapter = new-object "System.Data.SqlClient.SqlDataAdapter" ($Sql, $Connection)
    $dataAdapter.Fill($dataSet) | Out-Null
    $Connection.Close()
    return $dataSet
}