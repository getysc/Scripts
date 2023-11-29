
$machine1="??????????????????"
$machine2="??????????????????"
$data1 = Invoke-Command -ComputerName $machine1 -ScriptBlock {[System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine).GetEnumerator()| select-object key, Value |sort-Object key | ConvertTo-Json} 
$data2 = Invoke-Command -ComputerName $machine2 -ScriptBlock {[System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine).GetEnumerator()| select-object key, Value |sort-Object key | ConvertTo-Json}

$data1 | Set-Content -Path C:\temp\left.json
$data2 | Set-Content -Path C:\temp\right.json
winmergeu  C:\temp\left.json C:\temp\right.json
 
