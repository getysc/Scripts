[CmdletBinding()]
param(
	[parameter(mandatory=$false)]
	[ValidateNotNullOrEmpty()]
	[string]$environmentName,

	[parameter(mandatory=$false)]
	[ValidateNotNullOrEmpty()]
	[string]$ProcessProductionEnvironments = $true
)

$environmentsJson = '{
	"Environments": [
		{
			"Site": "STG",
			"WebServers": ["WebServers1","WebServers2"],
			"LoadBalancer": "someurl.corp.stg.org"
		},
		{
			"Site": "PRD",
			"WebServers": ["WebServers1","WebServers2"],
			"LoadBalancer": "someurl.corp.prd.org"
		}
	]
}'	

function ValidateHealthCheck {
    [CmdletBinding()]
    Param (
		[parameter(mandatory=$true)]
		[ValidateNotNullOrEmpty()]
        [string]$hostName, 
		[parameter(mandatory=$true)]
		[ValidateNotNullOrEmpty()]
        [string]$port
    )
	
    $url = "http://" + $hostName + ":" + $port + "/mgmt/health"
    #Write-Host "Validating HealthCheck :: $url"

	$response = try {(
		Invoke-WebRequest -Uri $url -ErrorAction Stop -UseBasicParsing).BaseResponse
	} 
	catch { 
			#Write-Verbose "An exception was caught: $($_.Exception.Message)"
			#Write-Verbose $_.Exception.Response 
	} 

	if($null -eq $response -or $response.StatusCode -ne 200)
	{ 
		$statusCode = $null
		if($null -eq $response)
		{
			$statusCode = "Couldn't Connect"
		}
		else
		{
			$statusCode = $response.StatusCode
		}
		
		Write-Host "[DOWN] $url" -ForegroundColor red
		return 0
	}
	else
	{
		Write-Host "[GOOD] $url" -ForegroundColor green
		return 1
	}
}

function Test-Environment {
    [CmdletBinding()]
    Param (
		[parameter(mandatory=$true)]
		[Array]$environments,
		[parameter(mandatory=$true)]
		[ValidateNotNullOrEmpty()]
        [string]$environmentName
    )
	
	if ($environmentName.Trim() -eq "")
	{
		"Valid environmentName is required"
		"Supported environments are :-"
			$environments.Site
			exit 0
	}

	Write-Host "Searching $environmentName"
	$environment = $environments | Where-Object { $_.Site -eq $environmentName}
	if ($environment -eq $null)
	{
		"Valid environmentName is required"
		"Supported environments are :-"
			$environments.Site
			exit 0
	}
	else
	{
		Write-Host "Found :: $environment"
	}

	$hostNames  = $environment.WebServers 
	Write-Host "$hostNames `n`n"
	$ports = Invoke-Command -ComputerName $environment.WebServers[0] -ScriptBlock {
			(Get-WebBinding).bindingInformation.Replace("*:", "").Replace(":", "")
	}

	foreach($hostName in $hostNames) 
	{
		Write-Host "Processing $hostName"
		foreach($port in $ports)
		{
			try {
				$result = ValidateHealthCheck $hostName $port
			} 
			catch {
			}
		}
	}
}

$environments = $environmentsJson | ConvertFrom-Json | select -expand Environments
if ($ProcessProductionEnvironments)
{
	foreach($environment in $environments)
	{
		if ($environment.Site.Contains("PRD"))
		{
			Test-Environment $environments $environment.Site
		}
	}
}
else
{
	Test-Environment $environments $environmentName
}
