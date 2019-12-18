<#
  .SYNOPSIS
  Creates an Authentication Policy for Tier0 user accounts and devices.
  .DESCRIPTION
  The policy will initially allow user accounts to logon to domaincontrollers. Privileged Access Workstations should be added to the list.
#>

# Initialize

$authPolicyName = 'AuthPolicy - Tier 0 Accounts and Devices'
$authPolicyDescription = 'This policy restricts directory service administrator accounts to authenticate against domain controllers and Privileged Access Workstations'
$tgtLifetimeInMins = 120

# Get all domaincontrollers

$domainControllersContainer = (Get-ADDomain -Current LocalComputer).DomainControllersContainer
$domainControllers = ([System.Directoryservices.Activedirectory.Domain]::GetComputerDomain()).DomainControllers
$server =  $domainControllers[0].Name

# Check if authentication policy alread exists

try {$authPolicy = Get-ADAuthenticationPolicy -Identity $authPolicyName -Server $server} catch {$authPolicy = $null}
if ($authPolicy -ne $null) {
    throw "Authentication policy '$($authPolicyName)' already exists!"
}

# Build SID list with domaincontroller SIDs

$sidList = ''
foreach ($domainController in $domainControllers) {
    $dc = Get-ADComputer -Filter "dNSHostName -eq '$($domainController.Name)'" -SearchBase $domainControllersContainer -SearchScope OneLevel -Server $server   
    if ([System.String]::IsNullOrEmpty($sidList) -eq $false) {
        $sidList += ', '
    }
    $sidList += "SID($($dc.SID))"
}
$sddl = "O:SYG:SYD:(XA;OICI;CR;;;WD;(Member_of_any {$($sidList)}))"

# Create the authentication policy

$authPolicy = New-ADAuthenticationPolicy -Name $authPolicyName `
                                         -Description $authPolicyDescription `
                                         -UserTGTLifetimeMins $tgtLifetimeInMins `
                                         -UserAllowedToAuthenticateFrom $sddl `
                                         -Enforce `
                                         -ProtectedFromAccidentalDeletion $true `
                                         -Server $server `
                                         -PassThru

# Get all Domain Admins except the builtin

$domainAdmins = Get-ADGroupMember 'Domain Admins' | ?{$_.objectClass -eq 'user' -and $_.SID.Value.EndsWith('-500') -eq $false}

# Assign all Domain Admins to the authentication policy

foreach ($domainAdmin in $domainAdmins) {
    Set-ADAccountAuthenticationPolicySilo -AuthenticationPolicy $authPolicy.DistinguishedName -Identity $domainAdmin.distinguishedName -Server $server
}

# Add all Domain Admins to the Protected Users group

Add-ADGroupMember -Identity 'Protected Users' -Members $domainAdmins -Server $server

