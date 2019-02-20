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
function Get-KbArticles {
    [CmdletBinding()]
    param (
        # HostName To connect to
        [Parameter(Mandatory = $True,
                   ValueFromPipeline = $True,
                   Position = 0)]
        $HostName,
        
        #Credentials to connect with
        [Parameter(Mandatory = $True)
        $Credential
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
         Invoke-RestMethod -Method Get -Uri "https://$hostname/rest/vxm/v1/support/kb/articles" -Headers $Headers
      } catch {
         Write-Error -ErrorRecord $PsItem -ErrorAction $CallerErrorPreference
   }
   end {}
}
