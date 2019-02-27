<#
   
       This script can release a VSTS release defintion

        Usage:
        Run below command at powershell prompt  (admin mode)
        VSTS-Release -ReleaseDefintionName "TRM.CandidateRating.Web"  -EnvironmentName "dev"
#>


function Log
{ 
   [CmdletBinding()]
    param(
        $data
    )

    Write-Verbose $data 
}


$projectsJson = '[
    {"name":"IT Application Services"}
]'

$releaseDefinitionsJson = '[
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "TRM",
		"releaseDefinitionName": "TRM.CandidateMarketing"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "TRM",
		"releaseDefinitionName": "TRM.CandidateRating.UpdateRating"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "TRM",
		"releaseDefinitionName": "TRM.CandidateRating.Web"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "RMX",
		"releaseDefinitionName": "RMX.RMX"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "WSCF",
		"releaseDefinitionName": "RMX.WSCF"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "myTE",
		"releaseDefinitionName": "myTE.Assignment.Response.ConsoleApp"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "myTE",
		"releaseDefinitionName": "myTE.IT.EAI.Azure.ServiceBus.API"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "myTE",
		"releaseDefinitionName": "myTE.IT.EAI.TimeExpense.Assignment.Requests"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "myTE",
		"releaseDefinitionName": "myTE.IT.EAI.TimeExpense.Assignment.Response"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Account.API"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Action.API"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Contact.API"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Eis.Account"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Eis.Department"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Eis.Employee"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Eis.Location"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.Event.API"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRM",
		"releaseDefinitionName": "CRM.JobOrder.API"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRMLogicApp",
		"releaseDefinitionName": "IT.EAI.CRM.LogicApp.Account.CreditCheck"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRMLogicApp",
		"releaseDefinitionName": "IT.EAI.CRM.LogicApp.DepartmentHierarchy"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRMLogicApp",
		"releaseDefinitionName": "IT.EAI.CRM.LogicApp.EmpDeptUpdate"
	},
	{
		"ProjectName": "IT Application Services",
		"Deploy": "true",
		"Project": "CRMLogicApp",
		"releaseDefinitionName": "IT.EAI.CRM.LogicApp.JobOrderStatusUpdate"
	}

]'

function Get-BaseRestUrl {
   [CmdletBinding()]
   param (
      [string] $vstsDomain, 
      [string] $vstsTeamProject
   )

   $url = "https://$($vstsDomain).vsrm.visualstudio.com/$vstsTeamProject/_apis/Release"
   return $url
}

function Get-ReleaseDefinitionData {
   [CmdletBinding()]
   param (
      $projects
   )

    [System.Collections.ArrayList]$releaseDataArray  = @()
    Foreach ($project in $projects)
    {
        $baseRestUrl = Get-BaseRestUrl -vstsDomain $vstsDomain -vstsTeamProject $project.name
        $uri = $baseRestUrl + '/definitions'  # #https://kforce.vsrm.visualstudio.com/TRM/_apis/Release/definitions
        $releaseDefintions = (Invoke-RestMethod -Uri $uri -headers $headers -ContentType 'application/json' -Method GET).value
        foreach ($releaseDefintion in $releaseDefintions)
        {
            $releaseData = New-Object -TypeName psobject
            $releaseData | Add-Member -MemberType NoteProperty -Name ProjectName -Value $project.name
            $releaseData | Add-Member -MemberType NoteProperty -Name Id -Value $releaseDefintion.id
            $releaseData | Add-Member -MemberType NoteProperty -Name ReleaseDefintionName -Value $releaseDefintion.name
            $releaseDataArray.Add($releaseData) | Out-Null
        }
        
    }

    $releaseDataArray
}

function Get-Release-Json 
{
    $json = @"
{
    "status": "inprogress",
    "comment": "Triggered by VSTS-Create-Release-In-Environment.ps1"
}
"@

$json
}

function Get-All-Releases
{
   [CmdletBinding()]
   param (
      [string] $releaseDefinitionId
   )
    
    $baseRestUrl = Get-BaseRestUrl -vstsDomain $vstsDomain -vstsTeamProject $ProjectName
    #https://kforce.vsrm.visualstudio.com/TRM/_apis/Release/releases?definitionId=4
    $uri = $baseRestUrl + [string]::Format("/releases?definitionId={0}",$releaseDefinitionId)
    Log "`t[Release Definition Url] $uri"

    $result = Invoke-RestMethod -Uri $uri -headers $headers -ContentType 'application/json' -Method GET # -Body $json
    $result.value
}

function Get-Release-Envrionments
{
   [CmdletBinding()]
   param (
      [string] $ProjectName,
      [string] $releaseId
   )
    
    $baseRestUrl = Get-BaseRestUrl -vstsDomain $vstsDomain -vstsTeamProject $ProjectName
    #https://kforce.vsrm.visualstudio.com/TRM/_apis/Release/releases/10
    $uri = $baseRestUrl + [string]::Format("/releases/{0}",$releaseId)
    Log "`t[Release Id Url]         $uri"

    $result = Invoke-RestMethod -Uri $uri -headers $headers -ContentType 'application/json' -Method GET # -Body $json
    [System.Collections.ArrayList]$environmentArray  = @()
    foreach($environment in $result.environments)
    {
        $environmentData = New-Object -TypeName psobject
        $environmentData | Add-Member -MemberType NoteProperty -Name Id        -Value $environment.id
        $environmentData | Add-Member -MemberType NoteProperty -Name Name      -Value $environment.name
        $environmentData | Add-Member -MemberType NoteProperty -Name ReleaseId -Value $environment.releaseId
        $environmentArray.Add($environmentData) | Out-Null
    }
    return $environmentArray
}


function Create-Release {
   [CmdletBinding()]
   param (
      [System.Collections.ArrayList]$ReleaseDefinitionDataArray,
      $ProjectName,
      $ReleaseDefintionName,
      $EnvironmentName
   )

    $releaseDefinitionData = $ReleaseDefinitionDataArray | Where-Object {$_.ProjectName -eq $ProjectName -and $_.ReleaseDefintionName -eq $ReleaseDefintionName}    
    if ($releaseDefinitionData -eq $null)
    {
        throw "`tProject/Release Template NOT found: $ProjectName - $ReleaseDefintionName"
    } 

    # Get latest release for input releaseDefinition 
    $releaseId = (Get-All-Releases -releaseDefinitionId $releaseDefinitionData.Id)[0].id
    if ($releaseId -eq $null)
    {
        throw "`tNOT found release id for releaseDefinition => $ReleaseDefintionName  $releaseDefinitionData.Id"
    } 

    # Get release data for input release id
    $releaseEnvironments = Get-Release-Envrionments -ProjectName $ProjectName -releaseId $releaseId
    $environment = $releaseEnvironments | Where-Object {$_.Name -eq $EnvironmentName}
    if ($environment -eq $null)
    {
        throw "`tNOT found environment for release id => $releaseId"
    } 

    # Trigger release for target environment
    $baseRestUrl = Get-BaseRestUrl -vstsDomain $vstsDomain -vstsTeamProject $ProjectName
    # #https://kforce.vsrm.visualstudio.com/TRM/_apis/Release/releases/10/environments/13?api-version=4.0-preview.4
    $uri = $baseRestUrl + [string]::Format("/releases/{0}/environments/{1}?api-version=4.0-preview.4",$releaseId, $environment.id)
    Log "`t[Release Trigger Url]    $uri"
    Log $uri
    
    $bodyJson = Get-Release-Json  
    $releaseResponse = Invoke-RestMethod -Uri $uri -ContentType 'application/json' -Method Patch -Headers $headers -Body $bodyJson 
    if ($releaseResponse.status -eq "queued") 
    {
        Log "[QUEUED] Triggered release for $ReleaseDefintionName with id $releaseId"
        Start-Sleep -s 10
    }
    else
    {
        throw "[ERROR] Release status $releaseResponse.status is not the expected state"
    }    

    return $uri
}

function Get-Release-Status
{
   [CmdletBinding()]
   param (
      [string] $ReleaseUri
   )

    $ReleaseCompleted = $false    
    Log "`t[Release Definition Url] $uri"
    for($i=0; $i -ne 100; ++$i)
    {
        $result = Invoke-RestMethod -Uri $ReleaseUri -headers $headers -ContentType 'application/json' -Method GET
        Log "status : $($result).status"
        if ($result.status -eq "succeeded")
        {
           $ReleaseCompleted = $true 
           break
        }
        Start-Sleep -Seconds 60
    }

    if ($ReleaseCompleted -ne $true)
    {
        throw "Release status is not the expected after maximum retries..."
    }

    
}


function Run-Test()
{
    $projectsJson = '[
        {"name":"TRM"}
    ]'

    $releaseDefinitionsJson = '[
        { "ProjectName": "TRM", "Deploy": "true", "Project": "TRM", "releaseDefinitionName": "HelloWorld"} 
    ]'

    $projects = ConvertFrom-Json –InputObject $projectsJson
    $releaseDefinitions = ConvertFrom-Json –InputObject $releaseDefinitionsJson

    # Get release defintions
    [System.Collections.ArrayList]$ReleaseDefinitionDataArray  = Get-ReleaseDefinitionData -projects $projects
    #$ReleaseDefinitionDataArray

    # Create releases
    $EnvironmentName = 'QA'
    $ReleaseUri = Create-Release -ReleaseDefinitionDataArray $ReleaseDefinitionDataArray -ProjectName 'TRM' -ReleaseDefintionName 'HelloWorld' -EnvironmentName $EnvironmentName 

    Get-Release-Status $ReleaseUri 
}

<#
$testrun= $true
if ($testrun -eq $true)
{
    Run-Test
}
else
{
    $projects = ConvertFrom-Json –InputObject $projectsJson
    $releaseDefinitions = ConvertFrom-Json –InputObject $releaseDefinitionsJson

    # Get release defintions
    [System.Collections.ArrayList]$ReleaseDefinitionDataArray  = Get-ReleaseDefinitionData -projects $projects
    $ReleaseDefinitionDataArray

    # Create releases
    #$EnvironmentName = 'QB'
    Foreach($releaseDefinition in $releaseDefinitions)
    {
        $release = "=> " + $releaseDefinition.ProjectName + " " +$releaseDefinition.releaseDefinitionName
        if ($releaseDefinition.Deploy -eq "false")
        {
            Log $release "[Ignoring]"
        }
        else
        {
            Log $release "[Releasing]"
            #Create-Release -ReleaseDefinitionDataArray $ReleaseDefinitionDataArray -ProjectName $releaseDefinition.ProjectName -ReleaseDefintionName $releaseDefinition.releaseDefinitionName -EnvironmentName $EnvironmentName 
        }
    } 
}
#>

function VSTS-Release
{ 
   [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$ReleaseDefinitionName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [ValidateSet("dev")]
        [string]$EnvironmentName,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()] 
        [string]$user = "",

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()] 
        [string]$token = (Get-Content "c:\windows\VSTSToken.txt"),

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()] 
        [string]$vstsDomain = 'kforce',
        $testrun= $false
    )

    # Base64-encodes the Personal Access Token (PAT) appropriately
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))
    $headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    $projects = ConvertFrom-Json –InputObject $projectsJson
    $releaseDefinitions = ConvertFrom-Json –InputObject $releaseDefinitionsJson

    # Get release defintions
    [System.Collections.ArrayList]$ReleaseDefinitionDataArray  = Get-ReleaseDefinitionData -projects $projects
    #$ReleaseDefinitionDataArray

    # Create release
    $ReleaseUri = Create-Release -ReleaseDefinitionDataArray $ReleaseDefinitionDataArray -ProjectName "IT Application Services" -ReleaseDefintionName $ReleaseDefinitionName -EnvironmentName $EnvironmentName 
    Get-Release-Status -ReleaseUri $ReleaseUri
}

#
# Example:
# VSTS-Release -ReleaseDefinitionName "TRM.CandidateRating.Web" -EnvironmentName "dev"

Export-ModuleMember -Function *
