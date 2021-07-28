<#
  .SYNOPSIS
  Grants a user read permission to a certificate private key located in Local Machine store.
  .DESCRIPTION 
  Grants a user read permission to a certificate private key located in Local Machine store.
  .PARAMETER CertificateThumbprint
  Certificate thumbprint.
  .PARAMETER UserName
  Name of user to grant read permissions.
  .EXAMPLE
  Grant-LocalMachinePrivateKeyReadPermissions.ps1 '6EDF02CB16053992372326EDAEA403217A259D01' 'ACME\useracc'
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$CertificateThumbprint
    ,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$UserName
)

[System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate = Get-ChildItem "Cert:\LocalMachine\My\$($CertificateThumbprint)" -ErrorAction SilentlyContinue
if ($certificate -eq $null) {
    throw "No certificate with thumbprint '$($CertificateThumbprint)' found in LocalMachine store"
}

$privateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)
$keyName = $privateKey.Key.UniqueName
$keyPath = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$keyName"
$permissions = Get-Acl -Path $keyPath
$rule = New-Object Security.AccessControl.FileSystemAccessRule $userName, "Read", Allow
$permissions.AddAccessRule($rule)
Set-Acl -Path $keyPath -AclObject $permissions
