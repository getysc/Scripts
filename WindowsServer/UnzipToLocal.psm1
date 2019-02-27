  <#
  .SYNOPSIS
  Unzip source path to destination path.
  .DESCRIPTION
   unzip source path to destination path
  .EXAMPLE
  UnzipToLocal -SourcePath "C://" -DestinationPath "D://" -Retry 3, -Sleep 5
  .EXAMPLE
  Give another example of how to use it
  
  #>

function UnzipToLocal($SourcePath, $DestinationPath, $Retry, $Sleep)
{
	Write-Verbose "[ENTER] UnzipToLocal" -Verbose

	$Success = $false
	$i = 0
	Do
	{
		if($i -gt $Retry)
		{
			Write-Error "All retry done cannot unzip $SourcePath to $DestinationPath"
			return $Success
			break
		}
		try
		{
			if($i -gt 0)
			{
				Write-Verbose "Going for sleep before retry sleep time: $Sleep" -Verbose
				Start-Sleep $Sleep
			}
			$i++
				Write-Verbose "Starting unzip to local" -Verbose
				Expand-Archive -Path $SourcePath -DestinationPath $DestinationPath -Force 
				Write-Verbose "Done unzip to local" -Verbose
				$Success = $true
		}
		catch
		{
			Write-Verbose "Error occured when trying UnzipToLocal from source path $SourcePath destination path $DestinationPath  $_ "  -Verbose
		}
	}
	While ($Success -ne $true)
	
	Write-Verbose "[EXIT]  UnzipToLocal" -Verbose
	return $Success
}

export-modulemember -function UnzipToLocal