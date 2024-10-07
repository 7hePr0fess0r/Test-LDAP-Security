param (
    [string[]]$Servers,                # Array of server names
    [int]$LdapPort = 389,              # Default port for LDAP (non-secure)
    [int]$LdapsPort = 636,             # Default port for LDAPS (secure)
    [switch]$CheckSigning,             # Check LDAP Signing only
    [switch]$CheckChannelBinding,      # Check LDAP Channel Binding only
    [switch]$CheckBoth,                # Check both LDAP Signing and LDAP Channel Binding
    [switch]$Help                      # Show help menu
)

if ($Help) {
    Write-Host @'
Usage: .\Test-LDAPSecurity.ps1 [parameters]

Parameters:
  --Servers                 : Comma-separated list of server names (e.g., "dc1,dc2").
  --LdapPort                : The port for LDAP (default: 389).
  --LdapsPort               : The port for LDAPS (default: 636).
  --CheckSigning            : Check LDAP Signing on the Domain Controller only.
  --CheckChannelBinding      : Check LDAP Channel Binding on the Domain Controller only.
  --CheckBoth               : Check both LDAP Signing and LDAP Channel Binding.
  --Help                    : Show this help menu.
'@
    exit
}

function Test-LDAPSigning {
    param (
        [string]$Server
    )

    $ldapPath = "LDAP://$Server:$LdapPort"
    $directoryEntry = New-Object System.DirectoryServices.DirectoryEntry
    $directoryEntry.Path = $ldapPath
    $directoryEntry.AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::None
    try {
        $directorySearcher = New-Object System.DirectoryServices.DirectorySearcher
        $directorySearcher.SearchRoot = $directoryEntry
        $directorySearcher.Filter = "(objectClass=user)"
        $searchResult = $directorySearcher.FindOne()

        if ($searchResult) {
            Write-Host " [+] LDAP signing is NOT required."
        } else {
            Write-Host " [+] Failed to query LDAP without signing. LDAP signing might be required."
        }
    } catch {
        Write-Host " [+] An error occurred while testing LDAP Signing. Please review your settings."
    }
}

function Test-LDAPChannelBinding {
    param (
        [string]$Server
    )

    $ldapPath = "LDAP://$Server:$LdapsPort"

    try {
        $directoryEntry = New-Object System.DirectoryServices.DirectoryEntry
        $directoryEntry.Path = $ldapPath
        $directoryEntry.AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::SecureSocketsLayer
        $directorySearcher = New-Object System.DirectoryServices.DirectorySearcher
        $directorySearcher.SearchRoot = $directoryEntry
        $directorySearcher.Filter = "(objectClass=user)"
        $searchResult = $directorySearcher.FindOne()

        if ($searchResult) {
            Write-Host " [+] LDAP Channel Binding is NOT required."
        } else {
            Write-Host " [+] Failed to query LDAP over SSL. LDAP Channel Binding might be required."
        }
    } catch {
        if ($_.Exception.Message -like "*The LDAP server requires channel binding*") {
            Write-Host " [+] LDAP Channel Binding is required."
        } elseif ($_.Exception.Message -like "*The server does not support SSL or channel binding*") {
            Write-Host " [+] The server does not support SSL or channel binding."
        } else {
            Write-Host " [+] An error occurred while testing LDAP Channel Binding. Please review your settings."
        }
    }
}

# Main script execution for each server
foreach ($Server in $Servers) {
    Write-Host "`nResults for $Server:"

    if ($CheckSigning) {
        Test-LDAPSigning -Server $Server
    }
    
    if ($CheckChannelBinding) {
        Test-LDAPChannelBinding -Server $Server
    }
    
    if ($CheckBoth) {
        Test-LDAPSigning -Server $Server
        Test-LDAPChannelBinding -Server $Server
    }
}
