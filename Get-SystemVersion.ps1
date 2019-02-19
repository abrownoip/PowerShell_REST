### Main Function, only used to call Get-HeaderInfo ###
 function Get-VxRailSystemInfo{
    Get-HeaderInfo
}

### Ignore soft/self-signed certs, can be used alone ###
function Ignore-SelfSignedCerts{
    try{
        Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem) {
                 return true;
            }
        }"@
      }
    catch {
        write-host $_ -ForegroundColor "Yellow"
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

### Gets user credentials then encodes them to base64 for HTTP request ###
function Get-HeaderInfo {
    Ignore-SelfSignedCerts
    $cred = Get-Credential
    $Headers = @{'Authorization' = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(-join ("$($cred.GetNetworkCredential().username)",":", "$($cred.GetNetworkCredential().password)"))))"}
    Get-SystemInfo -Headers $Headers
}

### REST Get request to VxRail Manager using provided encoded login credentials ###
function Get-SystemInfo {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $Headers
    )
    try {
        $vxrailSystemInfo = Invoke-RestMethod -Method Get -Uri "https://10.10.187.27/rest/vxm/v1/system" -Headers $Headers
        Remove-Variable -Name cred -ErrorAction SilentlyContinue
        Print-SystemInfo -systemInfo $vxrailSystemInfo
    } catch [System.Net.WebException] {
       write-host "Error : System.Net.WebException...Please check error logs for more details"
    }
}

### Takes information sent from Get-SystemInfo and outputs only specified info ###
function Print-SystemInfo {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $systemInfo
    )
    #write-host "Cluster Type: " 
    #write-host $vxRailSystemInfo.cluster_type
    #write-host "Cluster Health "
    Write-Host "Health : " $systemInfo.health`n
    write-host "Installed Components"
    $systemInfo.installed_components | select name, current_version, upgrade_status
}
