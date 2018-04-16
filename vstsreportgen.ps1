<#
   
       This script produces VSTS work item report (for ITEDs)
       
       You must set the Personal access token (PAT) in the expected path (or thourgh command line).

        Usage:
        Run below command at powershell prompt (admin mode)
        PS C:\> .\ITED-Report-Generator.ps1 -token "VSTSToken"
#>
Param(
    [string]$user = "",
    [string]$token = (Get-Content "c:\windows\VSTSToken.txt"),
    [string]$vstsAccount = 'https://your_company.visualstudio.com'
)

#$PSScriptRoot
$script_path = $MyInvocation.MyCommand.Path
$script_folder = Split-Path $script_path -Parent
$outputFile = $script_path.Replace('ps1', 'log')
Set-Location $script_folder
New-Item $outputFile -ItemType file -Force | Out-Null

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))


function SendMail
{
    param(
        $htmlFile
    )

    $smtpServer = "relayprod.your_company.com"
    $smtpFrom = fromuser@your_company.com"
    $smtpTo = "touser@your_company.com"
    $smtpCc = "ccuser@your_company.com"
    $smtpSubject = "System Deployment ITEMS on Release  1.X.X.X"


    $body = Get-Content -Path $htmlFile | Out-String
    #$smtpFrom 
    #$smtpTo 
    #$smtpSubject 
    #$smtpServer

    Send-MailMessage -From $smtpFrom -To $smtpTo -Cc $smtpCc -Subject $smtpSubject -Body $body -BodyAsHtml  -SmtpServer $smtpServer # -dno onSuccess, onFailure
}

function LogFile
{ 
    param(
        $data
    )

    Add-Content $outputFile "$($data)"
}


function GetRestMethod
{ 
    param(
        $Uri
    )

    $result = Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    $result
}




function IsPositiveinteger ($Value)
{
	return $Value -match "^\d+$"
}

function GetWokItemParentId
{ 
    param(
        $relations
    )

    $hasParent = $null
    foreach ($relation in $relations)
    {
	    if ($relation.rel -eq "System.LinkTypes.Hierarchy-Reverse")
	    {
	        Write-host "Parent WI    => " $relation.url
	        $hasParent =  $relation.url.Split('/')[-1]
	    }
    }
    Write-host "hasParent    => " $hasParent

    return $hasParent
}

function GetChildWokItems
{ 
    param(
        $relations
    )

    $childWIs = @()
    foreach ($relation in $relations)
    {
	    if ($relation.rel -eq "System.LinkTypes.Hierarchy-Forward")
	    {
	        #Write-host "`tChild  WI     => " $relation.url
	        #$childWI =  $relation.url.Split('/')[-1]
            $childWIs = $childWIs + $relation.url
	    }
    }
    Write-host "Child wi's        => " $childWIs.Count 

    return $childWIs
}


function WorkItemHasArtifactLinks
{ 
    param(
        $relations
    )

    foreach ($relation in $relations)
    {
	    if ($relation.rel -eq "ArtifactLink")
	    {
            Write-host "Artifact Link     => FOUND" -foreground "green"
            return $true
	    }
    }

    Write-host "Artifact Link     => NOT found"
    return $false
}

function GetVSTSWorkItemDetails
{ 
    param(
        [string]$taskId
    )

    $TaskUri = "$($vstsAccount)/DefaultCollection/_apis/wit/workitems?ids=" + $taskId + "&`$expand=all&api-version=1.0"
    #Write-host "Task Uri          =>" $TaskUri

    $result = GetRestMethod -Uri $TaskUri 
    #"RELATIONS:: " + $result.value.relations.Count 
    $result
}

function PrintWIArtifactInformation
{ 
    param(
        [string]$taskId
    )

    $result = GetVSTSWorkItemDetails $taskId 
    #"RELATIONS:: " + $result.value.relations.Count 

    $workItemType = $result.value.fields.'System.WorkItemType'
    Write-host "Task ID           =>" $taskId "(" $workItemType ")"
    $hasArtifactLink = WorkItemHasArtifactLinks $result.value.relations

    if ($hasArtifactLink)
    {
        #LogFile "$($taskId) TRUE $($workItemType)"
        LogFile "TRUE"
    }
    else
    {
        $childWorkItemUris = GetChildWokItems $result.value.relations
        foreach($childWorkItemUri in $childWorkItemUris)
        {
            $childTaskId = $childWorkItemUri.Split('/')[-1]
            Write-Host -NoNewline "`t    $($childTaskId) => "
            
            $apiResponse = GetVSTSWorkItemDetails $childTaskId
            $hasArtifactLink = WorkItemHasArtifactLinks $apiResponse.value.relations
            if ($hasArtifactLink -eq $true)
            {
                break;
            }    
        }

        if ($hasArtifactLink -eq $true)
        {
            #LogFile "$($taskId) TRUE"# $($workItemType)"
            LogFile "TRUE"
        }    
        else
        {
            #LogFile "$($taskId) FALSE"# $($workItemType)"
            LogFile "FALSE"
        }
    }

    Write-Host ""
}


#$taskId = "10759"
#PrintWIArtifactInformation $taskId 

<#
Get-Content $WorkItemIdsFile | Foreach-Object {

	$taskId = $_

    if (IsPositiveinteger $taskId)
	{
        PrintWIArtifactInformation $taskId 
    }
}
type .\WorkItemArtifactChecker.log

#>


#
# Get all queries 
# https://your_company.visualstudio.com/DefaultCollection/TRM/_apis/wit/queries?$depth=1&api-version=2.2
#
# Get queries under a folder
# https://your_company.visualstudio.com/DefaultCollection/CRM/_apis/wit/queries/My%20Queries?$depth=1&api-version=2.2
#

function GetWorkItemsFromStoredQuery
{ 
    param(
        [string]$storedWIQuery
    )

    #Write-Host "Get wiql from stored WI query=>" $storedWIQuery
    $storedWIQueryResult = GetRestMethod -Uri $storedWIQuery

    # Get WI's using wiql
    $wiqlQuery = $storedWIQueryResult._links.wiql.href
    #Write-Host "Get WI's using wiqlQuery =>" $wiqlQuery
    $wiqlQueryResult = GetRestMethod -Uri $wiqlQuery
        
    Write-Host "No. of workItems :: " $wiqlQueryResult.workItems.Count
    $wiqlQueryResult.workItems
}


function GetHeader
{
    $a = '<style>'
    $a = $a + 'BODY{background-color:peachpuff;}'
    $a = $a + 'TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}'
    $a = $a + 'TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}'
    $a = $a + 'TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}'
    $a = $a + '</style>'
    $a
}

function Get-WorkItemInformation { #Begin function Get-ComputerInformation
    [cmdletbinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        $workItemData
    )

    $TeamProject = $workItemData.fields.'System.TeamProject'
    $hasArtifactLink = WorkItemHasArtifactLinks $workItemData.relations

    $ReleaseNotes = ' '
    switch -wildcard ($TeamProject)
    {
        "CRM"
        {
            $ReleaseNotes = $workItemData.fields.'CRMScrum001.ReleaseNotesCRM'
            break;
        }

        "TRM"
        {
            $ReleaseNotes = $workItemData.fields.'Agile001.ReleaseNotes'
            break;
        }

        "Time and Expense Program"
        {
            $ReleaseNotes = $workItemData.fields.'Agile001.ReleaseNotes'
            break;
        }

        "ITS Delivery"
        {
            $ReleaseNotes = $workItemData.fields.'Agile001.ReleaseNotes'
            break;
        }

        default
        {
            throw "Unsupported project: $($TeamProject)"
        }
    }

    $workItemEditUrl = "$($vstsAccount)/$($TeamProject)/_workitems/edit/" + $workItemData.id

    #Create the object, cleanly!
    $workItemObject = [PSCustomObject]@{
            Id                   = $workItemData.id
            WorkItemType         = $workItemData.fields.'System.WorkItemType'
            Title                = $workItemData.fields.'System.Title'
            State                = $workItemData.fields.'System.State'
            AssignedTo           = $workItemData.fields.'System.AssignedTo'
            IterationPath        = $workItemData.fields.'System.AreaPath'
            ReleaseNotes         = $ReleaseNotes
            CodeAttached         = $hasArtifactLink
            Url                  = $workItemEditUrl #$workItemData.url
    }

    Return $workItemObject
}



function GetWorkItemsData
{ 
    param(
        $workItems
    )

    [System.Collections.ArrayList]$workitemsArray = @()
    if ($workItems.Count -ne 0)
    {
    
        # Get workitem ids and join them with ','
        $workItemsIds = [System.String]::Join(",", $workItems.id)

        $uri = "$($vstsAccount)/DefaultCollection/_apis/wit/WorkItems?ids=" + $workItemsIds + '&$expand=relations'  #OR use&fields=System.Id,System.WorkItemType,System.Title,System.AssignedTo,System.State,Agile001.ReleaseNotes
        Write-Host "Query workItems :: " $uri
        $result = GetRestMethod -Uri $uri 
        #$header = GetHeader
        #$result.value.fields | ConvertTo-HTML -head $header -Body "<H2>WI Information</H2>" | Out-File "c:\temp\test.htm"

    
        ForEach($workItemData in $result.value) {

            $workitemsArray.Add((Get-WorkItemInformation $workItemData)) | Out-Null
        }
    }

    $workitemsArray
}


function CreateHTMLTableRows
{ 
    param(
        $workitemsArray
    ) 

    [string]$tableRowTemplate = Get-Content "$($script_folder)\html_tabe_row_template.html"

    $result = ""
    Foreach ($workitem in $workitemsArray)
    {
        $tableRow = $tableRowTemplate.Replace('WORKITEM_ID', $workitem.Id)
        $tableRow = $tableRow.Replace('WORKITEM_URL', $workitem.Url)
        $tableRow = $tableRow.Replace('WORKITEM_TYPE', $workitem.WorkItemType)
        $tableRow = $tableRow.Replace('WORKITEM_TITLE', $workitem.Title)
        $tableRow = $tableRow.Replace('WORKITEM_STATE', $workitem.State)
        $tableRow = $tableRow.Replace('WORKITEM_AssignedTo', $workitem.AssignedTo)
        $tableRow = $tableRow.Replace('WORKITEM_ReleaseNotes', $workitem.ReleaseNotes)
        $tableRow = $tableRow.Replace('WORKITEM_CodeAttached', $workitem.CodeAttached)
        $result = $result +  $tableRow
    }

    $result 
 }

function CreateHTMLTable
{ 
    param(
        $htmlTableRows,
        $VSTSP
    ) 

    [string]$htmltableTemplate = Get-Content "$($script_folder)\html_table_template.html"
    $htmlTable = $htmltableTemplate.Replace('TABLE_ROWS', $htmlTableRows)
    $htmlTable = $htmlTable.Replace('VSTS_PROJECT_NAME', $TeamProject)
    $htmlTable 
}

function CreateHTMLFile
{ 
    param(
        $htmlTables
    ) 

    $outputFilePath = "$($script_folder)\ITED-Report.html"
    [string]$htmlTemplate = Get-Content "$($script_folder)\result_template.html"
    $htmlFile = $htmlTemplate.Replace('HTML_BODY', $htmlTables)
    $htmlFile | Out-File -FilePath $outputFilePath -Force
    
    #Invoke-Expression $outputFilePath
    SendMail $outputFilePath
}


$storedWIqueries = @(
    "$($vstsAccount)/DefaultCollection/CRM/_apis/wit/queries/Shared%20Queries/CurrentSprintWorkItemsAndBugs?$depth=1&api-version=2.2"#,
    "$($vstsAccount)/DefaultCollection/TRM/_apis/wit/queries/My%20Queries/CurrentSprintWorkItemsAndBugs?$depth=1&api-version=2.2",
    "$($vstsAccount)/DefaultCollection/Time and Expense Program/_apis/wit/queries/My%20Queries/CurrentSprintWorkItemsAndBugs?$depth=1&api-version=2.2",
    "$($vstsAccount)/DefaultCollection/ITS Delivery/_apis/wit/queries/My%20Queries/CurrentSprintWorkItemsAndBugs?$depth=1&api-version=2.2"
);


$htmlTables = " "
$storedWIqueries | Foreach-Object {

    $TeamProject = ($_ -split '/')[4]
    $workItems = GetWorkItemsFromStoredQuery $_

    $workitemsArray = GetWorkItemsData $workItems
    $htmlTableRows = CreateHTMLTableRows $workitemsArray
    $htmlTable = CreateHTMLTable $htmlTableRows $TeamProject
    $htmlTables = $htmlTables + $htmlTable
}
CreateHTMLFile $htmlTables



$token
