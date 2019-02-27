<# 
    .Synopsis 
       Install-AzureAppService deploys an Azure App Service
    .DESCRIPTION 
       The Write-Log function is designed to add Azure deployment capability to other scripts. 
    .NOTES 
       Created by: 
 
       Changelog: 
        * Added documentation. 
 
       To Do: 
        * Validate 
        * Add retry logic
      
    .PARAMETER AppName 
       AppName is the name of the Azure Application
    .PARAMETER PackagePath
       The path to the application binaries zip file.  
    .PARAMETER DeploymentPassword 
       Specify the password for deploying in Azure 
    .EXAMPLE 
        $AppName = "myAzureapp001"
        $PackagePath = 'c:\temp\AzureAppBinaries.zip' 
        $DeploymentPassword = 'some thing'
        Install-AzureAppService -AppName $AppName -PackagePath $PackagePath -DeploymentPassword $DeploymentPassword

    .LINK 
#>
Function Install-AzureAppService
{
    [CmdletBinding()] 
    param
	(
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="Azure AppService Name")]
		[ValidateNotNullOrEmpty()]
		[string]$AppName,

		[Parameter(Mandatory=$true, HelpMessage="Azure AppService Package Path")]
		[ValidateNotNullOrEmpty()]
		[string]$PackagePath,

		[Parameter(Mandatory=$true, HelpMessage="Deployment user password")]
		[ValidateNotNullOrEmpty()]
		$DeploymentPassword
	)


    Begin 
    { 
        # Use this block for re-reqs (like creating log files or setting up needed variables). 
    }

    Process 
    { 
        $MSDeployKey = 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3' 
        if(!(Test-Path $MSDeployKey)) { 
            throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
        } 

        $InstallPath = (Get-ItemProperty $MSDeployKey).InstallPath 
        if(!$InstallPath -or !(Test-Path $InstallPath)) { 
            throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
        } 

        $msdeploy = Join-Path $InstallPath "msdeploy.exe" 
        if(!(Test-Path $MSDeploy)) { 
            throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
        } 

        [string[]] $arguments = 
         "-verb:sync",
         "-source:package='$PackagePath'",
         "-dest:auto,ComputerName='https://$($AppName).scm.azurewebsites.net:443/msdeploy.axd?site=$($AppName)',UserName='`$$($AppName)',Password='$($DeploymentPassword)',AuthType='Basic'",
         "-enableRule:AppOffline",
         "-enableRule:DoNotDeleteRule",
         "-userAgent:PowerShell",
         "-retryAttempts=3",
         "-verbose"

        Write-Verbose $msdeploy $arguments
        & $msdeploy $arguments
    }

    End 
    { 
        # Cleanup
    } 
}


Export-ModuleMember -Function Install-AzureAppService

