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
  New-ADPolicyOID.ps1 '1.2.752.146.101.2' 'Swedish Social Insurance Agency Auth Certificate Policy' 'http://www.myndighetsca.se/cps/'
  .NOTES
  Must be run with Enterprise Admin permissions.
  https://technet.microsoft.com/en-us/library/bf1b7271-5d9b-4880-bc08-c2b70c8623e3
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$IssuancePolicyOid
    ,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$IssuancePolicyName
    ,
    [Parameter(Mandatory=$true,Position=3)]
    [string]$IssuancePolicyCps
)
  
# Initialize

$domain = Get-ADDomain -Current LocalComputer
$dc = $domain.PDCEmulator
$oidPath = "CN=OID,CN=Public Key Services,CN=Services,CN=Configuration,$($domain.DistinguishedName)"

# Create the CN

$cnPrefix = $IssuancePolicyOid.Substring($IssuancePolicyOid.LastIndexOf('.') + 1)
$algorithm = [Security.Cryptography.HashAlgorithm]::Create('MD5')
$enc = [system.Text.Encoding]::Unicode
$hash = $algorithm.ComputeHash($enc.GetBytes($IssuancePolicyOid))
$issuancePolicyCommonName = $cnPrefix + '.' + (-Join ($hash | ForEach {"{0:x2}" -f $_})).ToUpper()

# Get or create the issuance policy

$issuancePolicyPath = "CN=$($issuancePolicyCommonName),$($oidPath)"
try {$issuancePolicy = Get-ADObject -Identity $issuancePolicyPath -Server $dc} catch {$issuancePolicy = $null}
if ($issuancePolicy -eq $null)
{
    Write-Host "Create issuance policy '$($IssuancePolicyName)' ($($issuancePolicyPath))"
    $otherAttrs = @{'flags'=2;'msPKI-Cert-Template-OID'="$($IssuancePolicyOid)";'msPKI-OID-CPS'="$($IssuancePolicyCps)"}
    $issuancePolicy = New-ADObject -Name $issuancePolicyCommonName -Path $oidPath -Type msPKI-Enterprise-Oid -OtherAttributes $otherAttrs -DisplayName $IssuancePolicyName -Server $dc -PassThru
    if ($issuancePolicy -eq $null)
    {
        throw "Failed to create issuance policy for '$($IssuancePolicyOid)' ($($IssuancePolicyName))"
    }
}
else
{
    Write-Host "Issuance policy '$($IssuancePolicyName)' ($($issuancePolicyPath)) already exists"
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
