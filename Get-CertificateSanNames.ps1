Function Get-CertificateSanDnsNames
{
    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$true,Position=1)]
       [string]$certificateBase64
    )

    $certSanitized = $certificateBase64.Replace('-----BEGIN CERTIFICATE-----','').Replace('-----END CERTIFICATE-----','')
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($certSanitized))
    return ($cert.Extensions | Where-Object {$_.Oid.Value -eq "2.5.29.17"}).Format($true)
}
