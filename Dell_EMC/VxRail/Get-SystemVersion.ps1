### Main Function, only used to call Get-HeaderInfo ###
function Get-VxRailSystemInfo{
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$hostname
)
   
    Get-HeaderInfo -hostname $hostname

}

### Ignore soft/self-signed certs, can be used alone ###
function Ignore-SelfSignedCerts{
    try
    {
        Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy
        {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem)
             {
                 return true;
            }
        }
"@
      }
    catch
    {
        write-host $_ -ForegroundColor "Yellow"
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

### Gets user credentials then encodes them to base64 for HTTP request ###
function Get-HeaderInfo{
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    $hostname
)
    Ignore-SelfSignedCerts
    $cred = Get-Credential
    $Headers = @{'Authorization' = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(-join ("$($cred.GetNetworkCredential().username)",":", "$($cred.GetNetworkCredential().password)"))))"}
    Get-SystemInfo -Headers $Headers -hostname $hostname
}

### REST Get request to VxRail Manager using provided encoded login credentials ###
function Get-SystemInfo{
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $Headers,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        $hostname
    )
    try {
        $vxrailSystemInfo = Invoke-RestMethod -Method Get -Uri "https://$hostname/rest/vxm/v1/system" -Headers $Headers
        Remove-Variable -Name cred -ErrorAction SilentlyContinue
        Print-SystemInfo -systemInfo $vxrailSystemInfo
    } catch [System.Net.WebException]{
       write-host "Error : System.Net.WebException...Please check error logs for more details"
    }
}

### Takes information sent from Get-SystemInfo and outputs only specified info ###
function Print-SystemInfo{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $systemInfo
    )
    Write-Host "Health : " $systemInfo.health`n
    write-host "Installed Components"
    $systemInfo.installed_components | select name, current_version, upgrade_status
}