# Powershell-PKI-AD
Powershell scripts and tools used to manage your Active Directory and PKI environment.

## Get-TPMEKPub.ps1
Powershell script to display the public key hash (SHA256) for the TPM endorsement key.

## New-ADIssuancePolicy.ps1
Powershell script to create an issuance policy (OID, name and CPS URL) in Active Directory based on an existing OID information.

## New-AuthPolicyForDomainAdmins.ps1
Powershell script that creates an Authentication Policy for Tier0 user accounts/devices and assigns it to Domain Admins. Also adds Domain Admins to the Protected Users group.

## Test-TcpConnection.ps1
Powershell script to test TCP connectivity with timeout value.
