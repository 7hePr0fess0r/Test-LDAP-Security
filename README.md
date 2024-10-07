# Test-LDAPSecurity.ps1

## Overview
`Test-LDAPSecurity.ps1` is a PowerShell script designed to enumerate LDAP server side protection specifically 

1. LDAP Signing
2. LDAP Channel Binding

This script was developed during an Active Directory Audit conducted for a client. During that test, I only had a domain-joined machine, so I developed this code (obviously with the help of ChatGPT :innocent: ) to confirm the vulnerability and take proof of concept (PoC) showing LDAP server-side protection is enabled or not.

## Why it is important
Enabling both LDAP Signing and LDAP Channel Binding is the most effective measure to mitigate the risk of LDAP relaying attacks. LDAP Signing protects the LDAP service, whereas LDAP Channel Binding works to protect the LDAPS service.

## Usage
To run the script, use the following command structure:

```powershell
.\Test-LDAPSecurity.ps1 --Servers "dc1,dc2,dc3" --CheckBoth
```


| Parameter              | Description                                                                                      |
|------------------------|--------------------------------------------------------------------------------------------------|
| `--Servers`            | Comma-separated list of server names (e.g., `"dc1,dc2,dc3"`).                                 |
| `--LdapPort`           | The port for LDAP (default: `389`).                                                             |
| `--LdapsPort`          | The port for LDAPS (default: `636`).                                                            |
| `--CheckSigning`       | Check LDAP Signing on the Domain Controllers only.                                              |
| `--CheckChannelBinding` | Check LDAP Channel Binding on the Domain Controllers only.                                      |
| `--CheckBoth`          | Check both LDAP Signing and LDAP Channel Binding.                                              |
| `--Help`               | Display the help menu with usage information.                                                  |


## Reference
- https://viperone.gitbook.io/pentest-everything/everything/everything-active-directory/adversary-in-the-middle/ldap-relay
- https://www.hub.trimarcsecurity.com/post/return-of-the-ldap-channel-binding-and-ldap-signing
- https://github.com/zyn3rgy/LdapRelayScan
