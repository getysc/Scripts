<#
.SYNOPSIS
Checks the health state of one or more EC2 instances.

.DESCRIPTION
Checks the health state of one or more EC2 instances by Instance ID.

.PARAMETER InstanceId
Specifies the Instance ID of the EC2 instance to report on.

.PARAMETER ProfileName
Specifies an AWS PowerShell Credential Profile to use when executing this
script.

.PARAMETER Region
Specifies a region to use when executing this script.
#>
[CmdletBinding()]
Param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string[]]$InstanceId,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ProfileName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Region
)

Begin {
    # This flag allows us to abort the actual execution of the script if any of
    # the checks in the Begin block fail.
    $Script:AbortFromBegin = $false

    # Import the AWS PowerShell module. Stop if unsuccessful, since we won't be
    # able to do anything useful without it. Also, we are forcing Verbose to
    # false to prevent tons of output when the caller wants verbose output from
    # the script.
    Import-Module -Name AWSPowerShell -Verbose:$false -ErrorAction Stop

    # If the caller gave us a profile name to use, set that up.
    if ($PSBoundParameters.ContainsKey("ProfileName")) {
        # There might be a session profile set already. Store it so we can put
        # it back later.
        $Script:PreviousSessionCredential = Get-AWSCredential

        # Now set a session default credential to use for our script.
        Write-Verbose -Message "Setting session default profile to '$ProfileName'."
        Set-AWSCredential -ProfileName $ProfileName

        # The special variable $? will contain true if the previous command was
        # successful, otherwise false. If we failed to set the session profile,
        # abort the script.
        $Script:AbortFromBegin = $Script:AbortFromBegin -or !$?
    }
    
    # If the caller gave us a region to use, set that up.
    if ($PSBoundParameters.ContainsKey("Region")) {
        # There might be a session default region set already. Store it so we
        # can put it back later.
        $Script:PreviousDefaultRegion = Get-DefaultAWSRegion

        # Now set a session default region to use for our script.
        Write-Verbose -Message "Setting session default region to '$Region'."
        Set-DefaultAWSRegion -Region $Region

        # Again using $? to test if the previous command worked, and aborting
        # if it didn't.
        $Script:AbortFromBegin = $Script:AbortFromBegin -or !$?
    }
}

Process {
    # If something went wrong in the Begin block, do not perform any processing.
    if ($Script:AbortFromBegin) {
        return
    }

    #---------------------------------------------------------------------------
    # Your code here
    #---------------------------------------------------------------------------

    foreach ($Item in $InstanceId) {
        # Get status for this instance.
        $Status = Get-EC2InstanceStatus -InstanceId $Item -IncludeAllInstance $true

        # Create object to write to output.
        $OutputObject = [pscustomobject][ordered] @{
            InstanceId = $Status.InstanceId
            State = $Status.InstanceState.Name
            Status = $Status.Status.Status
            SystemStatus = $Status.SystemStatus.Status
        }

        # Produce output.
        Write-Output -InputObject $OutputObject
    }
}

End {
    # If the caller passed in a profile name, we need to reset the session's
    # default profile to whatever it was.
    if ($PSBoundParameters.ContainsKey("ProfileName")) {
        if ($Script:PreviousSessionCredential) {
            # This session had a default profile set. Put it back.
            Write-Verbose -Message "Restoring previous session default profile."
            Set-AWSCredential -Credential $Script:PreviousSessionCredential
        } else {
            # This session had no default profile set. Clear the profile we just
            # used for this script.
            Write-Verbose -Message "Clearing session default profile."
            Clear-AWSCredential
        }
    }

    # If the caller passed in a default region, we need to reset the session's
    # default region to whatever it was.
    if ($PSBoundParameters.ContainsKey("Region")) {
        if ($Script:PreviousDefaultRegion) {
            # This session had a default region set. Put it back.
            Write-Verbose -Message "Restoring previous session default region."
            Set-DefaultAWSRegion -Region $Script:PreviousDefaultRegion
        } else {
            # This session had no default region set. Clear the region we just
            # used for this script.
            Write-Verbose -Message "Clearing session default region."
            Clear-DefaultAWSRegion
        }
    }
}