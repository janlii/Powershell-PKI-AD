<#
  .SYNOPSIS
  This script can be used to test TCP connectivity to a host.
  .DESCRIPTION 
  This script can be used to test TCP connectivity to a host providing a timeout value.
  .PARAMETER DnsName
  Host DNS name.
  .PARAMETER PortNumber
  TCP port number.
  .PARAMETER TimeOutInSecs
  Timeout value in seconds. Default value is 5 seconds.
  .EXAMPLE
  Test-TcpConnection www.acme.local 443 10
  .EXAMPLE
  Test-TcpConnection -DnsName rdp.acme.local -PortNumber 3389
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$DnsName
    ,
    [Parameter(Mandatory=$True,Position=2)]
    [int]$PortNumber
    ,
    [Parameter(Mandatory=$False,Position=3)]
    [int]$TimeOutInSecs = 5
)

# First try to resolve the DNS name

try {$dnsResult = Resolve-DnsName $DnsName -DnsOnly -ErrorAction SilentlyContinue} catch {$dnsResult = $null}
if ($dnsResult -eq $null) {
    throw "Hostname '$($DnsName)' could not be resolved to an IP address"
}

# Test TCP connectivity

$tcpClient = New-Object system.Net.Sockets.TcpClient
$waitTimeSpan = [System.TimeSpan]::FromSeconds($TimeoutInSecs)
$result = $tcpClient.ConnectAsync($dnsResult.IP4Address, $PortNumber).Wait($waitTimeSpan)
if ($tcpClient.Connected -eq $false) {
    $tcpClient.Dispose()
    throw "TCP connect to '$($DnsName)' ($($dnsResult.IP4Address)) on port '$($PortNumber)' failed"
}

# Success

$tcpClient.Close()
$tcpClient.Dispose()
Write-Host "TCP connect to '$($DnsName)' ($($dnsResult.IP4Address)) on port '$($PortNumber)' succeeded"

