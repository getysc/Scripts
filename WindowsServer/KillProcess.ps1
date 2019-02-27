<#
.SYNOPSIS    
    Stop a windows process
.DESCRIPTION 
    This script stops a process on a remote computer
.EXAMPLE     
    
   . ../Common/KillProcess.ps1 
    KillProcess -ComputerName "ServerName" -Binary "Executable name" -InstallPath "Path on target server"
.NOTES       
---------------------------------------------------------
 Script name: KillProcess.ps1
 Script purpose: Retrieve a configuration object

--------------------------------------------------------

#>

function KillProcess($ComputerName, $Binary, $InstallPath)
{
	$remotesession = new-pssession -computername $ComputerName
	$processes = Invoke-Command -ScriptBlock{param($Binary) Get-Process $Binary -ErrorAction SilentlyContinue} -ArgumentList $Binary -Session $remotesession

	ForEach($process in $processes)
	{
			if ($process.Path.ToLower().Contains($InstallPath.ToLower()))
			{
				Write-Verbose -Verbose "  ====> STOPPED"		
				Invoke-Command -ScriptBlock{param($process) Stop-Process -Id $process.Id  | Out-Null} -ArgumentList $process -Session $remotesession	
			}
			else
			{
				Write-Verbose  -Verbose "  ====> NOT RUNNING"		
			}
	}
	Remove-PSSession -Session $remotesession
}