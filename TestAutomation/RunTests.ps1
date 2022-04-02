Param(
    [string]
    [Parameter(Mandatory = $false)]
    $TestCategory = "BVT",

    [string]
    [Parameter(Mandatory = $false)]
    $TestRunTitle = "MyApplication Health Checks",

    [string]
    [Parameter(Mandatory = $false)]
    $EmailAlias = "Sreekanth_Yarlagadda@MyOrg.com"
)

<#
# $vstestconsolepath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
#
$regKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\devenv.exe"
$visualStudioDir = Get-ItemPropertyValue -Path $regKey -Name "(Default)"
$visualStudioDir = ($visualStudioDir.Replace("devenv.exe","")).replace("`"","")
$vstestPath = 'CommonExtensions\Microsoft\TestWindow\vstest.console.exe'
$vstestconsolepath = Join-Path   $visualStudioDir $vstestPath
#>

$vstestconsolepath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
if(!(Test-Path $vstestconsolepath))
{
	$vstestconsolepath = "E:\VS2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
}

Write-Host "Input arguments"
Write-Host "`t TestCategory:: $TestCategory"
Write-Host "`t Engine:: $vstestconsolepath"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here


$TRXFilePath = Join-Path $here "MyApplication.HealthChecks.trx"
if (Test-Path $TRXFilePath) 
{
    Remove-Item $TRXFilePath -Force
}

if ($TestCategory -eq "All")
{
	$TestCategory= "BVT|TestCategory=FUNC"
}

$vstestArgumentsList = @(
	"MyApplication.HealthChecks.dll",
	"/logger:`"trx;LogFileName=$TRXFilePath`"",
	"/Settings:JEMS.runsettings",
	"/TestCaseFilter:`"TestCategory=$TestCategory`""
)
"& `"$vstestconsolepath`" $vstestArgumentsList"
& "$vstestconsolepath" $vstestArgumentsList 

$TRX2HTML = Join-Path $here "TRX2HTML.exe"
$trx2htmlArgumentsList = @(
	"`"$TRXFilePath`"",
	"`"$TestRunTitle`"",
	"`"$EmailAlias`""
)
"& `"$TRX2HTML`" $trx2htmlArgumentsList"
& "$TRX2HTML" $trx2htmlArgumentsList
