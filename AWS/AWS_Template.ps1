<#
.SYNOPSIS
Template for an AWS PowerShell script.

.DESCRIPTION
Fill in your own synopsis and description when you write your script.

.PARAMETER ProfileName
Specifies an AWS PowerShell Credential Profile to use when executing this
script.

.PARAMETER Region
Specifies a region to use when executing this script.
#>
[CmdletBinding()]
Param (
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