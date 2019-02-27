Function Get-VaultSecret 
{
  <#
  .SYNOPSIS
  Use the secretname parameter and return the secret from Azure Key Vault matching that name.
  .DESCRIPTION
  Describe the function in more detail
  .EXAMPLE
  Get-VaultSecret -secretname "Env-App1-AppSettings"
  .EXAMPLE
  Give another example of how to use it
  .PARAMETER secretname
  Name of the secret stored in the vault.
  #>
  [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
  param
  (
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage='Name of the secret stored in the vault.')]
    [string]$secretname,

    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage='Access key.')]
    [string]$accesskey


  )

  $Global:TenantId = ""
  $Global:UserName = ""
  $Global:VaultName = ""
  $Global:Env = ""
  $Global:PwdText = ""

  Function Get-Env {
     
     $Global:Env = $secretname.Split("-")[0]

  }

  Function Set-Config {
    if ($Global:Env -eq "PRD")
    {
        $Global:UserName = ""
        $Global:PwdText = ""
        $Global:TenantId = ""
        $Global:VaultName = ""
    }
    else
    {
        $Global:UserName = "11111-23e7-414f-9240-86ae69697d5e"
        $Global:TenantId = "222222-1cd4-4389-8df1-9d8013937102"
   
        $Global:VaultName = "your-vault-name"
    }

  }

 

	Function Get-Secret 
	{
		$securePwd = ConvertTo-SecureString $accesskey -AsPlainText -Force 
		$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $Global:UserName, $securePwd
		$l = Login-AzureRmAccount -ServicePrincipal -Credential $credObject -TenantId $Global:TenantId
		$secret = Get-AzureKeyVaultSecret -VaultName $Global:VaultName -Name $secretname
    
		return $secret.SecretValueText
	}


	Get-Env

	Set-Config

	return Get-Secret

}

export-modulemember -function Get-VaultSecret
