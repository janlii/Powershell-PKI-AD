Function Start-RDP
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$ComputerName
    )

    $ind = $ComputerName.IndexOf('.')
    if ($ind -ne -1) {
        $ComputerName = $ComputerName.Substring(0, $ind)
    } 

    try {
        $computer = Get-ADComputer $ComputerName -Properties OperatingSystem -ErrorAction Stop
    }
    catch {
        throw "Server '$($ComputerName)' not found!"
    }

    if (-not($computer.Name.ToLower().EndsWith("w"))) {
        throw "Server '$($computer.Name)' does not support RDP!"
    }

    if ($computer.OperatingSystem -like 'Windows Server 2012*') {
        Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/v $($computer.DNSHostName) /restrictedadmin"             
    }
    else {
        Start-Process -FilePath "C:\Windows\System32\mstsc.exe" -ArgumentList "/v $($computer.DNSHostName) /remoteguard"
    }
}

Function Start-RemotePS
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$ComputerName
    )

    $ind = $ComputerName.IndexOf('.')
    if ($ind -ne -1) {
        $ComputerName = $ComputerName.Substring(0, $ind)
    } 

    try {
        $computer = Get-ADComputer $ComputerName -Properties OperatingSystem -ErrorAction Stop
    }
    catch {
        throw "Server '$($ComputerName)' not found!"
    }

    if (-not($computer.Name.ToLower().EndsWith("w"))) {
        throw "Server '$($computer.Name)' does not support Powershell!"
    }

	powershell.exe -noexit -Command "Enter-PSSession -ComputerName $($computer.DNSHostName)" 
}
