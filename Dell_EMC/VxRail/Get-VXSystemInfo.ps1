
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-VXSystemInfo {
    [CmdletBinding()]
    param (
        # System to Connect to
        [Parameter(Mandatory = $True,
                   ValueFromPipeline = $True,
                   Position=0)]
        [Alias('Url')]
        $HostName,

        # Credentials to access system
        [Parameter(Mandatory = $True)]
        [PSCredential]
        $Credential = (Get-Credential)
    )
    begin {
        $CallerErrorPreference = $ErrorActionPreference
        Unblock-SelfSignedCerts -ErroAction 'SilentlyContinue'
        try {
            $ErrorActionPreference = 'Stop'
            $Headers = @{
                Authorization = "Basic {0}" -f [System.Convert]::ToBase64String(
                     [System.Text.Encoding]::ASCII.GetBytes(
                        ($Credential.Username,$Credential.GetNetworkCredential().Password) -join ":"
                    )
                )
            }
        } catch {
            Write-Error -ErrorRecord $PSItem -ErrorAction 'Stop'
        }
    }
    process {
        try {
            $ErrorActionPreference = 'Stop'
            $VXRailSystemInfo = Invoke-RestMethod -Method Get -Uri "https://$HostName/rest/vxm/v1/system" -Headers $Headers
            [PSCustomObject]@{
                Name = $VXRailSystemInfo.Installed_Components.Name
                Health = $VXRailSystemInfo.Health
                CurrentVersion = $VXRailSystemInfo.Installed_Components.Current_Version
                UpgradeStatus = $VXRailSystemInfo.Installed_Components.Upgrade_Status
            }
        } catch {
            Write-Error -ErrorRecord $PSItem -ErrorAction $CallerErrorPreference
        }
    }
    end {}
}
