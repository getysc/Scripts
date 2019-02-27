#
# 
#
#
# Unzip a file to target folder
# 
# Usage: 
# 
# .\Unzip.ps1 -ZipFilePath "c:\temp\eula.zip" -OutputPath "c:\temp\eula" 
#
param(
		[parameter(Mandatory=$true, HelpMessage="Zip File Path.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_  -PathType leaf})]
		[string]$ZipFilePath,

		[parameter(Mandatory=$true, HelpMessage="Output Path.")]
        [ValidateNotNullOrEmpty()]
		[string]$OutputPath,

		[parameter(Mandatory=$false, HelpMessage="Clean Output Path.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet($false,$true)]
		[string]$cleanOutput = $true,

		[parameter(Mandatory=$false, HelpMessage="Remove zip file")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet($false,$true)]
		[string]$RemoveZipFile = $false
)

Write-Verbose "     Zip file : $ZipFilePath" -Verbose
Write-Verbose "  Output path : $OutputPath" -Verbose
Write-Verbose " Clean Output : $cleanOutput" -Verbose
Write-Verbose "RemoveZipFile : $RemoveZipFile" -Verbose
Write-Verbose "" -Verbose

Add-Type -AssemblyName System.IO.Compression.FileSystem
if(!(Test-Path -Path $OutputPath)) 
{
    Write-Verbose "Creating folder : $OutputPath" -Verbose
    New-Item -ItemType directory -Path $OutputPath
}
else 
{
    if($cleanOutput)
    {
        Write-Verbose "Cleaning folder : $OutputPath" -Verbose
        Remove-Item "$OutputPath\*" -Recurse -Force
    }
}

Write-Verbose "Star extract zip file ..." -Verbose
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFilePath, $OutputPath)
Write-Verbose "Extracting is finished." -Verbose

if($RemoveZipFile -eq $true)
{
    Write-Verbose "Deleting source zip file..." -Verbose
    Remove-Item $ZipFilePath -Force -Recurse
    Write-Verbose "Zip file is deleted." -Verbose
}

Write-Verbose "Operation has been completed successfully." -Verbose
