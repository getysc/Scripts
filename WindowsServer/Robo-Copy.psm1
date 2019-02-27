<# 
    .Synopsis 
       Robo-copies files to target location
    .DESCRIPTION 
       Robo-copies files to target location
    .NOTES 
       Created by: 
 
       Changelog: 
        * Added documentation. 
 
       To Do: 
      
    .PARAMETER DestinationPath
       Destination Path to copy to
    .PARAMETER SourcePath
       The path to the application binaries zip file.  
    .EXAMPLE 
        $DestinationPath = "c:\temp"
        $SourcePath = 'd:\temp' 
        Copy-Package -DestinationPath $DestinationPath -SourcePath $SourcePath

    .LINK 
#>
Function Copy-Package
{
    [CmdletBinding()] 
    param
	(
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="Destination Path")]
		[ValidateNotNullOrEmpty()]
		[string]$DestinationPath,

		[Parameter(Mandatory=$true, HelpMessage="Source Path")]
		[ValidateNotNullOrEmpty()]
		[string]$SourcePath
	)


    Begin 
    { 
        # Use this block for re-reqs (like creating log files or setting up needed variables). 
    }

    Process 
    { 
        Write-Verbose "[ROBOCOPY] SourcePath= $SourcePath DestinationPath $DestinationPath"

		$date        = Get-Date -UFormat "%Y%m%d" 
		$what        = @("/COPYALL","/B","/SEC","/MIR") 
		$options     = @("/R:1000000", "/W:5")  

		$startDTM = (Get-Date)
		$cmdArgs     = @("$SourcePath","$DestinationPath",$what,$options)  
		Write-Verbose "Checking for target folder" -Verbose
		if (!(Test-Path -Path $DestinationPath)){
			Write-Verbose "Folder does not exist, creating" -Verbose
			New-Item -ItemType directory -Path $DestinationPath
		}
		else
		{
		   Write-Verbose "Folder exists" -Verbose
		}

		Write-Verbose "Copying $SourcePath to $TargetDir" -Verbose
		
		robocopy @cmdArgs
		$ExitCode = $LastExitCode
		$endDTM = (Get-Date)

		$Time = "Elapsed Time: $(($endDTM-$startDTM).totalminutes) minutes" 

		Write-Verbose "[ROBOCOPY] Copy completed in $Time"
    }

    End 
    { 
        # Cleanup
    } 
}


Export-ModuleMember -Function Copy-Package

