#
#
# Usage:
# 
# Starts a process (console application)
# .\Start-Process.ps1  -ServiceAccount "KFORCE\SVC-CRATENONPROD" -BinaryName "Kforce.TRM.CandidateRating.UpdateRating.exe" -InstallPath "D:\srvapps\CandidateRating.UpdateRating\DEV\" 
#
#
#  **** You must set variable "ServiceAccountPassword" *******
#
param(
	[parameter(Mandatory=$true, HelpMessage="Binary Name")]
        [ValidateNotNullOrEmpty()]
	[string]$BinaryName,

	[parameter(Mandatory=$true, HelpMessage="Binary Install Path")]
        [ValidateNotNullOrEmpty()]
	[string]$InstallPath,

	[parameter(Mandatory=$true, HelpMessage="Run as Service Account")]
        [ValidateNotNullOrEmpty()]
	[string]$ServiceAccount
)

$Environment = "__Environment__"
$NonProdServiceAccountPassword = "__NonProdServiceAccountPassword__"
$ProdServiceAccountPassword = "__ProdServiceAccountPassword__"

Write-Verbose -Verbose  "Environment    :: $Environment"

$ServiceAccountPassword = $NonProdServiceAccountPassword
if ($Environment.ToLower() -eq "prod")
{
	Write-Verbose -Verbose  "Using ProdServiceAccountPassword as ServiceAccountPassword"
	$ServiceAccountPassword = $ProdServiceAccountPassword
}

Write-Verbose -Verbose  "ServiceAccountPassword      :: $ServiceAccountPassword"
$binaryPath = Join-Path $InstallPath $BinaryName
Write-Verbose -Verbose  "BinaryName      :: $BinaryName"
Write-Verbose -Verbose  "InstallPath     :: $InstallPath"
Write-Verbose -Verbose  "ServiceAccount  :: $ServiceAccount"
Write-Verbose -Verbose  "binaryPath      :: $binaryPath"

if ([string]::IsNullOrEmpty($ServiceAccountPassword))
{
	throw "ServiceAccountPassword is empty or null"
}
$secpasswd = ConvertTo-SecureString $ServiceAccountPassword -AsPlainText -Force
$ServiceAccountCredentials = New-Object System.Management.Automation.PSCredential ($ServiceAccount, $secpasswd)
#Start-Process -WindowStyle hidden -FilePath $binaryPath -WorkingDirectory $InstallPath -Credential $ServiceAccountCredentials
Start-Process -FilePath $binaryPath -WorkingDirectory $InstallPath -Credential $ServiceAccountCredentials

