<#
  .SYNOPSIS
  Script that gets all Certification Authorities that issues certificates from a given certificate template.
  .DESCRIPTION
  Returns an array of all Certification Authorities that issues certificates from the given certificate template.
  .PARAMETER CertificateTemplateName
  Short name (without spaces) to of certificate template name to get Certification Authorities for.
  .EXAMPLE
  Get-TemplateCAs.ps1 'WebServer'
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

[string[]]$certificateAuthorityNames = @()
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
$certificateAuthorityNames

