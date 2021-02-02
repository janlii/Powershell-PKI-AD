<#
  .SYNOPSIS
  Script used to generate URL with RelayState parameter for use with ADFS IDP initiated signon.
  .DESCRIPTION
  .PARAMETER AdfsServerName
  Name of ADFS server (as FQDN).
  .PARAMETER RelyingPartyIdentifier
  Relying party identifier. Found in the "Identifiers" tab for a relying party in ADFS.
  .EXAMPLE
  Get-RelayStateUrl 'fs.acme.com' 'urn:microsoft:adfs:claimsxray'
  .NOTES
  The 'RelayStateForIdpInitiatedSignOnEnabled' parameter must be enabled in ADFS.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$AdfsServerName
    ,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$RelyingPartyIdentifier
)

Add-Type -AssemblyName System.Web
$adfsIdpInitiated = "https://$($AdfsServerName)/adfs/ls/IdpInitiatedSignOn.aspx"
$encodedIdentifier = [System.Web.HttpUtility]::UrlEncode($RelyingPartyIdentifier)
$rpid = 'RPID=' + $encodedIdentifier
$encodedRpid = [System.Web.HttpUtility]::UrlEncode($rpid)
$relayStateUrl = $adfsIdpInitiated + '?RelayState=' + $encodedRpid
Write-Output $relayStateUrl


