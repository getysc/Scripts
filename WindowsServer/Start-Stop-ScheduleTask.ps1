<#
.SYNOPSIS    
    Start or Stop a scheduled task
.DESCRIPTION 
    This script starts or stops a scheduled task
.EXAMPLE     
    
   . ../Common/ManageScheduledTask.ps1 
    ManageScheduledTask -ComputerName "ServerName" -TaskName "Scheduled Task name" -State "Start or Stop"
.NOTES       
---------------------------------------------------------
 Script name: ManageScheduledTask.ps1
 Script purpose: Manage a windows scheduled task

--------------------------------------------------------

#>
function ManageScheduledTask($ComputerName, $TaskName, $State)
{
	if($State -eq "Stop")
	{
		Invoke-Command -ComputerName $ComputerName  -ScriptBlock{param($TaskName) Get-ScheduledTask -TaskName $TaskName | Stop-ScheduledTask} -ArgumentList $TaskName
	}
	Else
	{
		Invoke-Command -ComputerName $ComputerName  -ScriptBlock{param($TaskName) Get-ScheduledTask -TaskName $TaskName | Start-ScheduledTask} -ArgumentList $TaskName
	}
}