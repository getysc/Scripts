#
#
# Usage:
# 
# Starts a process (console application)
# .\Stop-Process.ps1 -BinaryName "Kforce.TRM.CandidateRating.UpdateRating.exe" -InstallPath "D:\srvapps\CandidateRating.UpdateRating\DEV\"
#

param(
	[parameter(Mandatory=$true, HelpMessage="Process Name")]
        [ValidateNotNullOrEmpty()]
	[string]$BinaryName,

	[parameter(Mandatory=$true, HelpMessage="Process install Path")]
        [ValidateNotNullOrEmpty()]
	[string]$InstallPath
)

$BinaryName = $BinaryName.Replace('.exe', '')
Write-Verbose -Verbose "Process install Path : $InstallPath"
Write-Verbose -Verbose "Process Name         : $BinaryName"
Write-Verbose -Verbose ""

$processes = Get-Process $BinaryName -ErrorAction SilentlyContinue
if ($processes -eq $null)
{
	Write-Verbose -Verbose "  ====> NOT RUNNING"
	return
}

ForEach($process in $processes)
{
	if ($process.path.ToLower().Contains($InstallPath.ToLower()))
	{
		Write-Verbose -Verbose "  ====> STOPPED"		
		Stop-Process -Force $process | Out-Null	
	}
	else
	{
		Write-Verbose -Verbose "  ====> NOT RUNNING"		
	}
}