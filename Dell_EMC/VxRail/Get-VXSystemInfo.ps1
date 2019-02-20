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
                   Position = 0)]
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
            Invoke-RestMethod -Method Get -Uri "https://$HostName/rest/vxm/v1/system" -Headers $Headers | ForEach-Object {
               [PSCustomObject]@{
                  HostName            = $HostName
                  Health              = $PSItem.Health
                  InstalledComponents = $PSItem.Installed_Components | ForEach-Object {
                     [PSCustomObject]@{
                        Name           = $PSItem.Name
                        CurrentVersion = $PSItem.Current_Version
                        UpgradeStatus  = $PSItem.Upgrade_Status
                     }
                  }
               }
            }
        } catch {
            Write-Error -ErrorRecord $PSItem -ErrorAction $CallerErrorPreference
        }
    }
    end {}
}
