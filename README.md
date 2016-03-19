Script to query all leases on the specified DHCP server(s) and compare them to see if there are any duplicates. Discovered duplicates will have their full array of information displayed for the sake of comparison. Written in PowerShell.

Servers are specified via the **-ServerList** mandatory parameter. It accepts an array of input. Must be at least length 1.