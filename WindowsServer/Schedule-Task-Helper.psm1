<#
.SYNOPSIS    
    Start or Stop a windows scheduled task
.DESCRIPTION 
    This script starts or stops windows scheduled task
.EXAMPLE     
    Stop-SchedulerTask -RemoteSession $RemoteSession -TaskName $TaskName
.NOTES       

#>

New-Alias Log Write-Verbose

function Stop-SchedulerTask
{
    param(
	    [parameter(Mandatory=$true,  HelpMessage="Remote Session Object")]
	    [ValidateNotNullOrEmpty()]
	    $RemoteSession,

	    [parameter(Mandatory=$true, HelpMessage="Windows Scheduler Task name")]
	    [ValidateNotNullOrEmpty()]
	    [string]$TaskName,

	    [parameter(Mandatory=$false, HelpMessage="Number of retries")]
	    [Int]$Retries = 3,

	    [parameter(Mandatory=$false, HelpMessage="Sleep time")]
	    $Sleep = 15
    )
    
    Log "[Stop-SchedulerTask] BEGIN"

    Log  "TaskName:: $TaskName"
    $ScriptBlock = {param($TaskName) Get-ScheduledTask -TaskName $TaskName | Stop-ScheduledTask | Out-Null}
    Log  "ScriptBlock:: $ScriptBlock"
    $result = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $TaskName -Session $RemoteSession -ErrorAction Stop
    $result 

    $success = $false
    for($i=0; $i -lt $Retries; ++$i)
    {
        Start-Sleep -Seconds $Sleep

        <#
            0  State = 'Unknown' 
            1  State = 'Disabled'
            2  State = 'Queued'
            3  State = 'Ready' 
            4  State = 'Running'
        #>
        $ScriptBlock = {param($TaskName) (Get-ScheduledTask -TaskName $TaskName).State}
        Log  "ScriptBlock:: $ScriptBlock"
        $result = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $TaskName -Session $RemoteSession -ErrorAction Stop
        if ($result.Value -eq 'Ready')
        {
            $success = $true
            Log  "Task is in Ready State (Stopped)"
            break
        }
    }

    if ($success -eq $false)
    {
        throw "Unable to stop task [$TaskName] after maximum retries...."
    }

    Log "[Stop-SchedulerTask] END"
}


function Start-SchedulerTask
{
    param(
	    [parameter(Mandatory=$true,  HelpMessage="Remote Session Object")]
	    [ValidateNotNullOrEmpty()]
	    $RemoteSession,

	    [parameter(Mandatory=$true, HelpMessage="Windows Scheduler Task name")]
	    [ValidateNotNullOrEmpty()]
	    [string]$TaskName,

	    [parameter(Mandatory=$false, HelpMessage="Number of retries")]
	    [Int]$Retries = 3,

	    [parameter(Mandatory=$false, HelpMessage="Sleep time")]
	    $Sleep = 15
    )
    
    Log "[Start-SchedulerTask] BEGIN"

    Log  "TaskName:: $TaskName"
    $ScriptBlock = {param($TaskName) Get-ScheduledTask -TaskName $TaskName | Start-ScheduledTask | Out-Null}
    Log  "ScriptBlock:: $ScriptBlock"
    $result = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $TaskName -Session $RemoteSession -ErrorAction Stop
    $result 

    $success = $false
    for($i=0; $i -lt $Retries; ++$i)
    {
        Start-Sleep -Seconds $Sleep

        <#
            0  State = 'Unknown' 
            1  State = 'Disabled'
            2  State = 'Queued'
            3  State = 'Ready' 
            4  State = 'Running'
        #>
        $ScriptBlock = {param($TaskName) (Get-ScheduledTask -TaskName $TaskName).State}
        Log  "ScriptBlock:: $ScriptBlock"
        $result = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $TaskName -Session $RemoteSession -ErrorAction Stop
        if ($result.Value -eq 'Running')
        {
            $success = $true
            Log  "Task is in Running State"
            break
        }
    }

    if ($success -eq $false)
    {
        throw "Unable to start task [$TaskName] after maximum retries...."
    }

    Log "[Start-SchedulerTask] END"
}

Export-ModuleMember -Function Stop-SchedulerTask, Start-SchedulerTask
#Export-ModuleMember -Function * -Alias *
#Export-ModuleMember -Function Get-Test, New-Test, Start-Test -Alias gtt, ntt, stt

