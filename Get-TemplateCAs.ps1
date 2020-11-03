<#
  .SYNOPSIS
  Script that creates an issuance policy object (OID, name and CPS path) in Active Directory based on an existing OID.
  .DESCRIPTION
  The issuance policy OID is registered in Active Directory in CN=OID,CN=Public Key Services,CN=Services,CN=Configuration,DC=XXX,DC=SE.
  Equivalent to the "certutil -oid" command.
  .PARAMETER IssuancePolicyOid
  Issuance policy OID to register in Active Directory.  
  .PARAMETER IssuancePolicyName
  Name of the issuance policy.
  .PARAMETER IssuancePolicyCps
  URL to issuance policy CPS (Certificate Practice Statement)
  .EXAMPLE
  New-ADIssuancePolicy.ps1 '1.2.752.146.101.2' 'Swedish Social Insurance Agency Auth Certificate Policy' 'http://www.myndighetsca.se/cps/'
  .NOTES
  Must be run with Enterprise Admin permissions.
  https://technet.microsoft.com/en-us/library/bf1b7271-5d9b-4880-bc08-c2b70c8623e3
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$CertificateTemplateName
)

# Initialize

$domain = Get-ADDomain
$dc = $domain.PDCEmulator

# Get CA that issues certificates for the template name

$certificateAuthorityNames = @()
$policyServerAD = New-Object -ComObject X509Enrollment.CX509EnrollmentPolicyActiveDirectory
$policyServerAD.Initialize($dc, $null, 2, $false, 2)
$policyServerAD.SetCredential(0, 2, $null, $null)
$policyServerAD.LoadPolicy(2)
foreach ($template in $policyServerAD.GetTemplates()) {
    if ($template.Property(1) -eq $CertificateTemplateName) {
        $certificateAuthorities = $policyServerAD.GetCAsForTemplate($template)
        foreach ($certificateAuthority in $certificateAuthorities) {
            $certificateAuthorityNames += $certificateAuthority.Property(1)
        }
    }
}
if ($certificateAuthorityNames.Count -eq 0) {
    throw "No CA found for certificatetemplate '$($CertificateTemplateName)'"
}
Write-Host $certificateAuthorityNames

