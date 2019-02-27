#
#
# Usage:
# 
# Stops a scheduled task
# .\Stop-Task.ps1 -TaskName "TimeExpense.TRAIN"
#
#
param(
	[parameter(Mandatory=$true, HelpMessage="Schedule task Name")]
        [ValidateNotNullOrEmpty()]
	[string]$TaskName
)
Write-Verbose -Verbose  "[STOP] Scheduled task: $TaskName"

Get-ScheduledTask -TaskName $TaskName | Stop-ScheduledTask

Write-Verbose -Verbose  "[STATUS] (Get-ScheduledTask -TaskName $($TaskName)).State"