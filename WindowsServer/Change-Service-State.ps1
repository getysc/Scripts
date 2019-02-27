#
# Meant for stopping/starting RecruitMAX services (RMX/WSCF) 
# 
# Usage: 
# 
# Stop Services
# .\Change-Service-State.ps1 -WebsiteName "Default Web Site" -WebAppPoolName "Test" -ServiceName "Spooler" -State "Stopped"
#
# Start Services
# .\Change-Service-State.ps1 -WebsiteName "Default Web Site" -WebAppPoolName "Test" -ServiceName "Spooler" -State "Started"
#

param(
		[parameter(Mandatory=$true, HelpMessage="Environment name.")]
        [ValidateNotNullOrEmpty()]
		[string]$ServiceName,

		[parameter(Mandatory=$true, HelpMessage="Web site name.")]
        [ValidateNotNullOrEmpty()]
		[string]$WebsiteName,

		[parameter(Mandatory=$true, HelpMessage="Web App pool name.")]
        [ValidateNotNullOrEmpty()]
		[string]$WebAppPoolName,

		[parameter(Mandatory=$true, HelpMessage="Services State.")]
        [ValidateNotNullOrEmpty()]
		[string]$State
)

Configuration ChangeServiceState
{
	param(
		[parameter(Mandatory=$false)]
		[string]$ComputerName="localhost",

		[string]$ServiceName,

		[string]$WebsiteName,

		[string]$WebAppPoolName,

		[string]$State
  	)

	Import-DscResource -Module xWebAdministration

	#Node $AllNodes.NodeName
	Node $ComputerName
	{
        xWebAppPool HandleWebAppPool 
		{ 
			Name   = "$WebAppPoolName"
			Ensure = "Present" 
			State  = $State
		} 	

        xWebsite NewWebSite
		{
			Name = "$WebsiteName"
			Ensure = "Present"
			State = $State
        }

        Script ChangeServiceState
        {
            SetScript = {
                Write-Verbose "ServiceName : $using:ServiceName" -Verbose 
                Write-Verbose "State       : $using:State" -Verbose 

                $svc = Get-Service -Name "$using:ServiceName"

                if ($using:State -eq 'Started')
                {
                    #Start-Service $svc
                    #$svc.WaitForStatus('Running','00:10:00')
                    Start-Sleep -Seconds 180
                    Restart-Service $svc -Force
                }
                Elseif ($using:State -eq 'Stopped')
                {
                    Stop-Service $svc
                    $svc.WaitForStatus('Stopped','00:10:00')
                }
            }
        
            TestScript = { $false }
            GetScript = {
                # Do Nothing 
            } 
	    }

    }
}


Write-Verbose "WebsiteName     : $WebsiteName" -Verbose 
Write-Verbose "WebAppPoolName  : $WebAppPoolName" -Verbose 
Write-Verbose "ServiceName     : $ServiceName" -Verbose 
Write-Verbose "State           : $State" -Verbose 

if($State -eq "Started")
{
    $ServiceState = "Running"
}
elseif($State -eq "Stopped")
{
    $ServiceState = "Stopped"
}
else
{
    Write-Verbose -Verbose "Invalid value for State:$State"
    Write-Verbose -Verbose "State = { Started | Stopped }  ]"
    throw "Invalid value for State:$State"
}

ChangeServiceState -ServiceName $ServiceName -WebsiteName $WebsiteName -WebAppPoolName $WebAppPoolName -State $State
Start-DscConfiguration -Force -Wait -Verbose ./ChangeServiceState
