# Powershell-PKI-AD
Powershell scripts and tools used to manage your Active Directory, ADFS and PKI environment.

## Get-TPMEKPub.ps1
Powershell script to display the public key hash (SHA256) for the TPM endorsement key. This script can be executed with normal user privileges.

## Get-TemplateCAs.ps1
Powershell script to display all certification authorities that issues certificates from a given certificate template name.

## Grant-LocalMachinePrivateKeyReadPermissions.ps1
Powershell script that grants a user account read permissions to the private key of a certificate in the local machine store.

## HelperFunctions.psm1
Powershell module that simplifies connecting to servers using RDP or Powershell remoting. Create a folder named "HelperFunctions" in %ProgramFiles%\WindowsPowerShell and copy the file into the folder. From Powershell you can now use the following commands:
- Start-RDP servername
- Start-RemotePS servername

## Install-GroupManagedServiceAccount.ps1
Script that installs a Group Managed Service Account (GMSA) on a server, without having to install the 'RSAT-AD-Tools' feature.

## New-ADIssuancePolicy.ps1
Powershell script to create an issuance policy (OID, name and CPS URL) in Active Directory based on an existing OID information.

## New-AuthPolicyForDomainAdmins.ps1
Powershell script that creates an Authentication Policy for Tier0 user accounts/devices and assigns it to Domain Admins. Also adds Domain Admins to the Protected Users group.

## New-KdcOfflineRequest.ps1
Powershell script that creates a certificate request (CSR) for a "Kerberos Authentication" certificate for installation on domain controllers. Can be used when no internal PKI is in use.

## Test-CertificateRevocation.ps1
Powershell script that can be used to check certificate revocation.

## Test-TcpConnection.ps1
Powershell script to test TCP connectivity with timeout value.
