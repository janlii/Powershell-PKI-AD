<#
  .SYNOPSIS
  Skriptet bygger en URL som kan användas med IDP initierad inloggning och "relay state".
  .DESCRIPTION
  .PARAMETER AdfsServerName
  Namn på ADFS server som skall användas. Anges som FQDN.
  .PARAMETER RelyingPartyIdentifier
  Identifiere för en "relying party". Hittas under fliken "Identifiers" för en "relying party" i ADFS.
  .EXAMPLE
  Get-RelayStateUrl 'fs.skatteverket.se' 'https://jira.rsv.se/plugins/servlet/samlsso'
  .NOTES
  Parametern 'RelayStateForIdpInitiatedSignOnEnabled' måste vara aktiverad i ADFS!
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
$adfsIdpInitiated = "https://$($AdfsServerName)/adfs/ls/IdpInitiatedSignOn.aspx?"
$encodedIdentifier = [System.Web.HttpUtility]::UrlEncode($RelyingPartyIdentifier)
$rpid = 'RPID=' + $encodedIdentifier
$encodedRpid = [System.Web.HttpUtility]::UrlEncode($rpid)
$relayStateUrl = $adfsIdpInitiated + '?RelayState=' + $encodedRpid
Write-Output $relayStateUrl


