#
#
# Usage:
# 
# Starts a scheduled task
# .\Start-Task.ps1 -TaskName "TimeExpense.TRAIN"
#
#
param(
	[parameter(Mandatory=$true, HelpMessage="Schedule task Name")]
        [ValidateNotNullOrEmpty()]
	[string]$TaskName
)
Write-Verbose -Verbose  "[START] scheduled task: $TaskName"

Get-ScheduledTask -TaskName $TaskName | Start-ScheduledTask

Write-Verbose -Verbose  "[STATUS] (Get-ScheduledTask -TaskName $($TaskName)).State"