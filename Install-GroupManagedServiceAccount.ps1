<#
  .SYNOPSIS
  Script that installs a Group Managed Service Account (GMSA) on a server, without having to install 'RSAT-AD-Tools'.
  .DESCRIPTION
  Before installing the GMSA, the script will first check if the service account is ready for use on this server.
  .PARAMETER AccountName
  Name of Group Managed Service Account to install on this server.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$AccountName
)
#Requires -RunAsAdministrator

#region CSharp code

$sourceCode =  @"
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
namespace AD
{
    public class GroupManagedServiceAccount
    {
        [DllImport("logoncli.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern int NetAddServiceAccount (string serverName, string accountName, string password, int flags);

        [DllImport("logoncli.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern int NetIsServiceAccount (string serverName, string accountName, ref bool isServiceAccount);

        public static void InstallServiceAccount(string accountName)
        {
            int result = NetAddServiceAccount(null, accountName, null, 0);
            if (result != 0)
            {
                throw new Win32Exception(result);
            }
        }

        public static bool TestServiceAccount(string accountName)
        {
            bool isServiceAccount = false;
            int result = NetIsServiceAccount(null, accountName, ref isServiceAccount);
            if (result != 0)
            {
                throw new Win32Exception(result);
            }
            return isServiceAccount;
        }
    }
}
"@

#endregion

#region Main script

if (-not ([System.Management.Automation.PSTypeName]'AD.GroupManagedServiceAccount').Type) {
    Add-Type -TypeDefinition $sourceCode -Language CSharp
}

try {

    $gmsa = [ADSI]"WinNT://$($env:USERDNSDOMAIN)/$($AccountName)$,user"
    if ([String]::IsNullOrEmpty($gmsa.Path)) {
        throw "Cannot find an account '$($AccountName)' in '$($env:USERDNSDOMAIN)'."
    
    }
    $isServiceAccount = [AD.GroupManagedServiceAccount]::TestServiceAccount($AccountName)
    if ($isServiceAccount -eq $false) {
        throw "The account '$($AccountName)' can not be installed on this server. Verify that this computer have permission to use the GMSA."
    }
    [AD.GroupManagedServiceAccount]::InstallServiceAccount($AccountName)
    Write-Host "The account '$($AccountName)' is now installed on this server."
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

#endregion

