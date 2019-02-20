### Ignore soft/self-signed certs, can be used alone ###
function Unblock-SelfSignedCerts {
    begin {
        $CallerErrorPreference = $ErrorActionPreference
    }
    process {
        try {
            $ErrorActionPreference = 'Stop'
            Add-Type -TypeDefinition  @(
                "using System.Net;"
                "using System.Security.Cryptography.X509Certificates;"
                "public class TrustAllCertsPolicy : ICertificatePolicy {"
                "     public bool CheckValidationResult("
                "     ServicePoint srvPoint, X509Certificate certificate,"
                "     WebRequest request, int certificateProblem) {"
                "         return true;"
                "    }"
                "}"
            )
          }
        catch {
            Write-Error -ErrorRecord $PSItem -ErrorAction $CallerErrorPreference
        }
        finally {
            [System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]@{}
        }
    }
    end {}
}
