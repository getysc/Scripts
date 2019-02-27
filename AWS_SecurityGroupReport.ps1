<#
.SYNOPSIS
Generates a report of security groups.

.DESCRIPTION
Generates a report of security groups in each VPC.

.PARAMETER Protocol
Specifies a protocol filter. Only matching rules in matching security groups
will be displayed.

.PARAMETER Port
Specifies a port filter. Only matching rules in matching security groups will
be displayed.

.PARAMETER ProfileName
Specifies an AWS PowerShell Credential Profile to use when executing this
script.

.PARAMETER Region
Specifies a region to use when executing this script.
#>
[CmdletBinding()]
Param (
    [Parameter()]
    [ValidateSet("tcp", "udp", "icmp")]
    [string]$Protocol,

    [Parameter()]
    [ValidateRange(0, 65535)]
    [int]$Port,

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

    <#
    .SYNOPSIS
    Filters IpPermission objects based on protocol and port.

    .DESCRIPTION
    Filters IpPermission objects based on protocol and port, returning only
    objects that meet the specified criteria

    .PARAMETER InputObject
    One or more IpPermission objects to filter.

    .PARAMETER Protocol
    Specifies the protocol to filter for.

    .PARAMETER Port
    Specifies the port to filter for.

    .NOTES
    IpPermission objects that are for "all" protocols or ports will always be
    returned.
    #>
    Function Search-EC2SecurityGroupPermission {
        [CmdletBinding()]
        Param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [Amazon.EC2.Model.IpPermission[]]$InputObject,

            [Parameter()]
            [string]$Protocol,
        
            [Parameter()]
            [int]$Port
        )

        Process {
            foreach ($IpPermission in $InputObject) {
                # Determine if this rule matches our conditions.
                $Matched = $true

                # Match on protocol.
                if ($Protocol -and $IpPermission.IpProtocol -ne "-1") {
                    if ($IpPermission.IpProtocol -ne $Protocol) {
                        $Matched = $false
                    }
                }

                # Match on port.
                if ($Port -and $IpPermission.IpProtocol -ne "icmp" `
                        -and $IpPermission.FromPort -ne -1) {

                    if ($Port -lt $IpPermission.FromPort `
                            -or $Port -gt $IpPermission.ToPort) {
                                
                        $Matched = $false
                    }
                }

                if ($Matched) {
                    # If the rule is a match, return it.
                    Write-Output -InputObject $IpPermission
                }
            }
        }
    }

    <#
    .SYNOPSIS
    Creates a human-readable string from an AWS IpPermission object.
    
    .DESCRIPTION
    Creates a human-readable string from an Amazon.EC2.Model.IpPermission
    object.
    
    .PARAMETER InputObject
    One or more IpPermission objects to format.
    #>
    Function Format-EC2SecurityGroupPermission {
        [CmdletBinding()]
        Param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true
            )]
            [Amazon.EC2.Model.IpPermission[]]$InputObject
        )

        Process {
            foreach ($Item in $InputObject) {
                # Protocol.
                if ($Item.IpProtocol -eq "-1") {
                    $Protocol = "all"
                } else {
                    $Protocol = $Item.IpProtocol
                }

                # Port range.
                if ($Item.IpProtocol -eq "icmp") {
                    $PortRange = "n/a"
                } elseif ($Item.FromPort -eq -1 -or ($Item.FromPort -eq 0 `
                        -and $Item.ToPort -eq 0)) {
                    $PortRange = "all"
                } else {
                    $PortRange = $Item.FromPort.ToString()
                    if ($Item.ToPort -ne $Item.FromPort) {
                        $PortRange += "-$($Item.ToPort)"
                    }
                }

                # Source.
                $SourceList = @()
                foreach ($Ipv4Range in $Item.Ipv4Ranges) {
                    $SourceList += $Ipv4Range.CidrIp
                }
                
                foreach ($UserIdGroupPair in $Item.UserIdGroupPairs) {
                    $SourceList += $UserIdGroupPair.GroupId
                }
                $Source = $SourceList -join ", "

                # Final output.
                $Output = "proto: $($Protocol.PadRight(4)) " + `
                    "port(s): $($PortRange.PadRight(11)) " + `
                    "source: $Source"

                Write-Output -InputObject $Output
            }
        }
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

    Clear-Host

    # Retrieve data.
    $VpcList = @(Get-EC2Vpc) | Sort-Object -Property VpcId
    $SecurityGroups = @(Get-EC2SecurityGroup)

    # Filter data.
    $OutputData = @()

    foreach ($Vpc in $VpcList) {
        # Make a friendly formatted name string for the VPC.
        $VpcNameTag = $Vpc.Tags | Where-Object -Property Key -eq "Name"
        if ($VpcNameTag) {
            $VpcName = "$($VpcNameTag.Value) ($($Vpc.VpcId))"
        } else {
            $VpcName = $Vpc.VpcId
        }
        if ($Vpc.IsDefault) {
            $VpcName += " *"
        }

        # Create an item to represent this VPC.
        $VpcItem = [pscustomobject][ordered] @{
            Name = $VpcName
            SecurityGroups = @()
        }

        # Get Security Groups for this VPC.
        $SecurityGroupList = $SecurityGroups | `
            Where-Object -Property VpcId -eq $Vpc.VpcId | `
            Sort-Object -Property GroupName

        foreach ($SecurityGroup in $SecurityGroupList) {
            $MatchingPermissions = $SecurityGroup.IpPermissions | `
                Search-EC2SecurityGroupPermission `
                    -Protocol $Protocol `
                    -Port $Port

            # If any rules for this group match, display the group in the
            # output of the report.
            if ($MatchingPermissions) {
                $SecurityGroupItem = [pscustomobject][ordered] @{
                    GroupId = $SecurityGroup.GroupId
                    GroupName = $SecurityGroup.GroupName
                    Description = $SecurityGroup.Description
                    IpPermissions = $MatchingPermissions
                }
                
                $VpcItem.SecurityGroups += $SecurityGroupItem
            }
        }

        # Always display every VPC.
        $OutputData += $VpcItem
    }

    # Format and output data.
    foreach ($Vpc in $OutputData) {
        Write-Information -MessageData ("-" * 80) -InformationAction Continue
        Write-Information -MessageData "- VPC: $($Vpc.Name)" -InformationAction Continue
        Write-Information -MessageData ("-" * 80) -InformationAction Continue

        if ($Vpc.SecurityGroups.Count -gt 0) {
            foreach ($SecurityGroup in $Vpc.SecurityGroups) {
                Write-Information -MessageData "  $("-" * 78)" `
                    -InformationAction Continue

                Write-Information -MessageData `
                    ("  Seurity Group: $($SecurityGroup.GroupName) " + `
                    "($($SecurityGroup.GroupId))") -InformationAction Continue

                Write-Information -MessageData `
                    "    $($SecurityGroup.Description)" `
                    -InformationAction Continue
                    
                Write-Information -MessageData "`n  Rules:" `
                -InformationAction Continue

                $SortedPermissions = $SecurityGroup.IpPermissions | `
                    Format-EC2SecurityGroupPermission | `
                    Sort-Object

                foreach ($IpPermission in $SortedPermissions) {
                    Write-Information -MessageData "    $IpPermission" `
                        -InformationAction Continue
                }

                Write-Information -MessageData "" -InformationAction Continue
            }
        } else {
            Write-Information -MessageData "No security groups" `
                -InformationAction Continue
        }

        Write-Information -MessageData "" -InformationAction Continue
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