#
#
# Usage:
# 
# Stop Services
# .\Toggle-WebSite.ps1 -WebsiteName "Default Web Site" -WebAppPoolName "Test" -State "Stopped"
#
# Start Services
# .\Toggle-WebSite.ps1 -WebsiteName "Default Web Site" -WebAppPoolName "Test" -State "Started"
#

param(
		[parameter(Mandatory=$true, HelpMessage="IIS Website name.")]
        [ValidateNotNullOrEmpty()]
		[string]$WebsiteName,

		[parameter(Mandatory=$true, HelpMessage="IIS Apppool name.")]
        [ValidateNotNullOrEmpty()]
		[string]$WebAppPoolName,

		[parameter(Mandatory=$true, HelpMessage="Expected State.")]
        [ValidateNotNullOrEmpty()]
		[string]$State
)

Write-Verbose "WebsiteName     : $WebsiteName" -Verbose 
Write-Verbose "WebAppPoolName  : $WebAppPoolName" -Verbose 
Write-Verbose "State           : $State" -Verbose 

Import-Module WebAdministration
if($State -eq "Started")
{
    Start-WebAppPool -Name $WebAppPoolName
	Write-Verbose -Verbose (Get-WebAppPoolState $WebAppPoolName).Value

	Start-website -Name $WebsiteName
	Start-Sleep -Seconds 15
	Write-Verbose -Verbose (Get-WebsiteState -Name $WebsiteName).Value
}
elseif($State -eq "Stopped")
{
    if ((Get-WebsiteState $WebsiteName).Value -ne "Stopped")
	{
		Stop-website -Name $WebsiteName
		Start-Sleep -Seconds 15
	}

	Write-Verbose -Verbose (Get-WebsiteState -Name $WebsiteName).Value

    if ((Get-WebAppPoolState $WebAppPoolName).Value -ne "Stopped")
    {
		Stop-WebAppPool -Name $WebAppPoolName
	}
	
	Write-Verbose -Verbose (Get-WebAppPoolState $WebAppPoolName).Value
}
else
{
    Write-Verbose -Verbose "Invalid value for State:$State"
    Write-Verbose -Verbose "State = { Started | Stopped }  ]"
    throw "Invalid value for State:$State"
}

