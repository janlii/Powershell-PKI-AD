# Powershell-PKI-AD
Powershell scripts and tools used to manage your Active Directory, ADFS and PKI environment.

## Get-TPMEKPub.ps1
Powershell script to display the public key hash (SHA256) for the TPM endorsement key. This script can be executed with normal user privileges.

## Get-TemplateCAs.ps1
Powershell script to display all certification authorities that issues certificates from a given certificate template name.

## HelperFunctions.psm1
Powershell module that simplifies connecting to servers using RDP or Powershell remoting. Create a folder named "HelperFunctions" in %ProgramFiles%\WindowsPowerShell and copy the file into the folder. From Powershell you can now use the following commands:
- Start-RDP servername
- Start-RemotePS servername

## New-ADIssuancePolicy.ps1
Powershell script to create an issuance policy (OID, name and CPS URL) in Active Directory based on an existing OID information.

## New-AuthPolicyForDomainAdmins.ps1
Powershell script that creates an Authentication Policy for Tier0 user accounts/devices and assigns it to Domain Admins. Also adds Domain Admins to the Protected Users group.

## Test-TcpConnection.ps1
Powershell script to test TCP connectivity with timeout value.
