<#
.SYNOPSIS
Check validity of a certificate.
.DESCRIPTION
Checks if a certificate is valid including revocation check.
.PARAMETER CertificateFilePath 
Path to a certificate file.
.EXAMPLE
Test-CertificateRevocation.ps1 C:\temp\janlii_efos.cer
.EXAMPLE 
Test-CertificateRevocation.ps1 C:\temp\adfsserver01.cer
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [ValidateScript({Test-Path $_})] 
    [string]$CertificateFilePath
)
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $CertificateFilePath

# Build chain

$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
#$chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::Offline
$chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::Online
$chainResult = $chain.Build($cert)
if ($chainResult -eq $true) {
    Write-Host "Revocation check was successfull"
}
else {
    Write-Host "Revocation check failed" -ForegroundColor Red
}

Write-Host " "
Write-Host "Chain elements:"
foreach ($chainElem in $chain.ChainElements) {
    Write-Host "[$($chainElem.Certificate.Subject)] $($chainElem.ChainElementStatus.Status)"
}
