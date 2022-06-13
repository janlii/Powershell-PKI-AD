<#
  .SYNOPSIS
  Create a strong name mapping string from a certificate.
  .DESCRIPTION
  The strong name mapping string can be added to the 'altSecurityIdentities' user attribute to allow smartcard logon with the certificarte.
  .PARAMETER CertificateFile
  Path to certificate file.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    $CertificateFile
)

if ((Test-Path $CertificateFile) -eq $false) {
    throw "File '$($CertificateFile)' not found"
}

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $CertificateFile

# Reverse issuer

$parts = $cert.Issuer.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries).Trim()
[array]::Reverse($parts)
$reversedIssuer = $parts -join ','

# Reverse serialnumber

$parts = $cert.SerialNumber -split "(\w{2})" -match "\w"
[array]::Reverse($parts)
$reversedSerial = $parts -join ''

# Build strong mapping string

$strongMapping = "X509:<I>$($reversedIssuer)<SR>$($reversedSerial)"
Write-Host $strongMapping
